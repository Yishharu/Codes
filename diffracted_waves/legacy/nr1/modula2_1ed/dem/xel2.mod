MODULE XEL2; (* Driver for routine EL2 *) 

   FROM Uniform  IMPORT Ran3;
   FROM IntElem  IMPORT QSimp;
   FROM Elliptic IMPORT El2;
   FROM NRMath   IMPORT Sqrt, Sin, Cos, ArcTan;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;
           
   TYPE 
      RealArray55 = ARRAY [1..55] OF REAL;
   VAR 
      TrapzdIt: INTEGER; 
      Ran3Inext, Ran3Inextp: INTEGER; 
      Ran3Ma: RealArray55; 
      FuncA, FuncB, FuncAkc: REAL; 
      ago, astop, s, x: REAL; 
      i, idum: INTEGER; 

   (* Programs using routine func must declare the variables
   VAR
      FuncAkc, FuncA, FuncB: real;
   in the main routine, and must assign their values. *) 

   PROCEDURE func(phi: REAL): REAL; 
      VAR 
         tn, tsq: REAL; 
   BEGIN 
      tn := Sin(phi)/Cos(phi); 
      tsq := tn*tn; 
      RETURN (FuncA+FuncB*tsq)/Sqrt((1.0+tsq)*(1.0+FuncAkc*FuncAkc*tsq)); 
   END func; 
    
BEGIN 
   WriteString('general elliptic integral of second kind'); 
   WriteLn; 
   WriteString('      x        kc         a'); 
   WriteString('         b        el2    integral'); 
   WriteLn; 
   idum := -55; 
   ago := 0.0; 
   FOR i := 1 TO 20 DO 
      FuncAkc := 5.0*Ran3(idum); 
      FuncA := 10.0*Ran3(idum); 
      FuncB := 10.0*Ran3(idum); 
      x := 10.0*Ran3(idum); 
      astop := ArcTan(x); 
      QSimp(func, ago, astop, s); 
      WriteReal(x, 10, 6); 
      WriteReal(FuncAkc, 10, 6); 
      WriteReal(FuncA, 10, 6); 
      WriteReal(FuncB, 10, 6); 
      WriteReal(El2(x, FuncAkc, FuncA, FuncB), 10, 6);
      WriteReal(s, 10, 6);
      WriteLn;
   END;
   ReadLn;
END XEL2.
