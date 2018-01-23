IMPLEMENTATION MODULE ConjGrad;

   FROM DirSet IMPORT LinMin;
   FROM NRMath IMPORT VectorFunction;
   FROM NRIO   IMPORT Error;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   PROCEDURE DF1Dim(x: REAL; LinminPcom, LinminXcom: Vector; 
                    dfnc: VectorVectorFunc): REAL; 
      VAR 
         df1: REAL; 
         j, linminNcom, n: INTEGER; (* These variables are assigned values in LinMin. *)
         XT, DF: Vector;
         xt, df, linminPcom, linminXcom: PtrToReals; 
   BEGIN 
      GetVectorAttr(LinminPcom, linminNcom, linminPcom);
      GetVectorAttr(LinminXcom, n, linminXcom);
      CreateVector(linminNcom, XT, xt);
      CreateVector(linminNcom, DF, df);
      IF (XT # NilVector) AND (DF # NilVector) THEN
	      FOR j := 0 TO linminNcom-1 DO 
	         xt^[j] := linminPcom^[j]+x*linminXcom^[j]
	      END; 
	      dfnc(XT, DF); 
	      df1 := 0.0; 
	      FOR j := 0 TO linminNcom-1 DO 
	         df1 := df1+df^[j]*linminXcom^[j]
	      END; 
	   ELSE
	      Error('DF1Dim', 'Not enough memory.');
	   END;
      IF XT # NilVector THEN DisposeVector(XT); END;
      IF DF # NilVector THEN DisposeVector(DF); END;
      RETURN df1;
   END DF1Dim; 

   PROCEDURE FRPRMn(    P:    Vector; 
                        ftol: REAL;
                        fnc:  VectorFunction;
                        dfnc: VectorVectorFunc;
                    VAR iter: INTEGER; 
                    VAR fret: REAL); 
      CONST 
         itmax = 200; (* Maximum allowed number of iterations; small number to 
                         rectify special case of converging to exactly zero 
                         function value. *)
         eps = 1.0E-10; 
      VAR 
         j, its, n: INTEGER; 
         gg, gam, fp, dgg: REAL; 
         G, H, XI: Vector;
         p, g, h, xi: PtrToReals; 
   BEGIN 
      GetVectorAttr(P, n, p);
      CreateVector(n, G, g);
      CreateVector(n, H, h);
      CreateVector(n, XI, xi);
      IF (G # NilVector) AND (H # NilVector) AND (XI # NilVector) THEN
	      fp := fnc(P); (* Initializations. *)
	      dfnc(P, XI); 
	      FOR j := 0 TO n-1 DO 
	         g^[j] := -xi^[j]; 
	         h^[j] := g^[j]; 
	         xi^[j] := h^[j]
	      END; 
	      FOR its := 1 TO itmax DO (* Loop over iterations. *)
	         iter := its; 
	         LinMin(P, XI, fret, fnc); (* Next statement is the normal return: *)
	         IF 2.0*ABS(fret-fp) <= ftol*(ABS(fret)+ABS(fp)+eps) THEN 
			      DisposeVector(G);
			      DisposeVector(H); 
			      DisposeVector(XI);
			      RETURN;
	         END; 
	         fp := fnc(P); 
	         dfnc(P, XI); 
	         gg := 0.0; 
	         dgg := 0.0; 
	         FOR j := 0 TO n-1 DO 
	            gg := gg+g^[j]*g^[j]; 
	            (*  dgg := dgg+sqr(xi^[j])  *) (* This statement for Fletcher-Reeves. *)
	            dgg := dgg+(xi^[j]+g^[j])*xi^[j](* This statement for Polak-Ribiere. *)
	         END; 
	         IF gg = 0.0 THEN (* Unlikely. If gradient is exactly zero then we are 
	                             already done. *)
			      DisposeVector(G);
			      DisposeVector(H); 
			      DisposeVector(XI);
			      RETURN;
	         END; 
	         gam := dgg/gg; 
	         FOR j := 0 TO n-1 DO 
	            g^[j] := -xi^[j]; 
	            h^[j] := g^[j]+gam*h^[j]; 
	            xi^[j] := h^[j]
	         END
	      END; 
	      Error('FRPRMn', 'Too many iterations.'); 
	   ELSE
	      Error('FRPRMn', 'Not enough memory.'); 
	   END;
      IF G # NilVector THEN DisposeVector(G); END;
      IF H # NilVector THEN DisposeVector(H); END;
      IF XI # NilVector THEN DisposeVector(XI); END;
   END FRPRMn; 

END ConjGrad.
