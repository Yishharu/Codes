MODULE XShootF; (* driver for routine ShootF *) 
 
   FROM ShootFM  IMPORT ShootF;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, ReadInt, ReadReal, WriteLn, WriteInt,  WriteReal, 
                        WriteString, Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      nvar = 3; 
      n1 = 2; 
      n2 = 1; 
      delta = 1.0E-3; 
      eps = 1.0E-6; 
      dx = 1.0E-4; 
   VAR 
      ShootFC2, ShootFFactr, h1, hmin: REAL; 
      q1, x1, x2, xf: REAL; 
      i, ShootFM, ShootFN: INTEGER;
      V1, DELV1, DV1, V2, DELV2, DV2, F,
      OdeIntXp: Vector;
      v1, delv1, dv1, v2, delv2, dv2, f,
      odeIntXp: PtrToReals; 
      OdeintKmax, OdeintKount: INTEGER; 
      OdeintDxsav: REAL; 
      odeIntYp: PtrToLines;
      OdeIntYp: Matrix; 

   (* Programs using routine LOAD1 must declare the variables
   VAR
      ShootFC2,ShootFFactr: REAL;
      ShootFM: INTEGER;
   in the main routine. *) 

   PROCEDURE load1(x1: REAL; 
                   V1, Y: Vector); 
      VAR 
         nvar, n2: INTEGER;
         y, v1: PtrToReals;
   BEGIN 
      GetVectorAttr(V1, n2, v1);
      GetVectorAttr(Y, nvar, y);
      y^[2] := v1^[0]; 
      y^[1] := -(y^[2]-ShootFC2)*ShootFFactr/2.0/(Float(ShootFM)+1.0); 
      y^[0] := ShootFFactr+y^[1]*dx
   END load1; 

   (* Programs using routine load2 must declare the variables
      ShootFC2: REAL;
      ShootFM: INTEGER;
   in the main routine. *) 

   PROCEDURE load2(x2: REAL; 
                   V2, Y: Vector); 
      VAR 
         nvar, n1: INTEGER;
         y, v2: PtrToReals;
   BEGIN 
      GetVectorAttr(V2, n1, v2);
      GetVectorAttr(Y, nvar, y);
      y^[2] := v2^[1]; 
      y^[0] := v2^[0]; 
      y^[1] := (y^[2]-ShootFC2)*y^[0]/2.0/(Float(ShootFM)+1.0)
   END load2; 

   PROCEDURE score(xf: REAL; 
                   Y, F: Vector); 
      VAR 
         i, nvar, n2: INTEGER;
         y, f: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, nvar, y);
      GetVectorAttr(F, n2, f);
      FOR i := 0 TO 2 DO 
         f^[i] := y^[i]
      END
   END score; 

   (* Programs using routine DERIVS must declare the variables
      ShootFC2: REAL;
      ShootFM: INTEGER;
   in the main routine. *) 

   PROCEDURE derivs(x: REAL; 
                     Y, DYDX: Vector); 
      VAR 
         nvar, ndydx: INTEGER;
         y, dydx: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, nvar, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      dydx^[0] := y^[1]; 
      dydx^[2] := 0.0; 
      dydx^[1] := (2.0*x*(Float(ShootFM)+1.0)*y^[1]-
                  (y^[2]-ShootFC2*x*x)*y^[0])/(1.0-x*x)
   END derivs; 
    
BEGIN 
   CreateVector(n2, DELV1, delv1);
   CreateVector(n1, DELV2, delv2);
   CreateVector(n2, V1, v1);
   CreateVector(n1, V2, v2);
   CreateVector(n2, DV1, dv1);
   CreateVector(n1, DV2, dv2);
   CreateVector(nvar, F, f);
   CreateVector(200, OdeIntXp, odeIntXp);
   CreateMatrix(nvar, 200, OdeIntYp, odeIntYp);
   IF (DELV1 # NilVector) AND (DELV2 # NilVector) AND (V1 # NilVector) AND 
      (V2 # NilVector) AND (DV1 # NilVector) AND (DV2 # NilVector) AND
      (F # NilVector) AND (OdeIntXp # NilVector) AND (OdeIntYp # NilMatrix) THEN
	   REPEAT
	      WriteString('Input M,N,C-SQUARED: '); 
	      ReadInt('ShootFM:', ShootFM); 
	      ReadInt('ShootFN:', ShootFN); 
	      ReadReal('ShootFC2:', ShootFC2); 
	   UNTIL (ShootFN >= ShootFM) AND (ShootFM >= 0);
      OdeintKmax := 0;
	   ShootFFactr := 1.0; 
	   IF ShootFM <> 0 THEN 
	      q1 := Float(ShootFN); 
	      FOR i := 1 TO ShootFM DO 
	         ShootFFactr := -0.5*ShootFFactr*Float(ShootFN+i)*(q1/Float(i)); 
	         q1 := q1-1.0
	      END
	   END; 
	   v1^[0] := Float(ShootFN*(ShootFN+1)-ShootFM*(ShootFM+1))+ShootFC2/2.0; 
	   IF ODD(ShootFN-ShootFM) THEN 
	      v2^[0] := -ShootFFactr
	   ELSE 
	      v2^[0] := ShootFFactr
	   END; 
	   v2^[1] := v1^[0]+1.0; 
	   delv1^[0] := delta*v1^[0]; 
	   delv2^[0] := delta*ShootFFactr; 
	   delv2^[1] := delv1^[0]; 
	   h1 := 0.1; 
	   hmin := 0.0; 
	   x1 := -1.0+dx; 
	   x2 := 1.0-dx; 
	   xf := 0.0; 
	   WriteLn; 
	   WriteString('                    mu(-1)'); 
	   WriteString('             y(1-dx)             mu(+1)'); 
	   WriteLn; 
	   REPEAT 
	      ShootF(nvar, V1, V2, DELV1, DELV2, x1, x2, xf, eps, h1, hmin, 
	             load1, load2, score, derivs, 
	             OdeintDxsav, OdeintKmax,
	             OdeIntXp, OdeIntYp, OdeintKount, F, DV1, DV2); 
	      WriteLn; 
	      WriteString('    v '); 
	      WriteReal(v1^[0], 20, 6); 
	      WriteReal(v2^[0], 20, 6); 
	      WriteReal(v2^[1], 20, 6); 
	      WriteLn; 
	      WriteString('    dv'); 
	      WriteReal(dv1^[0], 20, 6); 
	      WriteReal(dv2^[0], 20, 6); 
	      WriteReal(dv2^[1], 20, 6); 
	      WriteLn; 
	   UNTIL ABS(dv1^[0]) <= ABS(eps*v1^[0]);
	   ReadLn;
	ELSE
	   Error('XShootF', 'Not enough memory.');
	END;
   IF DELV1 # NilVector THEN DisposeVector(DELV1) END;
   IF DELV2 # NilVector THEN DisposeVector(DELV2) END;
   IF V1 # NilVector THEN DisposeVector(V1) END;
   IF V2 # NilVector THEN DisposeVector(V2) END;
   IF DV1 # NilVector THEN DisposeVector(DV1) END;
   IF DV2 # NilVector THEN DisposeVector(DV2) END;
   IF F # NilVector THEN DisposeVector(F) END;
   IF OdeIntXp # NilVector THEN DisposeVector(OdeIntXp) END;
   IF OdeIntYp # NilMatrix THEN DisposeMatrix(OdeIntYp) END;
END XShootF.
