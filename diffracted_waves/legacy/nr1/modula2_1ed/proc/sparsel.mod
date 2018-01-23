IMPLEMENTATION MODULE SparseL;

   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, GetMatrixAttr, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        GetVectorAttr;

   PROCEDURE Sparse(    B,
                        X:  Vector; 
                    VAR rsq: REAL;
                        aSub, aTSub: Subroutine); 
      CONST 
         eps = 1.0E-6; (* r.m.s. accuracy desired. *)
      VAR 
         j, iter, irst, n, nX: INTEGER; 
         rp, gg, gam, eps2, dgg, bsq, anum, aden: REAL; 
         gV, hV, xiV, xjV: Vector; 
         g, h, xi, xj, b, x: PtrToReals;

      PROCEDURE DisposeLocalVectors;
      BEGIN
	      DisposeVector(xjV); 
	      DisposeVector(xiV); 
	      DisposeVector(hV); 
	      DisposeVector(gV);
      END DisposeLocalVectors;

   BEGIN 
      GetVectorAttr(B, n, b);
      GetVectorAttr(X, nX, x);
      IF (n = nX) THEN
	      CreateVector(n, gV, g);
	      CreateVector(n, hV, h);
	      CreateVector(n, xiV, xi);
	      CreateVector(n, xjV, xj);
	      eps2 := Float(n)*eps*eps; (* Criterion for sum-squared residuals. *)
	      irst := 0; (* irst is the number of restarts attempted. *)
         LOOP	
		      INC(irst, 1); 
		      aSub(X, xiV); (* Evaluate the starting gradient, *)
		      rp := 0.0; 
		      bsq := 0.0; 
		      FOR j := 0 TO n-1 DO 
		         bsq := bsq+b^[j]*b^[j]; (* and the magnitude of the
                                      right side. *)
		         xi^[j] := xi^[j]-b^[j]; 
		         rp := rp+xi^[j]*xi^[j]
		      END; 
		      aTSub(xiV, gV); 
		      FOR j := 0 TO n-1 DO 
		         g^[j] := -g^[j]; 
		         h^[j] := g^[j]
		      END; 
		      FOR iter := 1 TO 10*n DO (* Main iteration loop. *)
		         aSub(hV, xiV); 
		         anum := 0.0; 
		         aden := 0.0; 
		         FOR j := 0 TO n-1 DO 
		            anum := anum+g^[j]*h^[j]; 
		            aden := aden+xi^[j]*xi^[j]
		         END; 
		         IF aden = 0.0 THEN 
		            Error('SPARSE', 'Very singular matrix'); 
		         END; 
		         anum := anum/aden; (* Equation (2.10.21). *)
		         FOR j := 0 TO n-1 DO 
		            xi^[j] := x^[j]; 
		            x^[j] := x^[j]+anum*h^[j]
		         END; 
		         aSub(X, xjV); 
		         rsq := 0.0; 
		         FOR j := 0 TO n-1 DO 
		            xj^[j] := xj^[j]-b^[j]; 
		            rsq := rsq+xj^[j]*xj^[j]
		         END; 
		         IF (rsq = rp) OR (rsq <= bsq*eps2) THEN (* Converged.  Normal return. *)
		            DisposeLocalVectors;
		            RETURN 
		         END; 
		         IF rsq > rp THEN (* Not improving.  Do a restart. *)
		            FOR j := 0 TO n-1 DO 
		               x^[j] := xi^[j]
		            END; 
		            IF irst >= 3 THEN (* Return if too many restarts. This is the 
		                                 normal return when we run into roundoff
                                       error before satisfying the return above. *)
		               DisposeLocalVectors;
		               RETURN; 
		            END; 
		            EXIT;
		         END; 
		         rp := rsq; 
		         aTSub(xjV, xiV); (* Compute gradient for next iteration. *)
		         gg := 0.0; 
		         dgg := 0.0; 
		         FOR j := 0 TO n-1 DO 
		            gg := gg+g^[j]*g^[j]; 
		            dgg := dgg+(xi^[j]+g^[j])*xi^[j]
		         END; 
		         IF gg = 0.0 THEN (* a rare, but normal, return. *)
		            DisposeLocalVectors;
		            RETURN;
		         END; 
		         gam := dgg/gg; 
		         FOR j := 0 TO n-1 DO 
		            g^[j] := -xi^[j]; 
		            h^[j] := g^[j]+gam*h^[j]
		         END;
	         END;
	      END; 
	      Error('SPARSE', 'Too many iterations!'); 
	      DisposeLocalVectors;
	   ELSE
	      Error('Sparse', 'Inproper input vectors!');
	   END;
   END Sparse; 

END SparseL.
