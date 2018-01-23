MODULE XSort3; (* driver for routine Sort3 *) 
 
   FROM IxRank   IMPORT Sort3;
   FROM NRSystem IMPORT Float;
   FROM NRMath   IMPORT Round;
   FROM NRIO     IMPORT File, Open, Close, GetEOL, GetReal, ReadLn,
                        WriteLn, WriteReal, WriteString, Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector, VectorPtr;

   CONST 
      nlen = 64; 
   TYPE 
      CharArray40 = ARRAY [0..39] OF CHAR; 
      CharArray24 = ARRAY [0..23] OF CHAR; 
      CharArrayNLEN = ARRAY [0..nlen-1] OF CHAR; 
   CONST
      np = 100;
   VAR 
      i, j: INTEGER; 
      A, B, C: Vector; 
      a, b, c: PtrToReals; 
      amsg1: CharArray40; 
      amsg2: CharArray24; 
      n1, n2: INTEGER; 
      amsg, bmsg, cmsg: CharArrayNLEN; 
      dataFile: File; 
       
BEGIN 
   CreateVector(nlen, A, a);
   CreateVector(nlen, B, b);
   CreateVector(nlen, C, c);
   IF (A # NilVector) AND (B # NilVector) AND (C # NilVector) THEN
	   amsg1 := "i'd rather have a bottle in front of me "; 
	   n1 := 39; 
	   amsg2 := 'than a frontal lobotomy.'; 
	   n2 := 23; 
	   FOR i := 0 TO n1 DO 
	      amsg[i] := amsg1[i]
	   END; 
	   FOR i := 0 TO n2 DO 
	      amsg[n1+i+1] := amsg2[i]
	   END; 
	   WriteLn; 
	   WriteString('original message:'); 
	   WriteLn; 
	   WriteString(amsg); 
	   WriteLn; (* read array of random numbers *) 
	   Open('tarray.dat', dataFile); 
	   GetEOL(dataFile); 
	   FOR i := 0 TO nlen-1 DO 
	      GetReal(dataFile, a^[i])
	   END; 
	   Close(dataFile); (* create array b and array c *) 
	   FOR i := 0 TO nlen-1 DO 
	      b^[i] := Float(i); 
	      c^[i] := Float(nlen-i-1);
	   END; (* sort array a while mixing ib and ic *) 
	   Sort3(A, B, C); (* scramble message according to array b *) 
	   FOR i := 0 TO nlen-1 DO 
	      j := Round(b^[i]); 
	      bmsg[i] := amsg[j]
	   END; 
	   WriteLn; 
	   WriteString('scrambled message:'); 
	   WriteLn; 
	   WriteString(bmsg); 
	   WriteLn; (* unscramble according to array c *) 
	   FOR i := 0 TO nlen-1 DO 
	      j := Round(c^[i]); 
	      cmsg[j] := bmsg[i]
	   END; 
	   WriteLn; 
	   WriteString('mirrored message:'); 
	   WriteLn; 
	   WriteString(cmsg); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XPikSrt', 'Not enough memory.');
	END;
	IF (A # NilVector) THEN DisposeVector(A); END;
	IF (B # NilVector) THEN DisposeVector(B); END;
	IF (C # NilVector) THEN DisposeVector(C); END;
END XSort3.
