IMPLEMENTATION MODULE Bessel;

   FROM NRMath   IMPORT LnSD, Sqrt, SqrtDD, SinDD, CosDD;
   FROM NRSystem IMPORT LongReal, D, S, Float, Trunc;
   FROM NRIO     IMPORT Error;

   PROCEDURE BessJ(n: INTEGER; 
                   x: REAL): REAL; 
      CONST 
         iAcc  = 40; (* Make iAcc larger to increase accuracy. *)
         bigNo = 1.0E10; 
         bigni = 1.0E-10;
      VAR
         bj, bjm, bjp, sum, tox, bessJ: REAL;
         j, jSum, m: INTEGER;
   BEGIN
      IF n < 2 THEN
         Error('BessJ', '');
      END;
      IF x = 0.0 THEN
         bessJ := 0.0
      ELSIF ABS(x) > 1.0*Float(n) THEN (* Use upwards recurrence from J0 and
                                          J1. *)
         tox := 2.0/ABS(x);
         bjm := BessJ0(ABS(x));
         bj := BessJ1(ABS(x));
         FOR j := 1 TO n-1 DO
            bjp := Float(j)*tox*bj-bjm;
            bjm := bj;
            bj := bjp
         END;
         bessJ := bj
      ELSE (* Use downwards recurrence from an even value m here
              computed. *)
         tox := 2.0/ABS(x);
         m := 2*((n+Trunc(Sqrt(1.0*Float((iAcc*n))))) DIV 2);
         bessJ := 0.0;
         jSum := 0; (* jSum will alternate between 0 and 1; when
                       it is 1, we accumulate in sum the even terms in (5.4.6). *)
         sum := 0.0; 
         bjp := 0.0; 
         bj := 1.0; 
         FOR j := m TO 1 BY -1 DO (* The downward recurrence. *)
            bjm := Float(j)*tox*bj-bjp; 
            bjp := bj; 
            bj := bjm; 
            IF ABS(bj) > bigNo THEN (* Renormalize to prevent overflows. *)
               bj := bj*bigni; 
               bjp := bjp*bigni; 
               bessJ := bessJ*bigni; 
               sum := sum*bigni
            END; 
            IF jSum <> 0 THEN (* Accumulate the sum. *)
              sum := sum+bj
            END; 
            jSum := 1-jSum; (* Change 0 to 1 or vice-versa. *)
            IF j = n THEN 
               bessJ := bjp(* Save the unnormalized answer. *)
            END
         END; 
         sum := 2.0*sum-bj; (* Compute (5.4.6) *)
         bessJ := bessJ/sum (* and use it to normalize the answer. *)
      END; 
      IF (x < 0.0) AND ODD(n) THEN 
         bessJ := -bessJ
      END; 
      RETURN bessJ; 
   END BessJ;

   PROCEDURE BessJ0(x: REAL): REAL; 
      VAR 
         bessJ0: REAL; 
         ax, xx, z, y, 
         store1, store2: LongReal; 
   (*
     We'll accumulate polynomials in double precision.
   *)
   BEGIN 
      IF ABS(x) < 8.0 THEN (* Direct rational function fit. *)
         z := D(x);
         y := z*z;
         store1 := D(57568490574.0)+ y*(D(-13362590354.0)
                  +y*(D(651619640.7)+y*(D(-11214424.18)
                  +y*(D(77392.33017)+y*(D(-184.9052456))))));
         store2 := D(57568490411.0)+y*(D(1029532985.0)
                  +y*(D(9494680.718)+y*(D(59272.64853)
                  +y*(D(267.8532712)+y*D(1.0)))));
         bessJ0 := S(store1/store2)
      ELSE (* Fitting function (6.4.9). *)
         ax := D(ABS(x));
         z  := D(8.0)/ax;
         y  := z*z;
         xx := ax-D(0.785398164);
         store1 := D(1.0)+y*(D(-0.1098628627E-2)+y*(D(0.2734510407E-4)
                  +y*(D(-0.2073370639E-5)+y*D(0.2093887211E-6))));
         store2 := D(-0.1562499995E-1)+y*(D(0.1430488765E-3)
                  +y*(D(-0.6911147651E-5)+y*(D(0.7621095161E-6)
                  -y*D(0.934945152E-7))));
         bessJ0  := S(SqrtDD(D(0.636619772)/ax)
                   *(CosDD(xx)*store1-z*SinDD(xx)*store2));
      END;
      RETURN bessJ0;
   END BessJ0;

   PROCEDURE BessJ1(x: REAL): REAL;
      VAR
         bessJ1: REAL;
         ax, xx, z, y,
         store1, store2: LongReal;
   (*
     We'll accumulate polynomials in double precision.
   *)
   BEGIN
      IF ABS(x) < 8.0 THEN (* Direct rational approximation. *)
         z := D(x);
         y := z*z;
         store1 := D(x)*(D(72362614232.0)+y*(D(-7895059235.0)+y*(D(242396853.1)
                +y*(D(-2972611.439)+y*(D(15704.48260)+y*(D(-30.16036606)))))));
         store2 := D(144725228442.0)+y*(D(2300535178.0)+y*(D(18583304.74)
                +y*(D(99447.43394)+y*(D(376.9991397)+y*D(1.0)))));
         bessJ1 := S(store1/store2);
      ELSE (* Fitting function (6.4.9). *)
         ax := D(ABS(x));
         z := D(8.0)/ax;
         y := z*z;
         xx := ax-D(2.356194491);
         store1 := D(1.0)+y*(D(0.183105E-2)+y*(D(-0.3516396496E-4)
                +y*(D(0.2457520174E-5)+y*(D(-0.240337019E-6)))));
         store2 := D(0.04687499995)+y*(D(-0.2002690873E-3)+y*(D(0.8449199096E-5)
                +y*(D(-0.88228987E-6)+y*D(0.105787412E-6))));
         bessJ1 := S(SqrtDD(D(0.636619772)/ax)*(CosDD(xx)*store1-z*SinDD(xx)*store2));
         IF x < 0.0 THEN
            bessJ1 := -bessJ1;
         END;
      END;
      RETURN bessJ1;
   END BessJ1;

   PROCEDURE BessY(n: INTEGER;
                  x: REAL): REAL;
      VAR
         by, bym, byp, tox: REAL;
         j: INTEGER;
   BEGIN
      IF n < 2 THEN
         Error('BessY', 'index n less than 2');
      END;
      tox := 2.0/x;
      by := BessY1(x); (* Starting values for the recurrence. *)
      bym := BessY0(x);
      FOR j := 1 TO n-1 DO (* Recurrence (6.4.7). *)
         byp := Float(j)*tox*by-bym;
         bym := by; 
         by := byp
      END; 
      RETURN by; 
   END BessY;

   PROCEDURE BessY0(x: REAL): REAL; 
      VAR 
         xx, z, y, 
         store1, store2, bessY0: LongReal; (* We'll accumulate polynomials in double precision. *)
   BEGIN 
      IF x < 8.0 THEN (* Rational function approximation
                         of (6.4.8). *)
         z := D(x);
         y := z*z;
         store1 := D(-2957821389.0)+y*(D(7062834065.0)+y*(D(-512359803.6)
                +y*(D(10879881.29)+y*(D(-86327.92757)+y*D(228.4622733)))));
         store2 := D(40076544269.0)+y*(D(745249964.8)+y*(D(7189466.438)
                +y*(D(47447.26470)+y*(D(226.1030244)+y*D(1.0))))); 
         bessY0 := store1/store2+D(0.636619772)*D(BessJ0(x))*LnSD(x);
      ELSE (* Fitting function (6.4.10). *)
         z := D(8.0)/D(x); 
         y := z*z; 
         xx := D(x)-D(0.785398164); 
         store1 := D(1.0)+y*(D(-0.1098628627E-2)+y*(D(0.2734510407E-4)
                  +y*(D(-0.2073370639E-5)+y*D(0.2093887211E-6)))); 
         store2 := D(-0.1562499995E-1)+y*(D(0.1430488765E-3)
                  +y*(D(-0.6911147651E-5)+y*(D(0.7621095161E-6)
                  +y*(D(-0.934945152E-7))))); 
         bessY0 := SinDD(xx)*store1+z*CosDD(xx)*store2; 
         bessY0 := SqrtDD(D(0.636619772)/D(x))*bessY0
      END; 
      RETURN S(bessY0);
   END BessY0;

   PROCEDURE BessY1(x: REAL): REAL; 
      VAR 
         xx, z, y, 
         store1, store2: LongReal; (* We'll accumulate polynomials in double precision. *)
         bessY1: REAL; 
   BEGIN 
      IF x < 8.0 THEN (* Rational function approximation of (6.4.8). *)
         z := D(x);
         y := z*z;
         store1 := D(x)*(D(-0.4900604943E13)+y*(D(0.1275274390E13)
                  +y*(D(-0.5153438139E11)+y*(D(0.7349264551E9)
                  +y*(D(-0.4237922726E7)+y*D(0.8511937935E4))))));
         store2 := D(0.2499580570E14)+y*(D(0.4244419664E12)
                  +y*(D(0.3733650367E10)+y*(D(0.2245904002E8)
                  +y*(D(0.1020426050E6)+y*(D(0.3549632885E3)+y*D(1.0)))))); 
         bessY1 := S(store1/store2+D(0.636619772)
                 *(D(BessJ1(x))*LnSD(x)-D(1.0)/D(x)));
      ELSE (* Fitting function (6.4.10). *)
         z := D(8.0)/D(x);
         y := z*z;
         xx := D(x)-D(2.356194491);
         store1 := D(1.0)+y*(D(0.183105E-2)+y*(D(-0.3516396496E-4)
                +y*(D(0.2457520174E-5)+y*(D(-0.240337019E-6))))); 
         store2 := D(0.04687499995)+y*(D(-0.2002690873E-3)
                  +y*(D(0.8449199096E-5)+y*(D(-0.88228987E-6)
                  +y*D(0.105787412E-6)))); 
         bessY1 := S(SqrtDD(D(0.636619772)/D(x))
                  *(SinDD(xx)*store1+z*CosDD(xx)*store2));
      END; 
      RETURN bessY1
   END BessY1;

END Bessel.
