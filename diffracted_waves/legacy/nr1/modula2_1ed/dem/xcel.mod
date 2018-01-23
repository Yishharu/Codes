MODULE XCEl; (* Driver for routine CEl *) 

   FROM Elliptic IMPORT CEl;
   FROM Uniform  IMPORT Ran3;
   FROM QRombM   IMPORT QRomb;
   FROM NRMath   IMPORT Sqrt, Cos;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;

   CONST 
      pio2 = 1.5707963; 
      n = 5; 
   TYPE 
      RealArray55 = ARRAY [1..55] OF REAL; 
      RealArrayNP = ARRAY [1..n] OF REAL;    
   VAR 
      TrapzdIt: INTEGER; 
      Ran3Inext, Ran3Inextp: INTEGER; 
      Ran3Ma: RealArray55; 
      FuncA, FuncB, FuncP, FuncAkc: REAL; 
      ago, astop, s: REAL; 
      i, idum: INTEGER; 

   PROCEDURE func(phi: REAL): REAL; 
      VAR 
         cs, csq, ssq: REAL; 
         funcResult: REAL; 
   BEGIN 
      cs := Cos(phi); 
      csq := cs*cs; 
      ssq := 1.0-csq; 
      funcResult := (FuncA*csq+FuncB*ssq)/(csq+FuncP*ssq)/Sqrt(csq+FuncAkc*FuncAkc*ssq); 
      RETURN funcResult
   END func; 
    
BEGIN 
   WriteString('Complete elliptic integral'); 
   WriteLn; 
   WriteString('     kc         p         a'); 
   WriteString('         b       cel    integral'); 
   WriteLn; 
   idum := -55; 
   ago := 0.0; 
   astop := pio2; 
   FOR i := 1 TO 20 DO 
      FuncAkc := 0.1+Ran3(idum); 
      FuncA := 10.0*Ran3(idum); 
      FuncB := 10.0*Ran3(idum); 
      FuncP := 0.1+Ran3(idum); 
      QRomb(func, ago, astop, s); 
      WriteReal(FuncAkc, 10, 6); 
      WriteReal(FuncP, 10, 6); 
      WriteReal(FuncA, 10, 6); 
      WriteReal(FuncB, 10, 6); 
      WriteReal(CEl(FuncAkc, FuncP, FuncA, FuncB), 10, 6);
      WriteReal(s, 10, 6);
      WriteLn;
   END;
   ReadLn;
END XCEl.
