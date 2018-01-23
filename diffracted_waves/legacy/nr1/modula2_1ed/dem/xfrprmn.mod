MODULE XFRPRMn; (* driver for routine FRPRMn *) 

   FROM Bessel   IMPORT BessJ0, BessJ1;
   FROM ConjGrad IMPORT FRPRMn;
   FROM NRMath   IMPORT Sin, Cos;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      ndim = 3; 
      ftol = 1.0E-6; 
      pio2 = 1.5707963; 
   VAR 
      angl, fret: REAL; 
      iter, k: INTEGER; 
      P: Vector;
      p: PtrToReals; 
       
   PROCEDURE fnc(X: Vector): REAL; 
      VAR 
         n: INTEGER;
         x: PtrToReals;
   BEGIN 
      GetVectorAttr(X, n, x);
      RETURN 1.0-BessJ0(x^[0]-0.5)*BessJ0(x^[1]-0.5)*BessJ0(x^[2]-0.5); 
   END fnc; 

   PROCEDURE dfnc(X, DF: Vector); 
      VAR 
         n: INTEGER;
         x, df: PtrToReals;
   BEGIN 
      GetVectorAttr(X, n, x);
      GetVectorAttr(DF, n, df);
      df^[0] := BessJ1(x^[0]-0.5)*BessJ0(x^[1]-0.5)*BessJ0(x^[2]-0.5); 
      df^[1] := BessJ0(x^[0]-0.5)*BessJ1(x^[1]-0.5)*BessJ0(x^[2]-0.5); 
      df^[2] := BessJ0(x^[0]-0.5)*BessJ0(x^[1]-0.5)*BessJ1(x^[2]-0.5)
   END dfnc; 
    
BEGIN 
   CreateVector(ndim, P, p);
   IF P # NilVector THEN
	   WriteString('Program finds the minimum of a function'); WriteLn; 
	   WriteString('with different trial starting vectors.'); WriteLn; 
	   WriteString('TRUE minimum is (0.5,0.5,0.5)'); WriteLn; 
	   FOR k := 0 TO 4 DO 
	      angl := pio2*Float(k)/4.0; 
	      p^[0] := 2.0*Cos(angl); 
	      p^[1] := 2.0*Sin(angl); 
	      p^[2] := 0.0; 
	      WriteString('Starting vector: ('); 
	      WriteReal(p^[0], 7, 4); 
	      WriteString(','); 
	      WriteReal(p^[1], 7, 4); 
	      WriteString(','); 
	      WriteReal(p^[2], 7, 4); 
	      WriteString(')'); 
	      WriteLn; 
	      FRPRMn(P, ftol, fnc, dfnc, iter, fret); 
	      WriteString('Iterations:'); 
	      WriteInt(iter, 3); 
	      WriteLn; 
	      WriteString('Solution vector: ('); 
	      WriteReal(p^[0], 7, 4); 
	      WriteString(','); 
	      WriteReal(p^[1], 7, 4); 
	      WriteString(','); 
	      WriteReal(p^[2], 7, 4); 
	      WriteString(')'); 
	      WriteLn; 
	      WriteString('Func. value at solution'); 
	      WriteReal(fret, 14, -10); 
	      WriteLn
	   END;
	   ReadLn;
	   DisposeVector(P)
	ELSE
	   Error('XFRPRMn', 'Not enough memory.');
	END;
END XFRPRMn.
