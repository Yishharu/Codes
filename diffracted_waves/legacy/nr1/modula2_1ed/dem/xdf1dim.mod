MODULE XDF1Dim; (* driver for routine DF1DIM *) 

   FROM ConjGrad IMPORT DF1Dim;
   FROM SCRSHOM  IMPORT SCRSHO;
   FROM NRIO     IMPORT ReadLn,  ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      ndim = 3; 
   VAR 
      i, j, LinminNcom: INTEGER; 
      P, XI, LinminPcom, LinminXicom: Vector;
      p, xi, linminPcom, linminXicom: PtrToReals; 

  PROCEDURE dfnc(X, DF: Vector); 
      VAR 
         i, n, m: INTEGER;
         x, df: PtrToReals;
   BEGIN 
      GetVectorAttr(X, n, x);
      GetVectorAttr(DF, m, df);
      FOR i := 0 TO 2 DO 
         df^[i] := (x^[i]-1.0)*(x^[i]-1.0)
      END
   END dfnc; 
    
   PROCEDURE fx(x: REAL): REAL; 
   BEGIN 
      RETURN DF1Dim(x, LinminPcom, LinminXicom, dfnc); 
   END fx; 
    
BEGIN 
   CreateVector(ndim, P, p);
   CreateVector(ndim, XI, xi);
   CreateVector(ndim, LinminPcom, linminPcom);
   CreateVector(ndim, LinminXicom, linminXicom);
   IF (P # NilVector) AND (XI # NilVector) AND (LinminPcom # NilVector) AND 
      (LinminXicom # NilVector) THEN
	   p^[0] := 0.0; 
	   p^[1] := 0.0; 
	   p^[2] := 0.0; 
	   WriteLn; 
	   WriteString('Enter vector direction along which to'); WriteLn; 
	   WriteString('plot the function. Minimum is in the'); WriteLn; 
	   WriteString('direction 1.0 1.0 1.0 - enter x y z:'); WriteLn; 
	   ReadReal('x:', xi^[0]); 
	   ReadReal('y:', xi^[1]); 
	   ReadReal('z:', xi^[2]); 
	   WriteLn; 
	   FOR j := 0 TO ndim-1 DO 
	      linminPcom^[j] := p^[j]; 
	      linminXicom^[j] := xi^[j]
	   END; 
	   SCRSHO(fx);
	   ReadLn;
	ELSE
	   Error('XDF1Dim', 'Not enough memory.');
	END;
	IF P # NilVector THEN DisposeVector(P); END;
	IF XI # NilVector THEN DisposeVector(XI); END;
	IF LinminPcom # NilVector THEN DisposeVector(LinminPcom); END;
	IF LinminXicom # NilVector THEN DisposeVector(LinminXicom); END;
END XDF1Dim.
