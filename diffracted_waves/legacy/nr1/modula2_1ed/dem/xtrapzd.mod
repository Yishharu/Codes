MODULE XTrapzd; (* driver for routine trapzd *) 

   FROM IntElem IMPORT Trapzd;
   FROM NRMath  IMPORT Sin, Cos;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString;

   CONST 
      nmax = 14; 
      pio2 = 1.5707963; 
   VAR 
      TrapzdIt: INTEGER; 
      i: INTEGER; 
      a, b, s: REAL; 

   PROCEDURE func(x: REAL): REAL;    (* Test function *)
   BEGIN 
      RETURN (x*x)*((x*x)-2.0)*Sin(x); 
   END func; 
   
   PROCEDURE fint(x: REAL): REAL;    (* Integral of test function *) 
   BEGIN 
      RETURN 4.0*x*((x*x)-7.0)*Sin(x)-(((x*x)*(x*x))-14.0*(x*x)+28.0)*Cos(x); 
   END fint; 
    
BEGIN 
   a := 0.0; 
   b := pio2; 
   WriteString('integral of func with 2^(n-1) points'); 
   WriteLn; 
   WriteString('actual value of integral is'); 
   WriteReal(fint(b)-fint(a), 12, 6); 
   WriteLn; 
   WriteString('      n'); 
   WriteString('        approx. integral'); 
   WriteLn; 
   FOR i := 1 TO nmax DO 
      Trapzd(func, a, b, s, i); 
      WriteInt(i, 6); 
      WriteReal(s, 20, 6); 
      WriteLn
   END;
   ReadLn;
END XTrapzd.
