MODULE XFGauss; (* driver for routine FGAUSS *) 
 
   FROM NonLin   IMPORT FGauss;
   FROM NRSystem IMPORT Float;
   FROM NRMath   IMPORT Exp;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      npt = 3; 
      nlin = 2; 
      ma = 6; (* ma=3*nlin *) 
   VAR 
      e1, e2, f, x, y: REAL; 
      i, j: INTEGER; 
      A, DYDA, DF: Vector;
      a, dyda, df: PtrToReals; 
       
BEGIN 
   CreateVector(ma, A, a);
   CreateVector(ma, DYDA, dyda);
   CreateVector(ma, DF, df);
   IF (A # NilVector) AND (DYDA # NilVector) AND (DF # NilVector) THEN
	   a^[0] := 3.0; 
	   a^[1] := 0.2; 
	   a^[2] := 0.5; 
	   a^[3] := 1.0; 
	   a^[4] := 0.7; 
	   a^[5] := 0.3; 
	   WriteLn; 
	   WriteString('     x       y    dyda1   dyda2'); 
	   WriteString('   dyda3   dyda4   dyda5   dyda6');  WriteLn; 
	   FOR i := 1 TO npt DO 
	      x := 0.3*Float(i); 
	      FGauss(x, A, y, DYDA); 
	      e1 := Exp(-(x-a^[1])/a^[2]*(x-a^[1])/a^[2]); 
	      e2 := Exp(-(x-a^[4])/a^[5]*(x-a^[4])/a^[5]); 
	      f := a^[0]*e1+a^[3]*e2; 
	      df^[0] := e1; 
	      df^[3] := e2; 
	      df^[1] := a^[0]*e1*2.0*(x-a^[1])/(a^[2]*a^[2]); 
	      df^[4] := a^[3]*e2*2.0*(x-a^[4])/(a^[5]*a^[5]); 
	      df^[2] := a^[0]*e1*2.0*((x-a^[1])*(x-a^[1]))/(a^[2]*a^[2]*a^[2]); 
	      df^[5] := a^[3]*e2*2.0*((x-a^[4])*(x-a^[4]))/(a^[5]*a^[5]*a^[5]); 
	      WriteString('from FGAUSS'); 
	      WriteLn; 
	      WriteReal(x, 8, 4); 
	      WriteReal(y, 8, 4); 
	      FOR j := 0 TO 5 DO 
	         WriteReal(dyda^[j], 8, 4)
	      END; 
	      WriteLn; 
	      WriteString('independent calc.'); 
	      WriteLn; 
	      WriteReal(x, 8, 4); 
	      WriteReal(f, 8, 4); 
	      FOR j := 0 TO 5 DO 
	         WriteReal(df^[j], 8, 4)
	      END; 
	      WriteLn; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XFGauss', 'Not enough memory.');
	END;
	IF A # NilVector THEN DisposeVector(A) END;
	IF DYDA # NilVector THEN DisposeVector(DYDA) END;
	IF DF # NilVector THEN DisposeVector(DF) END;
END XFGauss.
