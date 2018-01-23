MODULE XCorrel; (* driver for routine Correl *) 
 
   FROM CorrelM IMPORT Correl;
   FROM NRIO    IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString,
                       Error;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       GetVectorAttr, NilVector;

   CONST 
      n = 64; 
      n2 = 128; (* n2=2*n *) 
      pi = 3.1415927; 
   VAR 
      i, j: INTEGER; 
      cmp: REAL; 
      DATA1, DATA2, ANS: Vector;
      data1, data2, ans: PtrToReals; 
       
BEGIN 
   CreateVector(n, DATA1, data1);
   CreateVector(n, DATA2, data2);
   CreateVector(n2, ANS, ans);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) AND (ANS # NilVector) THEN
	   FOR i := 1 TO n DO 
	      data1^[i-1] := 0.0; 
	      IF (i > (n DIV 2)-(n DIV 8)) AND (i < (n DIV 2)+(n DIV 8)) THEN 
	         data1^[i-1] := 1.0
	      END; 
	      data2^[i-1] := data1^[i-1]
	   END; 
	   Correl(DATA1, DATA2, n, ANS); (* calculate directly *) 
	   WriteString('  n'); 
	   WriteString('        Correl'); 
	   WriteString('      direct calc.'); 
	   WriteLn; 
	   FOR i := 0 TO 16 DO 
	      cmp := 0.0; 
	      FOR j := 1 TO n DO 
	         cmp := cmp+data1^[((i+j-1) MOD n)]*data2^[j-1]
	      END; 
	      WriteInt(i, 3); 
	      WriteReal(ans^[i], 15, 6); 
	      WriteReal(cmp, 15, 6); 
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('XCorrel', 'Not enough memory.');
	END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1) END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2) END;
	IF ANS # NilVector THEN DisposeVector(ANS) END;
END XCorrel.
