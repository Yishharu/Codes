MODULE XCovSrt; (* driver for routine CovSrt *) 

   FROM LLSs     IMPORT CovSrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;

   CONST 
      ma = 10; 
      mfit = 5; 
   VAR 
      i, j: INTEGER; 
      COVAR: Matrix;
      LISTA: IVector;
      covar: PtrToLines; 
      lista: PtrToIntegers; 
BEGIN 
   CreateMatrix(ma, ma, COVAR, covar);
   CreateIVector(mfit, LISTA, lista);
   IF (COVAR # NilMatrix) AND (LISTA # NilIVector) THEN
	   FOR i := 1 TO ma DO 
	      FOR j := 1 TO ma DO 
	         covar^[i-1]^[j-1] := 0.0; 
	         IF (i <= 5) AND (j <= 5) THEN 
	            covar^[i-1]^[j-1] := Float(i+j-1);
	         END
	      END
	   END; 
	   WriteLn; 
	   WriteString('original matrix');  WriteLn; 
	   FOR i := 1 TO ma DO 
	      FOR j := 1 TO ma DO 
	         WriteReal(covar^[i-1]^[j-1], 4, 1)
	      END; 
	      WriteLn
	   END; 
	   WriteString(' press RETURN to continue...'); WriteLn; 
	   ReadLn; (* test 1 - spread by 2 *) 
	   WriteLn; 
	   WriteString('test #1 - spread by two'); WriteLn; 
	   FOR i := 1 TO mfit DO 
	      lista^[i-1] := 2*i
	   END; 
	   CovSrt(COVAR, ma, LISTA, mfit); 
	   FOR i := 1 TO ma DO 
	      FOR j := 1 TO ma DO 
	         WriteReal(covar^[i-1]^[j-1], 4, 1)
	      END; 
	      WriteLn
	   END; 
	   WriteString(' press RETURN to continue...'); WriteLn; 
	   ReadLn; (* test 2 - reverse *) 
	   WriteLn; 
	   WriteString('test #2 - reverse'); WriteLn; 
	   FOR i := 1 TO ma DO 
	      FOR j := 1 TO ma DO 
	         covar^[i-1]^[j-1] := 0.0; 
	         IF (i <= 5) AND (j <= 5) THEN 
	            covar^[i-1]^[j-1] := Float(i+j-1)
	         END
	      END
	   END; 
	   FOR i := 1 TO mfit DO 
	      lista^[i-1] := mfit+1-i
	   END; 
	   CovSrt(COVAR, ma, LISTA, mfit); 
	   FOR i := 1 TO ma DO 
	      FOR j := 1 TO ma DO 
	         WriteReal(covar^[i-1]^[j-1], 4, 1)
	      END; 
	      WriteLn
	   END; 
	   WriteString(' press RETURN to continue...'); WriteLn; 
	   ReadLn; (* test 3 - spread and reverse *) 
	   WriteLn; 
	   WriteString('test #3 - spread and reverse'); WriteLn; 
	   FOR i := 1 TO ma DO 
	      FOR j := 1 TO ma DO 
	         covar^[i-1]^[j-1] := 0.0; 
	         IF (i <= 5) AND (j <= 5) THEN 
	            covar^[i-1]^[j-1] := Float(i+j-1);
	         END
	      END
	   END; 
	   FOR i := 1 TO mfit DO 
	      lista^[i-1] := ma+2-2*i
	   END; 
	   CovSrt(COVAR, ma, LISTA, mfit); 
	   FOR i := 1 TO ma DO 
	      FOR j := 1 TO ma DO 
	         WriteReal(covar^[i-1]^[j-1], 4, 1)
	      END; 
	      WriteLn
	   END;
	   ReadLn
   ELSE
      Error('XCovSrt', 'Not enough memory.');
   END;
   IF COVAR # NilMatrix THEN DisposeMatrix(COVAR) END;
   IF LISTA # NilIVector THEN DisposeIVector(LISTA) END;
END XCovSrt.
