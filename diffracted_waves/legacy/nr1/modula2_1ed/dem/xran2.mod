MODULE XRan2; (* driver for routine Ran2 *) 
              (* calculates Pi statistically using volume of unit n-sphere *)

   FROM Uniform  IMPORT Ran2;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT LongInt, Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteString, WriteInt, WriteReal;

   CONST 
      Pi = 3.1415926; 
   TYPE 
      IntegerArray3 = ARRAY [1..3] OF INTEGER; 
      RealArray3 = ARRAY [1..3] OF REAL; 
      RealArray97 = ARRAY [1..97] OF REAL; 
   VAR 
      i, j, k, jPower: INTEGER; 
      idum: LongInt;
      x1, x2, x3, x4: REAL; 
      iy: IntegerArray3; 
      yprob: RealArray3; 
      Ran2Y: REAL; 
      Ran2V: RealArray97; 

   PROCEDURE Fnc(x1, x2, x3, x4: REAL): REAL; 
   BEGIN 
      RETURN Sqrt(x1*x1 + x2*x2 + x3*x3 + x4*x4); 
   END Fnc; 

   PROCEDURE twoToj(j: INTEGER): INTEGER; 
   BEGIN 
      IF j = 0 THEN 
         RETURN 1
      ELSE 
         RETURN 2*twoToj(j-1)
      END; 
   END twoToj; 
    
BEGIN 
   idum := -1; 
   FOR i := 1 TO 3 DO 
      iy[i] := 0
   END; 
   WriteLn; 
   WriteString('volume of unit n-sphere, n = 2,3,4'); 
   WriteLn; 
   WriteString('# points     Pi       (4/3)*Pi   (1/2)*Pi^2 '); 
   WriteLn; 
   WriteLn; 
   FOR j := 1 TO 13 DO 
      FOR k := twoToj(j-1) TO twoToj(j) DO 
         x1 := Ran2(idum); 
         x2 := Ran2(idum); 
         x3 := Ran2(idum); 
         x4 := Ran2(idum); 
         IF Fnc(x1, x2, 0.0, 0.0) < 1.0 THEN 
            iy[1] := iy[1]+1
         END; 
         IF Fnc(x1, x2, x3, 0.0) < 1.0 THEN 
            iy[2] := iy[2]+1
         END; 
         IF Fnc(x1, x2, x3, x4) < 1.0 THEN 
            iy[3] := iy[3]+1
         END
      END; 
      jPower := twoToj(j); 
      yprob[1] := 4.0*Float(iy[1])/Float(jPower); 
      yprob[2] := 8.0*Float(iy[2])/Float(jPower); 
      yprob[3] := 16.0*Float(iy[3])/Float(jPower); 
      WriteInt(jPower, 6); 
      WriteReal(yprob[1], 12, 6); 
      WriteReal(yprob[2], 12, 6); 
      WriteReal(yprob[3], 12, 6); 
      WriteLn
   END; 
   WriteLn; 
   WriteString('actual'); 
   WriteReal(Pi, 12, 6); 
   WriteReal(4.0*Pi/3.0, 12, 6); 
   WriteReal(0.5*(Pi*Pi), 12, 6); 
   WriteLn;
   ReadLn;
END XRan2.
