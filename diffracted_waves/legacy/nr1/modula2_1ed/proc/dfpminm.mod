IMPLEMENTATION MODULE DFPMinM;

   FROM DirSet IMPORT LinMin;
   FROM NRMath IMPORT VectorFunction;
   FROM NRIO   IMPORT Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;


	PROCEDURE DFPMin(    P:    Vector; 
	                     ftol: REAL;
                        fnc:  VectorFunction;
                        dfnc: VectorVectorFunc;
	                 VAR iter: INTEGER; VAR fret: REAL);
	CONST
	   itmax = 200;(* Maximum allowed number of iterations; 
	                  small number to rectify special case of converging to
                     exactly zero function value. *)
	   eps = 1.0E-10;
	VAR
	   j,i,its, n: INTEGER;
	   fp,fae,fad,fac: REAL;
	   XI, G, DG, HDG: Vector;
	   xi,g,dg, hdg, p: PtrToReals;
	   HESSIN: Matrix;
	   hessin: PtrToLines;
	BEGIN
	   GetVectorAttr(P, n, p);
	   CreateVector(n, XI, xi);
	   CreateVector(n, G, g);
	   CreateVector(n, DG, dg);
	   CreateVector(n, HDG, hdg);
	   CreateMatrix(n, n, HESSIN, hessin);
	   IF (XI # NilVector) AND (G # NilVector) AND (DG # NilVector) AND
	      (HDG # NilVector) AND (HESSIN # NilMatrix) THEN
		   fp := fnc(P);(* Calculate starting function value and gradient, *)
		   dfnc(P, G);
		   FOR i := 0 TO n-1 DO (* and initialize the inverse Hessian to the unit
                                 matrix. *)
		      FOR j := 0 TO n-1 DO hessin^[i]^[j] := 0.0; END;
		      hessin^[i]^[i] := 1.0;
		      xi^[i] := -g^[i](* Initial line direction. *)
		   END;
		   FOR its := 1 TO itmax DO (* Main loop over the iterations. *)
		      iter := its;
		      LinMin(P, XI, fret, fnc); (* Next statement is the normal return: *)
		      IF 2.0*ABS(fret-fp) <= ftol*(ABS(fret)+ABS(fp)+eps) THEN 
	            DisposeMatrix(HESSIN); 
	            DisposeVector(HDG); 
	            DisposeVector(DG);
	            DisposeVector(G); 
	            DisposeVector(XI); 
	            RETURN;
		      END;
		      fp := fret;(* Save the old function value *)
		      FOR i := 0 TO n-1 DO dg^[i] := g^[i]; END;
			   (*
			     and the old gradient.
			   *)
		      fret := fnc(P);(* Get new function value and gradient. *)
		      dfnc(P, G);
		      FOR i := 0 TO n-1 DO (* Compute difference of gradients, *)
		         dg^[i] := g^[i]-dg^[i];
		      END;
		      FOR i := 0 TO n-1 DO (* and difference times current matrix. *)
		         hdg^[i] := 0.0;
		         FOR j := 0 TO n-1 DO hdg^[i] := hdg^[i]+hessin^[i]^[j]*dg^[j] END;
		      END;
		      fac := 0.0; (* Calculate dot products for the denominators, *)
		      fae := 0.0;
		      FOR i := 0 TO n-1 DO 
		         fac := fac+dg^[i]*xi^[i];
		         fae := fae+dg^[i]*hdg^[i]
		      END;
		      fac := 1.0/fac; (* and make the denominators multiplicative. *)
		      fad := 1.0/fae;
		      FOR i := 0 TO n-1 DO (* The vector that makes BFGS different
                                from DFP. *)
		         dg^[i] := fac*xi^[i]-fad*hdg^[i]; END;
		      FOR i := 0 TO n-1 DO (* The BFGS updating formula: *)
		         FOR j := 0 TO n-1 DO
		            hessin^[i]^[j] := hessin^[i]^[j]+fac*xi^[i]*xi^[j]
		               -fad*hdg^[i]*hdg^[j]+fae*dg^[i]*dg^[j];
		         END;
		      END;
		      FOR i := 0 TO n-1 DO (* Now calculate the next direction to go, *)
		         xi^[i] := 0.0;
		         FOR j := 0 TO n-1 DO xi^[i] := xi^[i]-hessin^[i]^[j]*g^[j] END;
		      END;
		   END; (* and go back for another iteration. *)
		   Error('DFPMin', 'Too many iterations.');
		ELSE
		   Error('DFPMin', 'Not enough memory.');
		END;
	   IF HESSIN # NilMatrix THEN DisposeMatrix(HESSIN); END;
	   IF HDG # NilVector THEN DisposeVector(HDG); END;
	   IF DG # NilVector THEN DisposeVector(DG); END;
	   IF G # NilVector THEN DisposeVector(G); END;
	   IF XI # NilVector THEN DisposeVector(XI); END;
	END DFPMin;

END DFPMinM.
