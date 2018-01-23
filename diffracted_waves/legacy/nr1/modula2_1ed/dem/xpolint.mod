MODULE XPolInt; (* driver for routine PolInt *) 

   FROM PolIntM  IMPORT PolInt;
   FROM NRMath   IMPORT Exp, Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, ReadInt, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector;

   CONST
      pi = 3.1415926; 
   VAR 
      i, n, nfunc: INTEGER; 
      dy, f, x, y: REAL; 
      XA, YA: Vector; 
      xa, ya: PtrToReals; 
       
BEGIN 
   WriteString('generation of interpolation tables'); WriteLn; 
   WriteString(' ... Sin(x)   0<x<pi'); WriteLn; 
   WriteString(' ... Exp(x)   0<x<1 '); WriteLn; 
   WriteString('how many entries go in these tables(note: n<=10)'); WriteLn; 
   ReadInt('n:', n); 
   CreateVector(n, XA, xa);
   CreateVector(n, YA, ya);
   IF (XA # NilVector) AND (YA # NilVector) THEN
	   FOR nfunc := 1 TO 2 DO 
	      WriteLn; 
	      IF nfunc = 1 THEN 
	         WriteString('sine function from 0 to pi'); WriteLn; 
	         FOR i := 0 TO n-1 DO 
	            xa^[i] := Float(i+1)*pi/Float(n); 
	            ya^[i] := Sin(xa^[i])
	         END; 
	      ELSIF nfunc = 2 THEN 
	         WriteString('exponential function from 0 to 1'); 
	         WriteLn; 
	         FOR i := 0 TO n-1 DO 
	            xa^[i] := Float(i+1)*1.0/Float(n); 
	            ya^[i] := Exp(xa^[i])
	         END; 
	      END; 
	      WriteLn; 
	      WriteString('        x'); 
	      WriteString('         f(x)'); 
	      WriteString('    interpolated'); 
	      WriteString('      error'); 
	      WriteLn; 
	      FOR i := 1 TO 10 DO 
	         IF nfunc = 1 THEN 
	            x := (-0.05+Float(i)/10.0)*pi; 
	            f := Sin(x)
	         ELSIF nfunc = 2 THEN 
	            x := -0.05+Float(i)/10.0; 
	            f := Exp(x)
	         END; 
	         PolInt(XA, YA, x, y, dy); 
	         WriteReal(x, 12, 6); 
	         WriteReal(f, 12, 6); 
	         WriteReal(y, 12, 6); 
	         WriteString('    '); 
	         WriteReal(dy, 12, -10); 
	         WriteLn
	      END; 
	      WriteLn; 
	      WriteString('***********************************'); 
	      WriteLn; 
	      WriteString('press RETURN'); 
	      WriteLn; 
	      ReadLn
	   END;
	ELSE
	   Error('XPolInt', 'Not enough memory.');
	END;
	IF (XA # NilVector) THEN DisposeVector(XA); END;
	IF (YA # NilVector) THEN DisposeVector(YA); END;
END XPolInt.
