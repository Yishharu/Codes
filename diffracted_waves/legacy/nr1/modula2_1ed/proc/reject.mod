IMPLEMENTATION MODULE Reject;

   FROM GammBeta IMPORT GammLn;
   FROM Uniform  IMPORT Ran3;
   FROM NRMath   IMPORT Sqrt, Exp, Ln, Sin, Cos, XOR, Random;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT Error;

   VAR
      BnlDevNOld: INTEGER;(* These variables store quantities from previous calls. *)
      BnlDevPOld, BnlDevOldg, BnlDevEn, BnlDevPc, BnlDevPlog, BnlDevPclog: REAL;
      PoiDevOldm, PoiDevSq, PoiDevAlxm, PoiDevG: REAL;

   PROCEDURE BnlDev(    pp:   REAL; 
                        n:    INTEGER; 
                    VAR idum: INTEGER): REAL; 
      CONST 
         pi = 3.141592654; 
      VAR 
         am, em, g, angle, p, bnl, sq, t, y: REAL; 
         j: INTEGER; 
   BEGIN
      IF pp <= 0.5 THEN p := pp ELSE p := 1.0-pp END; 
	   (*
	     The binomial distribution is invariant
	     under changing pp to 1.-pp, if we also change the answer to
	     n minus itself; we'll remember to do this below.
	   *)
      am := Float(n)*p; (* This is the mean of the deviate to be produced. *)
      IF n < 25 THEN (* Use the direct method while n is
                        not too large. This can require up to 25 calls to Ran3. *)
         bnl := 0.0; 
         FOR j := 1 TO n DO 
            IF Ran3(idum) < p THEN 
               bnl := bnl+1.0
            END
         END
      ELSIF am < 1.0 THEN (* If fewer than one event is expected out of 25 or 
                              more trials, then the distribution is quite
                             accurately Poisson.  Use direct Poisson method. *)
         g := Exp(-am); 
         t := 1.0; 
         j := -1;
         REPEAT 
            INC(j, 1); 
            t := t*Ran3(idum); 
         UNTIL ((t < g) OR (j = n)); 
         bnl := Float(j)
      ELSE (* Use the rejection method. *)
         IF n <> BnlDevNOld THEN (* If n has changed, then
                                    compute useful quantities. *)
            BnlDevEn := Float(n); 
            BnlDevOldg := GammLn(BnlDevEn+1.0); 
            BnlDevNOld := n
         END; 
         IF p <> BnlDevPOld THEN (* If P has changed, then
                                    compute useful quantities. *)
            BnlDevPc := 1.0-p; 
            BnlDevPlog := Ln(p); 
            BnlDevPclog := Ln(BnlDevPc); 
            BnlDevPOld := p
         END; 
         sq := Sqrt(2.0*am*BnlDevPc); (* The following code should by now
                                         seem familiar: rejection method with a
                                         Lorentzian comparison function. *)
         REPEAT 
            REPEAT 
               angle := pi*Ran3(idum); 
               y := Sin(angle)/Cos(angle); 
               em := sq*y+am; (* Trick for integer-valued distribution. *)
            UNTIL (em >= 0.0) AND (em < BnlDevEn+1.0); 
            em := Float(Trunc(em)); 
            t := 1.2*sq*(1.0+y*y)*Exp(  BnlDevOldg - GammLn(em+1.0)
                                      - GammLn(BnlDevEn-em+1.0) + em*BnlDevPlog
                                      + (BnlDevEn-em) * BnlDevPclog ); 
         UNTIL Ran3(idum) <= t; (* Reject. This
                                   happens about 1.5 times per deviate, on average. *)
         bnl := em
      END; 
      IF p <> pp THEN (* Remember to undo the symmetry transformation. *)
         bnl := Float(n)-bnl
      END; 
      RETURN bnl; 
   END BnlDev; 

   PROCEDURE GamDev(VAR ia,
                        idum: INTEGER): REAL;
      VAR
         am, e, s, v1, v2, x, y, a, b: REAL;
         j: INTEGER;
   BEGIN
      IF ia < 1 THEN
         Error('GamDev', 'Illegal input');
      END;
      IF ia < 6 THEN (* Use direct method, adding waiting times. *)
         x := 1.0;
         FOR j := 1 TO ia DO
            x := x*Ran3(idum)
         END;
         x := -Ln(x)
      ELSE (* Use rejection method. *)
         REPEAT
            REPEAT
               REPEAT (* These four lines generate the tangent of a random angle.
                         They are equivalent to *)
                  v1 := 2.0*Ran3(idum)-1.0;
                  v2 := 2.0*Ran3(idum)-1.0; (* y := TAN(3.1415926 * Ran3(idum)). *)
                  a := v1*v1 + v2*v2;
               UNTIL (a <= 1.0);
               y := v2/v1;
               am := Float(ia-1);
               s := Sqrt(2.0*am+1.0);
               x := s*y+am; (* We decide whether to reject x: *)
            UNTIL x > 0.0; (* Reject in region of zero probability. *)
            a := Ln(x/am);
            b := Exp(am*a-s*y);
            e := (1.0+(y*y))*b; (* Ratio of probability fn.to comparison fn. *)
         UNTIL
         Ran3(idum) <= e(* Reject on basis of a
                           second uniform deviate. *)
      END; 
      RETURN x; 
   END GamDev; 

   PROCEDURE PoiDev(    xm: REAL; 
                    VAR idum: INTEGER): REAL; 
      CONST 
         pi = 3.141592654; 
      VAR 
         em, t, y: REAL; 
   BEGIN 
      IF xm < 12.0 THEN (* Use direct method. *)
         IF xm <> PoiDevOldm THEN 
            PoiDevOldm := xm; 
            PoiDevG := Exp(-xm)(* If xm is new, compute the exponential. *)
         END; 
         em := Float(-1); 
         t := 1.0; 
         REPEAT 
            em := em+1.0; (* Instead of adding exponential deviates it is 
                             equivalent to multiply uniform deviates. Then we never
                             actually have to take the log, merely compare to the pre-computed
                             exponential. *)
            t := t*Ran3(idum); 
         UNTIL 
         t <= PoiDevG
      ELSE (* Use rejection method. *)
         IF xm <> PoiDevOldm THEN (* If xm has changed since the last call, then 
                                     precompute some functions which occur below. *)
            PoiDevOldm := xm; 
            PoiDevSq := Sqrt(2.0*xm); 
            PoiDevAlxm := Ln(xm); 
            PoiDevG := xm*PoiDevAlxm-
                       GammLn(xm+1.0)(* The function GammLn is the natural 
                                        logarithm of the gamma function, as given
                                        in section 6.2. *)
         END; 
         REPEAT 
            REPEAT 
               y := pi*Ran3(idum); 
               y := Sin(y)/Cos(y); 
				   (*
				     y is a deviate from a Lorentzian comparison fn.
				   *)
               em := PoiDevSq*y+xm; (* em is y, shifted and scaled. *)
            UNTIL (em >= 0.0); (* Reject if in regime of zero probability. *)
            em := Float(Trunc(em)); (* The trick for integer-valued distributions. *)
            t := 0.9*(1.0+y*y)*Exp(em*PoiDevAlxm-GammLn(em+1.0)-PoiDevG); 
			   (*
			     The ratio of the desired distribution to the comparison function; we
			     accept or reject by comparing it to another uniform deviate. The
			     factor 0.9 is chosen so that t never exceeds 1.
			   *)
         UNTIL (Ran3(idum) <= t)
      END; 
      RETURN em; 
   END PoiDev; 

BEGIN
   BnlDevNOld := -1;(* Initializations. *)
   BnlDevPOld := -1.0;
   PoiDevOldm := -1.0;
   (*
     PoidevOldm is used to determine whether
     the variable xm has changed since the last call.
   *)
END Reject.
