MODULE XMnBrak; (* driver for routine MnBrak *) 
   
   FROM Bessel   IMPORT BessJ0;
   FROM GoldenM  IMPORT MnBrak;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;

   VAR 
      ax, bx, cx, fa, fb, fc: REAL; 
      i: INTEGER; 
       
BEGIN 
   FOR i := 1 TO 10 DO 
      ax := Float(i)*0.5; 
      bx := (Float(i)+1.0)*0.5; 
      MnBrak(ax, bx, cx, fa, fb, fc, BessJ0); 
      WriteString('             a');
      WriteString('           b'); 
      WriteString('           c'); 
      WriteLn; 
      WriteString('  x  '); 
      WriteReal(ax, 12, 6); 
      WriteReal(bx, 12, 6); 
      WriteReal(cx, 12, 6); 
      WriteLn; 
      WriteString('  f  '); 
      WriteReal(fa, 12, 6); 
      WriteReal(fb, 12, 6); 
      WriteReal(fc, 12, 6); 
      WriteLn
   END;
   ReadLn;
END XMnBrak.
