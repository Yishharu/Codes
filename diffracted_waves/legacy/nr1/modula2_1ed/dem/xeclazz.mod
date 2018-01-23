MODULE XEClazz; (* driver for routine EClazz *) 
 
   FROM EClasses IMPORT EClazz;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteString,  Error;
   FROM NRIVect  IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector,
                        NilIVector;

   CONST 
      n = 15; 
   VAR 
      i, j, k, lclas, nclass: INTEGER; 
      NF, NFLAG, NSAV: IVector;
      nf, nflag, nsav: PtrToIntegers; 

   PROCEDURE equiv(i, j: INTEGER): BOOLEAN; 
   BEGIN 
      IF i MOD 4 = j MOD 4 THEN 
         RETURN TRUE
      ELSE 
         RETURN FALSE
      END; 
   END equiv; 
    
BEGIN 
   CreateIVector(n, NF, nf);
   CreateIVector(n, NFLAG, nflag);
   CreateIVector(n, NSAV, nsav);
   IF (NF # NilIVector) AND (NFLAG # NilIVector) AND (NSAV # NilIVector) THEN
	   EClazz(NF, equiv); 
	   FOR i := 0 TO n-1 DO 
	      nflag^[i] := 1
	   END; 
	   WriteLn; 
	   WriteString('Numbers from 1-15 divided according to'); WriteLn; 
	   WriteString('their value modulo 4:'); WriteLn; 
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
	   Error('XEClazz', 'Not enough memory.');
	END;
	IF (NF # NilIVector) THEN DisposeIVector(NF); END;
   IF (NFLAG # NilIVector) THEN DisposeIVector(NFLAG); END;
   IF (NSAV # NilIVector) THEN DisposeIVector(NSAV); END;
END XEClazz.
