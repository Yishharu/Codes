MODULE XBrent; (* driver for routine Brent *) 
 
   FROM Bessel   IMPORT BessJ0, BessJ1;
   FROM BrentM   IMPORT Brent;
   FROM GoldenM  IMPORT MnBrak;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;

   CONST 
      tol = 1.0E-6; 
      eql = 1.0E-4; 
   TYPE 
      RealArray20 = ARRAY [1..20] OF REAL; 
   VAR 
      ax, bx, cx, fa, fb, fc, xmin, bren: REAL; 
      i, iflag, j, nmin: INTEGER; 
      amin: RealArray20; 
    
BEGIN 
   nmin := 0; 
   WriteLn; 
   WriteString('minima of the function BessJ0'); 
   WriteLn; 
   WriteString('    min. #'); 
   WriteString('       x'); 
   WriteString('        BessJ0(x)'); 
   WriteString('   BessJ1(x)'); 
   WriteLn; 
   FOR i := 1 TO 100 DO 
      ax := Float(i); 
      bx := Float(i)+1.0; 
      MnBrak(ax, bx, cx, fa, fb, fc, BessJ0); 
      bren := Brent(ax, bx, cx, BessJ0, tol, xmin); 
      IF nmin = 0 THEN 
         amin[1] := xmin; 
         nmin := 1; 
         WriteInt(nmin, 7); 
         WriteReal(xmin, 15, 6); 
         WriteReal(BessJ0(xmin), 12, 6); 
         WriteReal(BessJ1(xmin), 12, 6); 
         WriteLn;
      ELSE
         iflag := 0;
         FOR j := 1 TO nmin DO
            IF ABS(xmin-amin[j]) <= eql*xmin THEN
               iflag := 1;
            END;
         END;
         IF iflag = 0 THEN
            nmin := nmin+1;
            amin[nmin] := xmin;
	         WriteInt(nmin, 7); 
	         WriteReal(xmin, 15, 6); 
	         WriteReal(BessJ0(xmin), 12, 6); 
	         WriteReal(BessJ1(xmin), 12, 6); 
	         WriteLn;
         END
      END;
   END;
   ReadLn;
END XBrent.
