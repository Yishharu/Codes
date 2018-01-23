MODULE XAnneal;

   FROM AnnealM IMPORT Anneal;
   FROM Uniform IMPORT Ran3;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                       Error;
   FROM NRIVect IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, GetIVectorAttr,
                       NilIVector;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                       NilVector;

   CONST 
      ncity = 10; 
   VAR 
      MetropJdum, idum, i, ii: INTEGER; 
      X, Y: Vector;
      x, y: PtrToReals; 
      IORDER: IVector;
      iorder: PtrToIntegers; 
       
BEGIN 
   CreateVector(ncity, X, x);
   CreateVector(ncity, Y, y);
   CreateIVector(ncity, IORDER, iorder);
   IF (X # NilVector) AND (Y # NilVector) AND (IORDER # NilIVector) THEN
	   MetropJdum := 1; 
	   idum := -1; 
	   FOR i := 1 TO ncity DO 
	      x^[i-1] := Ran3(idum); 
	      y^[i-1] := Ran3(idum); 
	      iorder^[i-1] := i
	   END; 
	   Anneal(X, Y, IORDER); 
	   WriteString('*** System Frozen ***'); WriteLn; 
	   WriteString('Final path:'); WriteLn; 
	   WriteString('   city      x         y'); WriteLn; 
	   FOR i := 1 TO ncity DO 
	      ii := iorder^[i-1]; 
	      WriteInt(ii, 4); 
	      WriteReal(x^[ii-1], 10, 4); 
	      WriteReal(y^[ii-1], 10, 4); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error("XAnneal", "Not enough memory.");
	END;
 IF (X # NilVector) THEN DisposeVector(X); END;
 IF (Y # NilVector) THEN DisposeVector(Y); END;
 IF (IORDER # NilIVector) THEN DisposeIVector(IORDER); END;

END XAnneal.
