MODULE XMidPnt; (* driver for routine MidPnt *) 
   
   FROM IntImpr  IMPORT MidPnt;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT LongReal;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString;

   CONST 
      nmax = 10; 
   VAR 
      a, b, s: REAL; 
      i, MidpntIt: INTEGER; 
    
   PROCEDURE func(x: REAL): REAL;    (* Function for testing integration *)
   BEGIN 
      RETURN 1.0/Sqrt(x); 
   END func; 
    
   PROCEDURE fint(x: REAL): REAL;    (* Integral of 'func' *)
   BEGIN 
      RETURN 2.0*Sqrt(x); 
   END fint; 
    
BEGIN 
   a := 0.0; 
   b := 1.0; 
   WriteLn; 
   WriteString('Integral of func computed with MIDPNT'); 
   WriteLn; 
   WriteString('Actual value of integral is'); 
   WriteReal((fint(b)-fint(a)), 7, 4); 
   WriteLn; 
   WriteString('     n'); 
   WriteString('             Approx. integral'); 
   WriteLn; 
   FOR i := 1 TO nmax DO 
      MidPnt(func, a, b, s, i); 
      WriteInt(i, 6); 
      WriteReal(s, 24, 6); 
      WriteLn
   END;
   ReadLn;
END XMidPnt.
