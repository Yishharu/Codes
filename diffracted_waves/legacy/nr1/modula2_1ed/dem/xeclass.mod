MODULE XEClass; (* driver for routine EClass *) 

   FROM EClasses IMPORT EClass;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteString, Error;
   FROM NRIVect  IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector,  
                        NilIVector;

   CONST 
      m = 11; 
      n = 15; 
   VAR 
      i, j, k, lclas, nclass: INTEGER; 
      LISTA, LISTB, NF, NFLAG, NSAV: IVector;
      lista, listb, nf, nflag, nsav: PtrToIntegers; 
       
BEGIN 
   CreateIVector(m, LISTA, lista);
   CreateIVector(m, LISTB, listb);
   CreateIVector(n,  NF, nf);
   CreateIVector(n, NFLAG, nflag);
   CreateIVector(n, NSAV, nsav);
   IF (LISTA # NilIVector) AND (LISTB # NilIVector) AND (NF # NilIVector) AND 
      (NFLAG # NilIVector) AND (NSAV # NilIVector) THEN
	   lista^[0] := 1;  lista^[1] := 1;  lista^[2] := 5; 
	   lista^[3] := 2;  lista^[4] := 6;  lista^[5] := 2; 
	   lista^[6] := 7;  lista^[7] := 11; lista^[8] := 3; 
	   lista^[9] := 4;  lista^[10] := 12; 
	   listb^[0] := 5;  listb^[1] := 9;  listb^[2] := 13; 
	   listb^[3] := 6;  listb^[4] := 10; listb^[5] := 14; 
	   listb^[6] := 3;  listb^[7] := 7;  listb^[8] := 15; 
	   listb^[9] := 8;  listb^[10] := 4; 
	   EClass(NF, LISTA, LISTB); 
	   FOR i := 0 TO n-1 DO 
	      nflag^[i] := 1
	   END; 
	   WriteLn; 
	   WriteString('Numbers from 1-15 divided according to'); WriteLn; 
	   WriteString('their value modulo 4:'); WriteLn; 
	   WriteLn; 
	   lclas := 0; 
	   FOR i := 0 TO n-1 DO 
	      nclass := nf^[i]; 
	      IF nflag^[nclass-1] <> 0 THEN 
	         nflag^[nclass-1] := 0; 
	         INC(lclas, 1); 
	         k := -1; 
	         FOR j := i TO n-1 DO 
	            IF nf^[j] = nf^[i] THEN 
	               INC(k, 1); 
	               nsav^[k] := j+1
	            END
	         END; 
	         WriteString('Class'); 
	         WriteInt(lclas, 2); 
	         WriteString(':   '); 
	         FOR j := 0 TO k DO 
	            WriteInt(nsav^[j], 3)
	         END; 
	         WriteLn
	      END
	   END;
	   ReadLn;
	ELSE
	   Error('XEClass', 'Not enough memory.');
	END;
	IF (NF # NilIVector) THEN DisposeIVector(NF); END;
   IF (LISTA # NilIVector) THEN DisposeIVector(LISTA); END;
   IF (LISTB # NilIVector) THEN DisposeIVector(LISTB); END;
   IF (NFLAG # NilIVector) THEN DisposeIVector(NFLAG); END;
   IF (NSAV # NilIVector) THEN DisposeIVector(NSAV); END;
END XEClass.
