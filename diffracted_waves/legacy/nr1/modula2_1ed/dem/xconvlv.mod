MODULE XConvlv; (* driver for routine Convlv *) 
 
   FROM ConvlvM IMPORT Convlv;
   FROM NRIO    IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString,
                       Error;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       GetVectorAttr, NilVector;

   CONST 
      n = 16; (* data array size *) 
      m = 9; (* response function dimension - must be odd *) 
      n2 = 32; (* n2=2*n *) 
      pi = 3.14159265; 
   VAR 
      i, isign, j: INTEGER; 
      cmp: REAL; 
      ans, data, respns, resp: PtrToReals; 
      ANS, DATA, RESPNS, RESP: Vector; 
       
BEGIN 
   CreateVector(n2, ANS, ans);
   CreateVector(n, DATA, data);
   CreateVector(n, RESPNS, respns);
   CreateVector(n, RESP, resp);
   IF (ANS # NilVector) AND (DATA # NilVector) AND (RESPNS # NilVector) AND
      (RESP # NilVector) THEN
	   FOR i := 1 TO n DO 
	      data^[i-1] := 0.0; 
	      IF (i >= (n DIV 2)-(n DIV 8)) AND (i <= (n DIV 2)+(n DIV 8)) THEN 
	         data^[i-1] := 1.0
	      END
	   END; 
	   FOR i := 1 TO m DO 
	      respns^[i-1] := 0.0; 
	      IF (i > 2) AND (i < 7) THEN 
	         respns^[i-1] := 1.0
	      END; 
	      resp^[i-1] := respns^[i-1]
	   END; 
	   isign := 1; 
	   Convlv(DATA, RESP, m, isign, ANS); (* compare with a direct convolution *) 
	   WriteString('  i'); 
	   WriteString('        Convlv'); 
	   WriteString('     Expected'); 
	   WriteLn; 
	   FOR i := 1 TO n DO 
	      cmp := 0.0; 
	      FOR j := 1 TO m DIV 2 DO 
	         cmp := cmp+data^[((i-j-1+n) MOD n)]*respns^[j]; 
	         cmp := cmp+data^[((i+j-1) MOD n)]*respns^[m-j]
	      END; 
	      cmp := cmp+data^[i-1]*respns^[0]; 
	      WriteInt(i, 3); 
	      WriteReal(ans^[i-1], 15, 6); 
	      WriteReal(cmp, 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XConvlv', 'Not enough memory.');
	END;
	IF (ANS # NilVector) THEN DisposeVector(ANS) END;
	IF (DATA # NilVector) THEN DisposeVector(DATA) END;
	IF (RESPNS # NilVector) THEN DisposeVector(RESPNS) END;
	IF (RESP # NilVector) THEN DisposeVector(RESP) END;
END XConvlv.
