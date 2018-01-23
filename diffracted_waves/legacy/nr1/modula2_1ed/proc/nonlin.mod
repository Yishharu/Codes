IMPLEMENTATION MODULE NonLin;

   FROM GaussJor IMPORT GaussJ;
   FROM LLSs     IMPORT CovSrt;
   FROM NRMath   IMPORT Exp;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   VAR
      MrqminOchisq: REAL;

   PROCEDURE FGauss(    x: REAL; 
                        A: Vector; 
                    VAR y: REAL; 
                        DYDA: Vector); 
      VAR 
         i, ii, ma, ndyda: INTEGER; 
         fac, ex, arg: REAL; 
         a, dyda: PtrToReals;
   BEGIN 
      GetVectorAttr(A, ma, a);
      GetVectorAttr(DYDA, ndyda, dyda);
      y := 0.0; 
      FOR ii := 1 TO ma DIV 3 DO 
         i := 3*ii-2; 
         arg := (x-a^[i])/a^[i+1]; 
         ex := Exp(-arg*arg); 
         fac := a^[i-1]*ex*2.0*arg; 
         y := y+a^[i-1]*ex; 
         dyda^[i-1] := ex; 
         dyda^[i] := fac/a^[i+1]; 
         dyda^[i+1] := fac*arg/a^[i+1]
      END
   END FGauss; 

   PROCEDURE MrqCof(    X, Y, SIG, A: Vector; 
                        LISTA: IVector; 
                        ALPHA: Matrix; 
                        BETA: Vector; 
                        func: MrqFunc;
                    VAR chisq: REAL); 
   (*
     Used by MRQMin to evaluate the linearized fitting matrix 
     ALPHA[mfit, mfit], and vector BETA[0, mfit-1] as in (14.4.8).
   *)
      VAR 
         k, j, i, nbeta, ndata, ny, nalpha, ma, malpha, 
         nsig, mfit: INTEGER; 
         ymod, wt, sig2i, dy: REAL; 
         lista: PtrToIntegers;
         x, y, sig, a, dyda, beta: PtrToReals;
         alpha: PtrToLines;
         DYDA: Vector;
   BEGIN 
      GetVectorAttr(X, ndata, x);
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(A, ma, a);
      GetVectorAttr(SIG, nsig, sig);
      GetIVectorAttr(LISTA, mfit, lista);
      GetVectorAttr(BETA, nbeta, beta);
      GetMatrixAttr(ALPHA, nalpha, malpha, alpha);
      CreateVector(ma, DYDA, dyda);
      IF DYDA # NilVector THEN
         FOR j := 1 TO mfit DO 
		   (*
		     Initialize (symmetric) ALPHA, BETA.
		   *)
            FOR k := 1 TO j DO 
               alpha^[j-1]^[k-1] := 0.0
            END; 
            beta^[j-1] := 0.0
         END; 
         chisq := 0.0; 
         FOR i := 1 TO ndata DO 
		   (*
		     Summation loop over all data.
		   *)
            func(x^[i-1], A, ymod, DYDA); 
            sig2i := 1.0/(sig^[i-1]*sig^[i-1]); 
            dy := y^[i-1]-ymod; 
            FOR j := 1 TO mfit DO 
               wt := dyda^[lista^[j-1]-1]*sig2i; 
               FOR k := 1 TO j DO 
                  alpha^[j-1]^[k-1] := alpha^[j-1]^[k-1]+wt*dyda^[lista^[k-1]-1]
               END; 
               beta^[j-1] := beta^[j-1]+dy*wt
            END; 
            chisq := chisq+dy*dy*sig2i
			   (*
			     Find chi ^2.
			   *)
         END; 
         FOR j := 2 TO mfit DO (* Fill in the symmetric side. *)
            FOR k := 1 TO j-1 DO 
               alpha^[k-1]^[j-1] := alpha^[j-1]^[k-1]
            END
         END; 
         DisposeVector(DYDA)
      ELSE
         Error('MrqCof', 'Not enough memory.');
      END;
   END MrqCof; 

   PROCEDURE MrqMin(    X, Y, SIG: Vector;  nData: INTEGER;
                        A:         Vector;  ma:    INTEGER;
                        LISTA:     IVector; mfit:  INTEGER;
                        COVAR, ALPHA: Matrix; 
                        func: MrqFunc;
                        MrqMinBeta: Vector;
                    VAR chisq, alamda: REAL); 
      VAR 
         k, kk, j, ihit, na, nx, ny, nsig, ncovar, nalpha,
         nlista, mcovar, malpha, mBeta: INTEGER; 
         ATRY, DA: Vector;
         ONEDA: Matrix;
         oneda: PtrToLines; 
         atry, da, x, y, sig, a, mrqminbeta: PtrToReals;
         lista: PtrToIntegers;
         covar, alpha: PtrToLines;
   BEGIN 
      GetVectorAttr(X, nx, x);
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(A, na, a);
      GetVectorAttr(SIG, nsig, sig);
      GetIVectorAttr(LISTA, nlista, lista);
      GetMatrixAttr(COVAR, ncovar, mcovar, covar);
      GetMatrixAttr(ALPHA, nalpha, malpha, alpha);
      GetVectorAttr(MrqMinBeta, mBeta, mrqminbeta);
      CreateVector(ma, DA, da);
      CreateVector(ma, ATRY, atry);
      CreateMatrix(ma, 1, ONEDA, oneda);(* ONEDA is a matrix with one column, the vector DA. It is
                                           used by GaussJ below. *)
      IF (DA # NilVector) AND (ATRY # NilVector) AND 
         (ONEDA # NilMatrix) THEN
	      IF alamda < 0.0 THEN (* Initialization. *)
	         kk := mfit+1; 
	         FOR j := 1 TO ma DO (* Does LISTA contain a proper
                                 permutation of the coefficients? *)
	            ihit := 0; 
	            FOR k := 1 TO mfit DO 
	               IF lista^[k-1] = j THEN 
	                  INC(ihit, 1)
	               END
	            END; 
	            IF ihit = 0 THEN 
	               lista^[kk-1] := j; 
	               INC(kk, 1)
	            ELSIF ihit > 1 THEN 
	               Error('MrqMin', 'Improper permutation in LISTA'); 
	            END
	         END; 
	         IF kk <> ma+1 THEN 
	            Error('MrqMin', 'Improper permutation in LISTA'); 
	         END; 
	         alamda := 0.001; 
	         MrqCof(X, Y, SIG, A, LISTA, ALPHA, MrqMinBeta, func, chisq); 
	         MrqminOchisq := chisq; 
	         FOR j := 1 TO ma DO 
	            atry^[j-1] := a^[j-1]
	         END
	      END; 
	      FOR j := 1 TO mfit DO (* Alter linearized fitting matrix, by augmenting 
                                diagonal elements. *)
	         FOR k := 1 TO mfit DO 
	            covar^[j-1]^[k-1] := alpha^[j-1]^[k-1]
	         END; 
	         covar^[j-1]^[j-1] := alpha^[j-1]^[j-1]*(1.0+alamda); 
	         oneda^[j-1]^[0] := mrqminbeta^[j-1]
	      END; 
	      GaussJ(COVAR, mfit, ONEDA, 1); (* Matrix solution. *)
	      FOR j := 1 TO mfit DO 
	         da^[j-1] := oneda^[j-1]^[0]
	      END; 
	      IF alamda = 0.0 THEN (* Once converged evaluate covariance 
                               matrix with alamda=0. *)
	         CovSrt(COVAR, ma, LISTA, mfit); 
		      IF ATRY # NilVector THEN DisposeVector(ATRY); END;
		      IF DA # NilVector THEN DisposeVector(DA); END;
		      IF ONEDA # NilMatrix THEN DisposeMatrix(ONEDA) END;
		      RETURN;
	      END; 
	      FOR j := 1 TO mfit DO 
	         atry^[lista^[j-1]-1] := a^[lista^[j-1]-1]+da^[j-1]
	      END; 
	      MrqCof(X, Y, SIG, ATRY, LISTA, COVAR, DA, func, chisq); 
	      IF chisq < MrqminOchisq THEN (* Did the trial succeed? *)
	         alamda := 0.1*alamda; (* Success, accept the new solution. *)
	         MrqminOchisq := chisq; 
	         FOR j := 1 TO mfit DO 
	            FOR k := 1 TO mfit DO 
	               alpha^[j-1]^[k-1] := covar^[j-1]^[k-1]
	            END; 
	            mrqminbeta^[j-1] := da^[j-1]; 
	            a^[lista^[j-1]-1] := atry^[lista^[j-1]-1]
	         END
	      ELSE (* Failure, increase alamda and return. *)
	         alamda := 10.0*alamda; 
	         chisq := MrqminOchisq
	      END; 
	   ELSE
	      Error('MrqMin', 'Not enough memory.');
	   END;
      IF ATRY # NilVector THEN DisposeVector(ATRY); END;
      IF DA # NilVector THEN DisposeVector(DA); END;
      IF ONEDA # NilMatrix THEN DisposeMatrix(ONEDA) END;
   END MrqMin; 
   
END NonLin.
