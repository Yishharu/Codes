MODULE XODEInt; (* driver for ODEInt *) 
 
   FROM AccMon IMPORT ODEInt;
   FROM Bessel IMPORT BessJ0, BessJ1, BessJ;
   FROM NRIO   IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                      Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   CONST 
      n = 4; 
   VAR 
      OdeintDxsav, eps, h1, hmin, x1, x2: REAL; 
      i, OdeintKmax, OdeintKount, nbad, nok: INTEGER; 
      YSTART, ODEIntXp: Vector;
      ystart, odeIntXp: PtrToReals; 
      ODEIntYp: Matrix;
      odeIntYp: PtrToLines; 
       
   PROCEDURE derivs(x: REAL; 
                    Y, DYDX: Vector); 
      VAR
         ny, ndydx: INTEGER;
         y, dydx: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      dydx^[0] := -y^[1]; 
      dydx^[1] := y^[0]-(1.0/x)*y^[1]; 
      dydx^[2] := y^[1]-(2.0/x)*y^[2]; 
      dydx^[3] := y^[2]-(3.0/x)*y^[3]
   END derivs; 
    
BEGIN 
   CreateVector(n, YSTART, ystart);
   CreateVector(200, ODEIntXp, odeIntXp);
   CreateMatrix(n, 200, ODEIntYp, odeIntYp);
   IF (YSTART # NilVector) AND (ODEIntXp # NilVector) AND (ODEIntYp # NilMatrix) THEN
	   x1 := 1.0; 
	   x2 := 10.0; 
	   ystart^[0] := BessJ0(x1); 
	   ystart^[1] := BessJ1(x1); 
	   ystart^[2] := BessJ(2, x1); 
	   ystart^[3] := BessJ(3, x1); 
	   eps := 1.0E-4; 
	   h1 := 0.1; 
	   hmin := 0.0; 
	   OdeintKmax := 100; 
	   OdeintDxsav := (x2-x1)/20.0;
	   ODEInt(YSTART,x1, x2, eps, h1, hmin, derivs, OdeintDxsav, OdeintKmax,
	          ODEIntXp, ODEIntYp, OdeintKount, nok, nbad); 
	   WriteLn; 
	   WriteString('successful steps:             '); 
	   WriteInt(nok, 3); 
	   WriteLn; 
	   WriteString('bad steps:                    '); 
	   WriteInt(nbad, 3); 
	   WriteLn; 
	   WriteString('stored intermediate values:   '); 
	   WriteInt(OdeintKount, 3); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('       x          integral     BessJ(3,x)'); 
	   WriteLn; 
	   FOR i := 0 TO OdeintKount-1 DO 
	      WriteReal(odeIntXp^[i], 10, 4); 
	      WriteReal(odeIntYp^[3]^[i], 16, 6); 
	      WriteReal(BessJ(3, odeIntXp^[i]), 12, 6);
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('XMMid', 'Not enough memory.');
	END;
	IF YSTART # NilVector THEN DisposeVector(YSTART) END;
	IF ODEIntXp # NilVector THEN DisposeVector(ODEIntXp) END;
	IF ODEIntYp # NilMatrix THEN DisposeMatrix(ODEIntYp) END;
END XODEInt.
