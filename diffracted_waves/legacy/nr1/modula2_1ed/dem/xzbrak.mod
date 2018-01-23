MODULE XZBrak; (* driver for routine ZBrak *) 
 
   FROM Bessel IMPORT BessJ0;
   FROM BraBis IMPORT ZBrak;
   FROM NRIO   IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, NilVector;

   CONST 
      n = 100; 
      nbmax = 20; 
      x1 = 1.0; 
      x2 = 50.0; 
   VAR 
      i, nb: INTEGER; 
      XB1, XB2: Vector; 
      xb1, xb2: PtrToReals; 
       
BEGIN 
   nb := nbmax; 
   CreateVector(nb, XB1, xb1);
   CreateVector(nb, XB2, xb2);
   IF (XB1 # NilVector) AND (XB2 # NilVector) THEN
	   ZBrak(BessJ0, x1, x2, n, XB1, XB2, nb); 
	   WriteLn; 
	   WriteString('brackets for roots of bessj0:'); 
	   WriteLn; 
	   WriteString('                  lower'); 
	   WriteString('     upper'); 
	   WriteString('        f(lower)'); 
	   WriteString('  f(upper)'); 
	   WriteLn; 
	   FOR i := 0 TO nb DO 
	      WriteString('  root '); 
	      WriteInt(i+1, 2); 
	      WriteString('    '); 
	      WriteReal(xb1^[i], 10, 4); 
	      WriteReal(xb2^[i], 10, 4); 
	      WriteString('    '); 
	      WriteReal(BessJ0(xb1^[i]), 10, 4); 
	      WriteReal(BessJ0(xb2^[i]), 10, 4); 
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('XZBrak', 'Not enough memory.');
	END;
	IF (XB1 # NilVector) THEN DisposeVector(XB1) END;
	IF (XB2 # NilVector) THEN DisposeVector(XB2) END;
END XZBrak.
