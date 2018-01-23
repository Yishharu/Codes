IMPLEMENTATION MODULE ShootFM;

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

   PROCEDURE ShootF(n: INTEGER; 
                    V1, V2, DELV1, DELV2: Vector; 
                    x1, x2, xf: REAL; 
                    eps, h1, hmin: REAL; 
                    load1, load2, score, derivs: DerivFunction;
                    OdeintDxsav: REAL;
                    OdeintKmax: INTEGER;
                    ODEIntXp: Vector;
                    ODEIntYp: Matrix;
                    VAR OdeintKount: INTEGER;
                    F, DV1, DV2: Vector); 
      VAR 
         nok, nbad, j, iv, i, n1, n2, 
         nDelv1, nDelv2, nf, nDv1, nDv2: INTEGER; 
         sav, det: REAL; 
         Y, F1, F2: Vector; 
         DFDV: Matrix;
         dfdv: PtrToLines; 
         INDX: IVector; 
         indx: PtrToIntegers; 
         v1, v2, delv1, delv2, f, dv1, dv2,
         f1, f2, y: PtrToReals;
   BEGIN 
      GetVectorAttr(V1, n2, v1);
      GetVectorAttr(V2, n1, v2);
      GetVectorAttr(DELV1, nDelv1, delv1);
      GetVectorAttr(DELV2, nDelv2, delv2);
      GetVectorAttr(F, nf, f);
      GetVectorAttr(DV1, nDv1, dv1);
      GetVectorAttr(DV2, nDv2, dv2);
      CreateVector(n, Y, y);
      CreateVector(n, F1, f1);
      CreateVector(n, F2, f2);
      CreateMatrix(n, n, DFDV, dfdv);
      CreateIVector(n, INDX, indx);
      IF (Y # NilVector) AND (F1 # NilVector) AND (F2 # NilVector) AND 
         (DFDV # NilMatrix) AND (INDX # NilIVector) THEN
	      load1(x1, V1, Y); (* Path from x1 to xf with 
                            best trial values V1. *)
	      ODEInt(Y, x1, xf, eps, h1, hmin, derivs, OdeintDxsav, 
	             OdeintKmax, ODEIntXp, ODEIntYp, OdeintKount, nok, nbad); 
	      score(xf, Y, F1); 
	      load2(x2, V2, Y); (* Path from x2 to xfF with 
                            best trial values V2. *)
	      ODEInt(Y, x2, xf, eps, h1, hmin, derivs, OdeintDxsav, 
	             OdeintKmax, ODEIntXp, ODEIntYp, OdeintKount, nok, nbad); 
	      score(xf, Y, F2); 
	      j := 0; 
	      FOR iv := 1 TO n2 DO 
		   (*
		     Vary boundary conditions at x1.
		   *)
	         INC(j, 1); 
	         sav := v1^[iv-1]; 
	         v1^[iv-1] := v1^[iv-1]+delv1^[iv-1]; 
	         load1(x1, V1, Y); 
	         ODEInt(Y, x1, xf, eps, h1, hmin, derivs, OdeintDxsav, 
	         OdeintKmax, ODEIntXp, ODEIntYp, OdeintKount, nok, nbad); 
	         score(xf, Y, F); 
	         FOR i := 1 TO n DO (* Evaluate numerical derivatives of 
                                n fitting conditions. *)
	            dfdv^[i-1]^[j-1] := (f^[i-1]-f1^[i-1])/delv1^[iv-1]
	         END; 
	         v1^[iv-1] := sav(* Restore boundary parameter. *)
	      END; 
	      FOR iv := 1 TO n1 DO 
		   (*
		     Next vary boundary conditions at x2.
		   *)
	         INC(j, 1); 
	         sav := v2^[iv-1]; 
	         v2^[iv-1] := v2^[iv-1]+delv2^[iv-1]; 
	         load2(x2, V2, Y); 
	         ODEInt(Y, x2, xf, eps, h1, hmin, derivs, OdeintDxsav, 
	                OdeintKmax, ODEIntXp, ODEIntYp, OdeintKount, nok, nbad); 
	         score(xf, Y, F); 
	         FOR i := 1 TO n DO (* F1 used as handy temporary. *)
	            dfdv^[i-1]^[j-1] := (f2^[i-1]-f^[i-1])/delv2^[iv-1]
	         END; 
	         v2^[iv-1] := sav
	      END; 
	      FOR i := 1 TO n DO 
	         f^[i-1] := f1^[i-1]-f2^[i-1]; 
	         f1^[i-1] := -f^[i-1]
	      END; 
	      LUDCMP(DFDV, INDX, det); (* Solve to find increments to free parameters. *)
	      LUBKSB(DFDV, INDX, F1); 
	      j := 0; 
	      FOR iv := 1 TO n2 DO 
		   (*
		     Increment adjustable boundary parameters 
		     at x1.
		   *)
	         INC(j, 1); 
	         v1^[iv-1] := v1^[iv-1]+f1^[j-1]; 
	         dv1^[iv-1] := f1^[j-1]
	      END; 
	      FOR iv := 1 TO n1 DO 
		   (*
		     Increment adjustable boundary parameters 
		     at x2.
		   *)
	         INC(j, 1); 
	         v2^[iv-1] := v2^[iv-1]+f1^[j-1]; 
	         dv2^[iv-1] := f1^[j-1]
	      END; 
	   ELSE
	      Error('ShootF', 'Not enough memory.');
	   END;
      IF INDX # NilIVector THEN DisposeIVector(INDX); END;
      IF DFDV # NilMatrix THEN DisposeMatrix(DFDV); END;
      IF Y # NilVector THEN DisposeVector(Y); END;
      IF F1 # NilVector THEN DisposeVector(F1); END;
      IF F2 # NilVector THEN DisposeVector(F2); END;
   END ShootF; 
END ShootFM.
