IMPLEMENTATION MODULE ShootM;

   FROM LUDecomp IMPORT LUDCMP, LUBKSB;
   FROM AccMon   IMPORT ODEInt;
   FROM NRMath   IMPORT DerivFunction;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE Shoot(n: INTEGER; 
                   V, DELV: Vector; 
                   x1, x2, eps, h1, hmin: REAL; 
                   load, score, derivs: DerivFunction;
                   ShootM,ShootN: INTEGER;
                   ShootC2,ShootFactr: REAL;
                   OdeintDxsav: REAL;
                   OdeintKmax: INTEGER;
                   ODEIntXp: Vector;
                   ODEIntYp: Matrix;
                   VAR OdeintKount: INTEGER;
                   F, DV: Vector); 
      VAR 
         n2, nok, nbad, iv, i, nDelv, ndv, nf: INTEGER; 
         sav, det: REAL; 
         Y: Vector;
         DFDV: Matrix;
         dfdv: PtrToLines; 
         INDX: IVector;
         indx: PtrToIntegers; 
         v, delv, f, y, dv: PtrToReals;
   BEGIN 
      GetVectorAttr(V, n2, v);
      GetVectorAttr(DELV, nDelv, delv);
      GetVectorAttr(F, nf, f);
      GetVectorAttr(DV, ndv, dv);
      CreateVector(n, Y, y);
      CreateMatrix(n2, n2, DFDV, dfdv);
      CreateIVector(n2, INDX, indx);
      IF (Y # NilVector) AND (DFDV # NilMatrix) AND (INDX # NilIVector) THEN
	      load(x1, V, Y); (* Integrate from x1 with best trial values. *)
	      ODEInt(Y, x1, x2, eps, h1, hmin, derivs, OdeintDxsav, OdeintKmax,
	             ODEIntXp, ODEIntYp, OdeintKount, nok, nbad); 
	      score(x2, Y, F); 
	      FOR iv := 1 TO n2 DO (* Vary boundary conditions at x1. *)
	         sav := v^[iv-1]; 
	         v^[iv-1] := v^[iv-1]+delv^[iv-1]; (* Increment parameter IV. *)
	         load(x1, V, Y); 
	         ODEInt(Y, x1, x2, eps, h1, hmin, derivs, OdeintDxsav, OdeintKmax,
	                ODEIntXp, ODEIntYp, OdeintKount, nok, nbad); 
	         score(x2, Y, DV); 
	         FOR i := 1 TO n2 DO (* Evaluate numerical derivatives of the n2 
                                   matching conditions. *)
	            dfdv^[i-1]^[iv-1] := (dv^[i-1]-f^[i-1])/delv^[iv-1]
	         END; 
	         v^[iv-1] := sav (* Restore incremented parameter. *)
	      END; 
	      FOR iv := 1 TO n2 DO 
	         dv^[iv-1] := -f^[iv-1]
	      END; 
	      LUDCMP(DFDV, INDX, det); (* Solve linear equations. *)
	      LUBKSB(DFDV, INDX, DV); 
	      FOR iv := 1 TO n2 DO (* Increment boundary parameters. *)
	         v^[iv-1] := v^[iv-1]+dv^[iv-1]
	      END; 
	   ELSE
	      Error('Shoot', 'Not enough memory.');
	   END;
      IF INDX # NilIVector THEN DisposeIVector(INDX); END;
      IF DFDV # NilMatrix THEN DisposeMatrix(DFDV); END;
      IF Y # NilVector THEN DisposeVector(Y); END;
   END Shoot; 

END ShootM.
