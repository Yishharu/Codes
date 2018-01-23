MODULE XDBrent; (* driver for routine DBrent *) 

   FROM Bessel   IMPORT BessJ0, BessJ1;
   FROM DBrentM  IMPORT DBrent;
   FROM GoldenM  IMPORT MnBrak;
   FROM NRMath   IMPORT RealFunction;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;

   CONST 
      tol = 1.0E-6; 
      eql = 1.0E-4; 
   TYPE 
      RealArray20 = ARRAY [1..20] OF REAL; 
   VAR 
      ax, bx, cx, fa, fb, fc, xmin, dbr: REAL; 
      i, iflag, j, nmin: INTEGER; 
      amin: RealArray20; 
       
   PROCEDURE dfunc(x: REAL): REAL; 
   BEGIN 
      RETURN -BessJ1(x); 
   END dfunc; 
    
BEGIN 
   nmin := 0; 
   WriteLn; 
   WriteString('minima of the function BessJ0'); 
   WriteLn; 
   WriteString('    min. #'); 
   WriteString('       x'); 
   WriteString('       BessJ0(x)'); 
   WriteString('   BessJ1(x)'); 
   WriteString('     DBRENT'); 
   WriteLn; 
   FOR i := 1 TO 100 DO 
      ax := Float(i); 
      bx := Float(i)+1.0; 
      MnBrak(ax, bx, cx, fa, fb, fc, BessJ0); 
      dbr := DBrent(ax, bx, cx, BessJ0, dfunc, tol, xmin); 
      IF nmin = 0 THEN 
         amin[1] := xmin; 
         nmin := 1; 
         WriteInt(nmin, 7); 
         WriteReal(xmin, 15, 6); 
         WriteReal(BessJ0(xmin), 12, 6); 
         WriteReal(dfunc(xmin), 12, 6); 
         WriteReal(dbr, 12, 6); 
         WriteLn; 
      ELSE 
         iflag := 0; 
         FOR j := 1 TO nmin DO 
            IF ABS(xmin-amin[j]) <= eql*xmin THEN 
               iflag := 1
            END
         END; 
         IF iflag = 0 THEN 
            INC(nmin, 1); 
            amin[nmin] := xmin; 
            WriteInt(nmin, 7); 
            WriteReal(xmin, 15, 6); 
            WriteReal(BessJ0(xmin), 12, 6); 
            WriteReal(dfunc(xmin), 12, 6); 
            WriteReal(dbr, 12, 6); 
            WriteLn
         END
      END
   END;
   ReadLn;
END XDBrent.
