IMPLEMENTATION MODULE AmoebaM;

   FROM NRMath   IMPORT VectorFunction;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE AmoTry(    P:      Matrix; 
                        Y:      Vector;
                        SUM:    Vector;
                        ndim,
                        ihi:    INTEGER;
                        func:   VectorFunction;
                    VAR nfunc:  INTEGER;
                        fac:    REAL):   REAL;
   (*
     Extrapolates by a factor FAC through the face of the simplex
     across from the high point, tries it, and replaces the high point
     if the new point is better.
   *)
      VAR
         j, mpts, np, nsum, nY: INTEGER;
         fac1, fac2, ytry: REAL;
         PTRY: Vector;
         ptry, y, sum: PtrToReals;
         p: PtrToLines;
   BEGIN
      GetMatrixAttr(P, mpts, np, p);
      GetVectorAttr(Y, nY, y);
      GetVectorAttr(SUM, nsum, sum);
      CreateVector(ndim, PTRY, ptry);
      IF PTRY # NilVector THEN 
         fac1 := (1.0-fac)/Float(ndim); 
         fac2 := fac1-fac; 
         FOR j := 0 TO ndim-1 DO 
            ptry^[j] := sum^[j]*fac1-p^[ihi]^[j]*fac2
         END; 
         ytry := func(PTRY); (* Evaluate the function at the trial point. *)
         INC(nfunc, 1); 
         IF ytry < y^[ihi] THEN (* If it's better than the highest, then replace 
                                   the highest. *)
            y^[ihi] := ytry;
            FOR j := 0 TO ndim-1 DO
               sum^[j] := sum^[j]+ptry^[j]-p^[ihi]^[j];
               p^[ihi]^[j] := ptry^[j]
            END
         END;
         DisposeVector(PTRY);
         RETURN ytry;
      ELSE
         Error('AmoTry', 'Not enough memory.');
      END;
   END AmoTry;

   PROCEDURE Amoeba(    P:     Matrix;
                        Y:     Vector;
                        ndim:  INTEGER;
                        ftol:  REAL; 
                        func:  VectorFunction;
                    VAR nfunc: INTEGER); 
      CONST 
         nfuncmax = 5000; (* The maximum allowed
                             number of function evaluations, and three parameters
                             defining the expansions and contractions. *)
         alpha = 1.0;
         beta = 0.5;
         gamma = 2.0;
      VAR
         mpts, nY, j, inhi, ilo, ihi, i, np: INTEGER;
         ytry, ysave, sum, rtol: REAL;
         PSUM: Vector;
         psum, y: PtrToReals;
         p: PtrToLines;

   BEGIN
      GetMatrixAttr(P, mpts, np, p);
      GetVectorAttr(Y, nY, y);
      IF (nY = mpts) THEN
         CreateVector(ndim, PSUM, psum);
         IF PSUM # NilVector THEN
		      nfunc := 0;
		      FOR j := 0 TO ndim-1 DO 
		         sum := 0.0; 
		         FOR i := 0 TO mpts-1 DO 
		            sum := sum+p^[i]^[j]
		         END; 
		         psum^[j] := sum
		      END; 
		      LOOP 
		         ilo := 0; (* First we must determine which point is the
                            highest (worst), next-highest, and lowest (best), *)
		         IF y^[0] > y^[1] THEN 
		            ihi := 0; 
		            inhi := 1
		         ELSE 
		            ihi := 1; 
		            inhi := 0
		         END; 
		         FOR i := 0 TO mpts-1 DO (* by looping over the points in the simplex. *)
		            IF y^[i] < y^[ilo] THEN 
		               ilo := i
		            END; 
		            IF y^[i] > y^[ihi] THEN 
		               inhi := ihi; 
		               ihi := i
		            ELSIF y^[i] > y^[inhi] THEN 
		               IF i <> ihi THEN 
		                  inhi := i
		               END
		            END
		         END; 
				   (*
				     Compute the fractional range from highest to lowest.
				   *)
		         rtol := 2.0*(ABS(y^[ihi]-y^[ilo]))/(ABS(y^[ihi])+ABS(y^[ilo])); 
		         IF rtol < ftol THEN 
				   (*
				     Return if satisfactory.
				   *)
		            DisposeVector(PSUM);
		            RETURN;
		         END; 
		         IF nfunc >= nfuncmax THEN 
		            Error('Amoeba', 'Too many iterations'); 
		         END; 
				   (*
				     Begin a new iteration. First extrapolate by a factor alpha through
				     the face of the simplex across from the high point, i.e., reflect the
				     simplex from the high point.
				   *)
		         ytry := AmoTry(P, Y, PSUM, ndim, ihi, func, nfunc, -alpha);
		         IF ytry <= y^[ilo] THEN
				   (*
				     Gives a result better than the best
				     point, so try an additional extrapolation by a factor gamma.
				   *)
		            ytry := AmoTry(P, Y, PSUM, ndim, ihi, func, nfunc, gamma)
		         ELSIF ytry >= y^[inhi] THEN
				   (*
				     The reflected point is worse than the second-highest, so
				     look for an intermediate lower point,
				     i.e., do a one-dimensional contraction.
				   *)
		            ysave := y^[ihi];
		            ytry := AmoTry(P, Y, PSUM, ndim, ihi, func, nfunc, beta);
		            IF ytry >= ysave THEN (* Can't seem to get rid of that high point.
                                       Better contract around the lowest (best) point. *)
		               FOR i := 0 TO mpts-1 DO
		                  IF i <> ilo THEN
		                     FOR j := 0 TO ndim-1 DO
		                        psum^[j] := 0.5*(p^[i]^[j]+p^[ilo]^[j]);
		                        p^[i]^[j] := psum^[j]
		                     END;
		                     y^[i] := func(PSUM)
		                  END
		               END;
		               INC(nfunc, ndim); (* Keep track of function evaluations. *)
		               FOR j := 0 TO ndim-1 DO (* Recompute PSUM. *)
		                  sum := 0.0; 
		                  FOR i := 0 TO mpts-1 DO 
		                     sum := sum+p^[i]^[j]
		                  END; 
		                  psum^[j] := sum
		               END
		            END
		         END
		      END; (* Go back for the test of doneness and the next iteration. *)
	         DisposeVector(PSUM);
		   ELSE
	         Error('Amoeba', 'Not enough memory.');
	      END;
	   ELSE
	      Error('Amoeba', 'Inproper input data.');
	   END;
   END Amoeba; 

END AmoebaM.
