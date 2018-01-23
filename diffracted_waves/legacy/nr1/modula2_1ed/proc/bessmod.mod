IMPLEMENTATION MODULE BessMod;

   FROM NRMath   IMPORT Sqrt, SqrtSD, ExpSD, LnSD;
   FROM NRSystem IMPORT LongReal, D, S, Float, Trunc;
   FROM NRIO     IMPORT Error;

   PROCEDURE BessI(n: INTEGER; 
                    x: REAL): REAL; 
      CONST 
         iAcc = 40; (* Make iAcc larger to increase accuracy. *)
         bigNo = 1.0E10; 
         bigni = 1.0E-10; 
      VAR 
         bi, bim, bip, tox, ans, bessI: REAL; 
         j, m: INTEGER;
   BEGIN 
      IF n < 2 THEN 
         Error('BessI', 'index n is less than 2');
      END; 
      IF x = 0.0 THEN 
         bessI := 0.0
      ELSE 
         ans := 0.0; 
         tox := 2.0/ABS(x); 
         bip := 0.0; 
         bi := 1.0; 
         m := 2*(n+Trunc(Sqrt(Float(iAcc*n)))); 
         FOR j := m TO 1 BY -1 DO (* Downward recurrence from
                                     an even value m. *)
            bim := bip+Float(j)*tox*bi; 
            bip := bi; 
            bi := bim; 
            IF ABS(bi) > bigNo THEN (* Renormalize to prevent overflows. *)
               ans := ans*bigni; 
               bi := bi*bigni; 
               bip := bip*bigni
            END; 
            IF j = n THEN 
               ans := bip
            END
         END; 
         IF (x < 0.0) AND ODD(n) THEN 
            ans := (-ans)
         END; 
         bessI := ans*BessI0(x)/bi(* Normalize with BessI0. *)
      END; 
      RETURN bessI
   END BessI;

   PROCEDURE BessI0(x: REAL): REAL; 
      VAR 
         ax, bessI0: REAL; 
         y: LongReal; (* Accumulate polynomials in double precision. *)
   BEGIN 
      IF ABS(x) < 3.75 THEN 
         y := D((x/3.75)*(x/3.75));
         bessI0 := S(D(1.0)+y*(D(3.5156229)+y*(D(3.0899424)
                  +y*(D(1.2067492)+y*(D(0.2659732)+y*(D(0.360768E-1)
                  +y*D(0.45813E-2)))))));
      ELSE
         ax := ABS(x);
         y := D(3.75/ax);
         bessI0 := S(ExpSD(ax)/SqrtSD(ax)*(D(0.39894228)+y*(D(0.1328592E-1)
                  +y*(D(0.225319E-2)+y*(D(-0.157565E-2)+y*(D(0.916281E-2)
                  +y*(D(-0.2057706E-1)+y*(D(0.2635537E-1)+y*(D(-0.1647633E-1)
                  +y*D(0.392377E-2))))))))));
      END;
      RETURN bessI0
   END BessI0;

   PROCEDURE BessI1(x: REAL): REAL;
      VAR
         ax, bessI1: REAL;
         y, ans: LongReal; (* Accumulate polynomials in double precision. *)
   BEGIN
      IF ABS(x) < 3.75 THEN (* Polynomial fit. *)
         y := D((x/3.75)*(x/3.75));
         ans := D(x)*(D(0.5)+y*(D(0.87890594)+y*(D(0.51498869)
               +y*(D(0.15084934)+y*(D(0.2658733E-1)+y*(D(0.301532E-2)
               +y*D(0.32411E-3)))))))
      ELSE
         ax := ABS(x);
         y := D(3.75/ax);
         ans := D(0.2282967E-1)+y*(D(-0.2895312E-1)+y*(D(0.1787654E-1)
               -y*D(0.420059E-2))); 
         ans := D(0.39894228)+y*(D(-0.3988024E-1)+y*(D(-0.362018E-2)
               +y*(D(0.163801E-2)+y*(D(-0.1031555E-1)+y*ans)))); 
         ans := (ExpSD(ax)/SqrtSD(ax))*ans; 
         IF x < 0.0 THEN 
            ans := -ans
         END
      END; 
      bessI1 := S(ans);
      RETURN bessI1
   END BessI1;

   PROCEDURE BessK(n: INTEGER; 
                  x: REAL): REAL; 
      VAR 
         tox, bkp, bkm, bk, bessK: REAL; 
         j: INTEGER; 
   BEGIN 
      IF n < 2 THEN 
         Error('BessK', 'index n less than 2'); 
      END; 
      tox := 2.0/x; 
      bkm := BessK0(x); (* Upward recurrence for all x *)
      bk := BessK1(x); 
      FOR j := 1 TO n-1 DO (* ...and here it is. *)
         bkp := bkm+Float(j)*tox*bk; 
         bkm := bk; 
         bk := bkp
      END; 
      bessK := bk; 
      RETURN bessK
   END BessK;

   PROCEDURE BessK0(x: REAL): REAL; 
      VAR 
         bessK0: REAL;
         y:      LongReal; (* Accumulate polynomials in double precision. *)
   BEGIN 
      IF x <= 2.0 THEN (* Polynomial fit. *)
         y := D(x*x/4.0);
         bessK0 := S(-LnSD(x/2.0)*D(BessI0(x))+(D(-0.57721566)
                  +y*(D(0.42278420)+y*(D(0.23069756)+y*(D(0.3488590E-1)
                  +y*(D(0.262698E-2)+y*(D(0.10750E-3)+y*D(0.74E-5))))))));
      ELSE
         y := D(2.0/x);
         bessK0 := S(ExpSD(-x)/SqrtSD(x)*(D(1.25331414)+y*(D(-0.7832358E-1)
                  +y*(D(0.2189568E-1)+y*(D(-0.1062446E-1)+y*(D(0.587872E-2)
                  +y*(D(-0.251540E-2)+y*D(0.53208E-3))))))));
      END;
      RETURN bessK0;
   END BessK0;

   PROCEDURE BessK1(x: REAL): REAL;
      VAR
         y: LongReal; (* Accumulate polynomials in double precision. *)
         bessK1: REAL;
   BEGIN
      IF x <= 2.0 THEN (* Polynomial fit. *)
         y := D(x*x/4.0);
         bessK1 := S(LnSD(x/2.0)*D(BessI1(x))+D(1.0/x)*(D(1.0)+y*(D(0.15443144)
                  +y*(D(-0.67278579)+y*(D(-0.18156897)+y*(D(-0.1919402E-1)
                  +y*(D(-0.110404E-2)+y*(D(-0.4686E-4)))))))));
      ELSE
         y := D(2.0/x);
         bessK1 := S(ExpSD(-x)/SqrtSD(x)*(D(1.25331414)+y*(D(0.23498619)
                  +y*(D(-0.3655620E-1)+y*(D(0.1504268E-1)+y*(D(-0.780353E-2)
                  +y*(D(0.325614E-2)+y*(D(-0.68245E-3)))))))));
      END;
      RETURN bessK1
   END BessK1;

END BessMod.
