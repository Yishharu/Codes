MODULE XQSimp; (* driver for routine QSimp *) 

   FROM IntElem  IMPORT QSimp;
   FROM NRMath   IMPORT Sin, Cos;
   FROM NRSystem IMPORT LongReal;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString;

   CONST 
      pio2 = 1.5707963; 
   VAR 
      TrapzdIt: INTEGER; 
      a, b, s: REAL; 
    
   PROCEDURE func(x: REAL): REAL;    (* Test function *)
   BEGIN 
      RETURN (x*x)*(x*x-2.0)*Sin(x); 
   END func; 
    
   PROCEDURE fint(x: REAL): REAL;    (* Integral of test function *)
   BEGIN 
      RETURN 4.0*x*((x*x)-7.0)*Sin(x)-(((x*x)*(x*x))-14.0*(x*x)+28.0)*Cos(x); 
   END fint; 
    
BEGIN 
   a := 0.0; 
   b := pio2; 
   WriteString('Integral of func computed with QSimp'); 
   WriteLn; 
   WriteLn; 
   WriteString('Actual value of integral is'); 
   WriteReal(fint(b)-fint(a), 12, 6); 
   WriteLn; 
   QSimp(func, a, b, s); 
   WriteString('Result from routine QSimp is'); 
   WriteReal(s, 12, 6); 
   WriteLn;
   ReadLn;
END XQSimp.
