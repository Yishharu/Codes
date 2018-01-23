MODULE XQRomo; (* Driver for routine QRomo *) 
 
   FROM IntImpr IMPORT QRomo;
   FROM NRMath IMPORT Sqrt, Sin;
   FROM NRSystem IMPORT LongReal;
   FROM NRIO IMPORT ReadLn, WriteLn, WriteReal, WriteString;

   CONST 
      x1 = 0.0; 
      x2 = 1.5707963; 
      n = 5; 
   VAR 
      MidsqlIt: INTEGER; 
      result:   REAL; 

   PROCEDURE func(x: REAL): REAL; 
   BEGIN 
      RETURN Sqrt(x)/Sin(x); 
   END func; 
    
BEGIN 
   WriteString('Improper integral:'); 
   WriteLn; 
   WriteLn; 
   QRomo(func, x1, x2, result); 
   WriteString('Function: Sqrt(x)/Sin(x)       Interval: (0,pi/2)'); 
   WriteLn; 
   WriteString('Using: MIDSQL                  Result:'); 
   WriteReal(result, 8, 4); 
   WriteLn; 
   ReadLn;
END XQRomo.
