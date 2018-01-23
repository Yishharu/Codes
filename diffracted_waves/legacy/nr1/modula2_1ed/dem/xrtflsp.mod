MODULE XRtFlsp; (* driver for routine RtFlsp *) 

   FROM Bessel IMPORT BessJ0;
   FROM BraBis IMPORT ZBrak;
   FROM FlspSc IMPORT RtFlsp;
   FROM NRIO   IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, NilVector;

   CONST 
      n = 100; 
      nbmax = 20; 
      x1 = 1.0; 
      x2 = 50.0; 
   VAR 
      i, nb: INTEGER; 
      root, xacc: REAL; 
      XB1, XB2: Vector;
      xb1, xb2: PtrToReals; 
       
BEGIN 
   nb := nbmax; 
   CreateVector(nb, XB1, xb1);
   CreateVector(nb, XB2, xb2);
   IF (XB1 # NilVector) AND (XB2 # NilVector) THEN
	   ZBrak(BessJ0, x1, x2, n, XB1, XB2, nb); 
	   WriteLn; 
	   WriteString('roots of bessj0:'); 
	   WriteLn; 
	   WriteString('                   x'); 
	   WriteString('           f(x)'); 
	   WriteLn; 
	   FOR i := 0 TO nb DO 
	      xacc := (1.0E-6)*(xb1^[i]+xb2^[i])/2.0; 
	      root := RtFlsp(BessJ0, xb1^[i], xb2^[i], xacc); 
	      WriteString('  root '); 
	      WriteInt(i+1, 2); 
	      WriteString('  '); 
	      WriteReal(root, 12, 6); 
	      WriteReal(BessJ0(root), 14, 6); 
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('XRtFlsp', 'Not enough memory.');
	END;
	IF (XB1 # NilVector) THEN DisposeVector(XB1) END;
	IF (XB2 # NilVector) THEN DisposeVector(XB2) END;
END XRtFlsp.
