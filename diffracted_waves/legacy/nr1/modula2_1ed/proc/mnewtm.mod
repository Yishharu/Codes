IMPLEMENTATION MODULE MNewtM;

   FROM LUDecomp IMPORT LUDCMP, LUBKSB;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, DisposeMatrix, CreateMatrix, GetMatrixAttr,  
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr, 
                        NilVector;

   PROCEDURE DisposeAll(BETA: Vector; INDX: IVector; ALPHA: Matrix);
   BEGIN
      IF (BETA # NilVector) THEN DisposeVector(BETA) END;
      IF (INDX # NilIVector) THEN DisposeIVector(INDX) END;
      IF (ALPHA # NilMatrix) THEN DisposeMatrix(ALPHA) END; 
   END DisposeAll;

   PROCEDURE MNewt(usrfun:     Coefficients;
                   ntrial:     INTEGER; 
                   X:          Vector; 
                   tolx, tolf: REAL); 
        VAR 
         k, i, n: INTEGER; 
         errx, errf, d: REAL; 
         BETA: Vector; 
         ALPHA: Matrix; 
         INDX: IVector; 
         beta, x: PtrToReals; 
         alpha: PtrToLines; 
         indx: PtrToIntegers; 
   BEGIN 
      GetVectorAttr(X, n, x);
      CreateVector(n, BETA, beta);
      CreateIVector(n, INDX, indx);
      CreateMatrix(n, n, ALPHA, alpha);
      IF (BETA # NilVector) AND (ALPHA # NilMatrix) AND (INDX # NilIVector) THEN
	      FOR k := 1 TO ntrial DO 
	         usrfun(X, ALPHA, BETA); (* User function supplies matrix coefficients. *)
	         errf := 0.0; (* Check function convergence. *)
	         FOR i := 0 TO n-1 DO 
	            errf := errf+ABS(beta^[i])
	         END; 
	         IF errf <= tolf THEN 
	            DisposeAll(BETA, INDX, ALPHA); 
	            RETURN;
	         END; 
	         LUDCMP(ALPHA, INDX, d); (* Solve linear
                                     equations using LU decomposition. *)
	         LUBKSB(ALPHA, INDX, BETA); 
	         errx := 0.0; (* Check root convergence. *)
	         FOR i := 0 TO n-1 DO (* Update solution. *)
	            errx := errx+ABS(beta^[i]); 
	            x^[i] := x^[i]+beta^[i]
	         END; 
	         IF errx <= tolx THEN 
	            DisposeAll(BETA, INDX, ALPHA); 
	            RETURN;
	         END
	      END; 
	      DisposeAll(BETA, INDX, ALPHA); 
	   ELSE
	      Error('MNewt', 'Inproper input data.');
      END;
   END MNewt; 
END MNewtM.
