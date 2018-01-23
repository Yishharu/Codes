IMPLEMENTATION MODULE LLSs;

   FROM GaussJor IMPORT GaussJ;
   FROM SVD      IMPORT SVDCMP, SVBKSB;
   FROM NRIO     IMPORT Error;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE CovSrt(COVAR: Matrix; ma: INTEGER; LISTA: IVector; mfit: INTEGER); 
      VAR 
         j, i, na, mCovar, mLista: INTEGER; 
         swap: REAL; 
         covar: PtrToLines;
         lista: PtrToIntegers;
   BEGIN 
      GetMatrixAttr(COVAR, na, mCovar, covar);
      GetIVectorAttr(LISTA, mLista, lista);
      FOR j := 1 TO ma-1 DO (* Zero all elements below diagonal. *)
         FOR i := j+1 TO ma DO 
            covar^[i-1]^[j-1] := 0.0
         END
      END; 
      FOR i := 1 TO mfit-1 DO (* Repack off-diagonal elements of fit into correct 
                                 locations below diagonal. *)
         FOR j := i+1 TO mfit DO 
            IF lista^[j-1] > lista^[i-1] THEN 
               covar^[lista^[j-1]-1]^[lista^[i-1]-1] := covar^[i-1]^[j-1]
            ELSE 
               covar^[lista^[i-1]-1]^[lista^[j-1]-1] := covar^[i-1]^[j-1]
            END
         END
      END; 
      swap := covar^[0]^[0]; (* Temporarily store original diagonal elements 
                                in top row, and zero the diagonal. *)
      FOR j := 1 TO ma DO 
         covar^[0]^[j-1] := covar^[j-1]^[j-1]; 
         covar^[j-1]^[j-1] := 0.0
      END; 
      covar^[lista^[0]-1]^[lista^[0]-1] := swap; 
      FOR j := 2 TO mfit DO (* Now sort elements into proper order on diagonal. *)
         covar^[lista^[j-1]-1]^[lista^[j-1]-1] := covar^[0]^[j-1]
      END; 
      FOR j := 2 TO ma DO (* Finally, fill in above diagonal by symmetry. *)
         FOR i := 1 TO j-1 DO 
            covar^[i-1]^[j-1] := covar^[j-1]^[i-1]
         END
      END
   END CovSrt; 

   PROCEDURE FLeg(x: REAL; 
                  PL: Vector); 
      VAR 
         j, nl: INTEGER; 
         twox, f2, f1, d: REAL; 
         pl: PtrToReals;
   BEGIN 
      GetVectorAttr(PL, nl, pl);
      pl^[0] := 1.0; 
      pl^[1] := x; 
      IF nl > 2 THEN 
         twox := 2.0*x; 
         f2 := x; 
         d := 1.0; 
         FOR j := 3 TO nl DO 
            f1 := d; 
            f2 := f2+twox; 
            d := d+1.0; 
            pl^[j-1] := (f2*pl^[j-2]-f1*pl^[j-3])/d
         END
      END
   END FLeg; 

   PROCEDURE FPoly(x: REAL; 
                   P: Vector); 
      VAR 
         j, np: INTEGER; 
         p: PtrToReals;
   BEGIN 
      GetVectorAttr(P, np, p);
      p^[0] := 1.0; 
      FOR j := 2 TO np DO 
         p^[j-1] := p^[j-2]*x
      END
   END FPoly; 

   PROCEDURE LFit(    X, Y, SIG, A: Vector; 
                      LISTA: IVector; 
                      mfit:  INTEGER;
                      COVAR: Matrix; 
                      funcs: Function;
                  VAR chisq: REAL); 
      VAR 
         k, kk, j, ihit, i, ndata, ny, nsig, na, ma, 
         nlista, ncovar, mcovar: INTEGER; 
         ym, wt, sum, sig2i: REAL; 
         BETA: Matrix;
         AFUNC: Vector;
         x, y, sig, afunc, a: PtrToReals;
         lista: PtrToIntegers;
         beta, covar: PtrToLines;
   BEGIN 
      GetVectorAttr(X, ndata, x);
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(SIG, nsig, sig);
      GetVectorAttr(A, ma, a);
      GetIVectorAttr(LISTA, nlista, lista);
      GetMatrixAttr(COVAR, ncovar, mcovar, covar);
      CreateMatrix(ma, 1, BETA, beta);
      CreateVector(ma, AFUNC, afunc);
      IF (BETA # NilMatrix) AND (AFUNC # NilVector) THEN 
         kk := mfit+1; (* Check to see that LISTA contains a proper
                          permutation of coefficients and fill in any missing members. *)
	      FOR j := 1 TO ma DO 
	         ihit := 0; 
	         FOR k := 1 TO mfit DO 
	            IF lista^[k-1] = j THEN INC(ihit, 1) END
	         END; 
	         IF ihit = 0 THEN 
	            lista^[kk-1] := j; 
	            INC(kk, 1)
	         ELSIF ihit > 1 THEN 
	            Error('LFit', 'improper permutation in LISTA'); 
	         END
	      END; 
	      IF kk <> ma+1 THEN 
	         Error('LFit', 'improper permutation in LISTA'); 
	      END; 
	      FOR j := 1 TO mfit DO 
   (*
     Initialize the (symmetric) matrix.
   *)
	         FOR k := 1 TO mfit DO 
	            covar^[j-1]^[k-1] := 0.0
	         END; 
	         beta^[j-1]^[0] := 0.0
	      END; 
	      FOR i := 1 TO ndata DO (* Loop over data to accumulate coefficients of the 
                                 normal equations. *)
	         funcs(x^[i-1], AFUNC); 
	         ym := y^[i-1]; 
	         IF mfit < ma THEN (* Subtract off dependences on known 
                               pieces of the fitting function. *)
	            FOR j := mfit+1 TO ma DO 
	               ym := ym-a^[lista^[j-1]-1]*afunc^[lista^[j-1]-1]
	            END
	         END; 
	         sig2i := 1.0/(sig^[i-1]*sig^[i-1]); 
	         FOR j := 1 TO mfit DO 
	            wt := afunc^[lista^[j-1]-1]*sig2i; 
	            FOR k := 1 TO j DO 
	               covar^[j-1]^[k-1] := covar^[j-1]^[k-1]+wt*afunc^[lista^[k-1]-1]
	            END; 
	            beta^[j-1]^[0] := beta^[j-1]^[0]+ym*wt
	         END
	      END; 
	      IF mfit > 1 THEN 
	         FOR j := 2 TO mfit DO (* Fill in above the diagonal from
                                   symmetry. *)
	            FOR k := 1 TO j-1 DO 
	               covar^[k-1]^[j-1] := covar^[j-1]^[k-1]
	            END
	         END
	      END; 
	      GaussJ(COVAR, mfit, BETA, 1); (* Matrix solution. *)
	      FOR j := 1 TO mfit DO (* Partition solution to appropriate
                                coefficients A. *)
	         a^[lista^[j-1]-1] := beta^[j-1]^[0]
	      END; 
	      chisq := 0.0; (* Evaluate chi ^2 of the fit. *)
	      FOR i := 1 TO ndata DO 
	         funcs(x^[i-1], AFUNC); 
	         sum := 0.0; 
	         FOR j := 1 TO ma DO 
	            sum := sum+a^[j-1]*afunc^[j-1]
	         END; 
	         chisq := chisq+(((y^[i-1]-sum)/sig^[i-1])*((y^[i-1]-sum)/sig^[i-1]))
	      END; 
	      CovSrt(COVAR, ma, LISTA, mfit); (* Sort covariance matrix to
                                          true order of fitting *)
	   ELSE
	      Error('LFit', 'Not enough memory.');
	   END;
      IF AFUNC # NilVector THEN DisposeVector(AFUNC); END;(* coefficients. *)
      IF BETA # NilMatrix THEN DisposeMatrix(BETA); END;
   END LFit; 

   PROCEDURE SVDFit(    X, Y, SIG, A: Vector; 
                        U, V: Matrix;
                        W: Vector;
                        func: Function;
                    VAR chisq: REAL); 
      CONST 
         tol = 1.0E-5; 
      VAR 
         j, i, ndata, ny, nsig, ma, nu, mu,
         nv, mv, nw: INTEGER; 
         wmax, tmp, thresh, sum: REAL; 
         B, AFUNC: Vector;
         x, y, sig, a, w, b, afunc: PtrToReals;
         u, v: PtrToLines;
   BEGIN 
      GetVectorAttr(X, ndata, x);
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(SIG, nsig, sig);
      GetVectorAttr(A, ma, a);
      GetMatrixAttr(U, nu, mu, u);
      GetMatrixAttr(V, nv, mv, v);
      GetVectorAttr(W, nw, w);
      CreateVector(ndata, B, b);
      CreateVector(ma, AFUNC, afunc);
      IF (B # NilVector) AND (AFUNC # NilVector) THEN 
	      FOR i := 1 TO ndata DO 
   (*
     Accumulate coefficients of the fitting matrix.
   *)
	         func(x^[i-1], AFUNC); 
	         tmp := 1.0/sig^[i-1]; 
	         FOR j := 1 TO ma DO 
	            u^[i-1]^[j-1] := afunc^[j-1]*tmp
	         END; 
	         b^[i-1] := y^[i-1]*tmp
	      END; 
	      SVDCMP(U, W, V); (* Singular value decomposition. *)
	      wmax := 0.0; (* Edit the singular values, given TOL, from here ... *)
	      FOR j := 1 TO ma DO 
	         IF w^[j-1] > wmax THEN 
	            wmax := w^[j-1]
	         END
	      END; 
	      thresh := tol*wmax; 
	      FOR j := 1 TO ma DO (* ...to here. *)
	         IF w^[j-1] < thresh THEN 
	            w^[j-1] := 0.0
	         END
	      END; 
	      SVBKSB(U, W, V, B, A); 
	      chisq := 0.0; (* Evaluate chi-square. *)
	      FOR i := 1 TO ndata DO 
	         func(x^[i-1], AFUNC); 
	         sum := 0.0; 
	         FOR j := 1 TO ma DO 
	            sum := sum+a^[j-1]*afunc^[j-1]
	         END; 
	         chisq := chisq+(((y^[i-1]-sum)/sig^[i-1])*((y^[i-1]-sum)/sig^[i-1]))
	      END; 
	   ELSE
	      Error('SVDFit', 'Not enough memory.');
	   END;
      IF AFUNC # NilVector THEN DisposeVector(AFUNC); END;
      IF B # NilVector THEN DisposeVector(B); END;
   END SVDFit; 

   PROCEDURE SVDVar(V: Matrix; 
                    W: Vector; 
                    CVM: Matrix); 
      VAR 
         k, j, i, n, m, nw, na, ma: INTEGER; 
         sum: REAL; 
         w, wti: PtrToReals;
         WTI: Vector;
         cvm, v: PtrToLines; 
   BEGIN 
      GetMatrixAttr(V, n, m, v);
      GetVectorAttr(W, nw, w);
      GetMatrixAttr(CVM, na, ma, cvm);
      IF WTI # NilVector THEN
	      CreateVector(n, WTI, wti);
	      FOR i := 1 TO ma DO 
	         wti^[i-1] := 0.0; 
	         IF w^[i-1] <> 0.0 THEN 
	            wti^[i-1] := 1.0/(w^[i-1]*w^[i-1])
	         END
	      END; 
	      FOR i := 1 TO ma DO 
   (*
     Sum contributions to covariance matrix (14.3.20).
   *)
	         FOR j := 1 TO i DO 
	            sum := 0.0; 
	            FOR k := 1 TO ma DO 
	               sum := sum+v^[i-1]^[k-1]*v^[j-1]^[k-1]*wti^[k-1]
	            END; 
	            cvm^[i-1]^[j-1] := sum; 
	            cvm^[j-1]^[i-1] := sum
	         END
	      END; 
	      DisposeVector(WTI);
	   ELSE
	      Error('SVDVar', 'Not enough memory.');
	   END;
   END SVDVar; 

END LLSs.
