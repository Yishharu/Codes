MODULE XZBrac; (* driver for routine ZBrac *) 
 
   FROM  BraBis  IMPORT ZBrac;
   FROM Bessel   IMPORT BessJ0;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;

   VAR 
      succes: BOOLEAN; 
      i: INTEGER; 
      x1, x2: REAL; 
       
BEGIN 
   WriteString('   bracketing values:'); 
   WriteString('       function values:'); 
   WriteLn; 
   WriteString('     x1'); 
   WriteString('        x2'); 
   WriteString('         Bessj0(x1)'); 
   WriteString('  Bessj0(x2)'); 
   WriteLn; 
   FOR i := 1 TO 10 DO 
      x1 := Float(i); 
      x2 := x1+1.0; 
      ZBrac(BessJ0, x1, x2, succes); 
      IF succes THEN 
         WriteReal(x1, 7, 2); 
         WriteReal(x2, 10, 2); 
         WriteString('       '); 
         WriteReal(BessJ0(x1), 12, 6); 
         WriteReal(BessJ0(x2), 12, 6); 
         WriteLn
      END
   END;
   ReadLn;
END XZBrac.
