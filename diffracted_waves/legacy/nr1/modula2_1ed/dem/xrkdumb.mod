MODULE XRKDumb; (* driver for routine RKDumb *) 
 
   FROM RKs    IMPORT RKDumb;
   FROM Bessel IMPORT BessJ0, BessJ1, BessJ;
   FROM NRIO   IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                      Error;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                      NilMatrix, PtrToLines;

   CONST 
      nvar = 4; 
      nstep = 150; 
   TYPE 
      RealArrayNVAR = ARRAY [1..nvar] OF REAL; 
      RealArray200 = ARRAY [1..200] OF REAL; 
      RealArrayNVARby200 = ARRAY [1..nvar], [1..200] OF REAL; 
   VAR 
      i, j: INTEGER; 
      x1, x2: REAL; 
      RKDumbX, VSTART: Vector; 
      rkDumbX, vstart: PtrToReals;
      RKDumbY: Matrix; 
      rkDumbY: PtrToLines;
       
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
   CreateVector(nvar, VSTART, vstart);
   CreateVector(200, RKDumbX, rkDumbX);
   CreateMatrix(nvar, 200, RKDumbY, rkDumbY);
   IF (VSTART # NilVector) AND (RKDumbX # NilVector) AND (RKDumbY # NilMatrix) THEN
	   x1 := 1.0; 
	   vstart^[0] := BessJ0(x1); 
	   vstart^[1] := BessJ1(x1); 
	   vstart^[2] := BessJ(2, x1); 
	   vstart^[3] := BessJ(3, x1); 
	   x2 := 20.0; 
	   RKDumb(VSTART, x1, x2, nstep, derivs, RKDumbX, RKDumbY); 
	   WriteString('       x       integrated    BessJ3'); 
	   WriteLn; 
	   FOR i := 1 TO nstep DIV 10 DO 
	      j := 10*i; 
	      WriteReal(rkDumbX^[j-1], 10, 4); 
	      WriteString('  '); 
	      WriteReal(rkDumbY^[3]^[j-1], 12, 6); 
	      WriteReal(BessJ(3, rkDumbX^[j-1]), 12, 6);
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('XMMid', 'Not enough memory.');
	END;
	IF VSTART # NilVector THEN DisposeVector(VSTART) END;
	IF RKDumbX # NilVector THEN DisposeVector(RKDumbX) END;
	IF RKDumbY # NilMatrix THEN DisposeMatrix(RKDumbY) END;
END  XRKDumb.
