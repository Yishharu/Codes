MODULE XKendl2; (* driver for routine Kendl2 *) 
                (* look for 'ones-after-zeros' in IRBit1 and IRBit2 sequences *) 

   FROM Correl2 IMPORT Kendl2;
   FROM RBits   IMPORT IRBit1, IRBit2;
   FROM NRMath  IMPORT Round;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                       WriteText, Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,
                       NilMatrix, PtrToLines;

   CONST
      ndat = 1000;
      i = 8;
      j = 8;
   TYPE
      CharArray3 = ARRAY [1..3] OF CHAR;
   VAR
      ifunc, k, l, m, n, twoton: INTEGER;
      prob, tau, z: REAL;
      TAB: Matrix;
      tab: PtrToLines;
      text: ARRAY [1..8] OF CharArray3;
      iseed: BITSET;
      result: INTEGER;

BEGIN
   CreateMatrix(i, j, TAB, tab);
   IF TAB # NilMatrix THEN
	   text[1] := '000';
	   text[2] := '001';
	   text[3] := '010';
	   text[4] := '011';
	   text[5] := '100';
	   text[6] := '101';
	   text[7] := '110';
	   text[8] := '111';
	   WriteString('Are ones followed by zeros and vice-versa'); WriteLn;
	   FOR ifunc := 1 TO 2 DO
         iseed := {};
         INCL(iseed, 2); INCL(iseed, 5);
         INCL(iseed, 7); INCL(iseed, 8);
         INCL(iseed, 11);
	      IF ifunc = 1 THEN
	         WriteString('test of IRBit1:'); WriteLn
	      ELSE
	         WriteString('test of IRBit2:'); WriteLn
	      END;
	      FOR k := 0 TO i-1 DO
	         FOR l := 0 TO j-1 DO
	            tab^[k]^[l] := 0.0
	         END
	      END;
	      FOR m := 1 TO ndat DO
	         k := 1;
	         twoton := 1;
	         FOR n := 0 TO 2 DO
	            IF ifunc = 1 THEN
	               result := VAL(INTEGER, IRBit1(iseed));
	               INC(k, result*twoton)
	            ELSE
	               result := VAL(INTEGER, IRBit2(iseed));
	               INC(k, result*twoton)
	            END;
	            twoton := 2*twoton
	         END;
	         l := 1;
	         twoton := 1; 
	         FOR n := 0 TO 2 DO 
	            IF ifunc = 1 THEN 
	               result := VAL(INTEGER, IRBit1(iseed));
	               INC(l, result*twoton)
	            ELSE 
	               result := VAL(INTEGER, IRBit2(iseed));
	               INC(l, result*twoton)
	            END; 
	            twoton := 2*twoton
	         END; 
	         tab^[k-1]^[l-1] := tab^[k-1]^[l-1]+1.0
	      END; 
	      Kendl2(TAB, tau, z, prob); 
	      WriteString('    '); 
	      FOR n := 1 TO 8 DO 
	         WriteText(text[n], 6)
	      END; 
	      WriteLn; 
	      FOR n := 1 TO 8 DO 
	         WriteText(text[n], 3); 
	         FOR m := 1 TO 8 DO 
	            WriteInt(Round(tab^[n-1]^[m-1]), 6)
	         END; 
	         WriteLn
	      END; 
	      WriteLn; 
	      WriteString('      kendall tau     std. dev.     probability'); 
	      WriteLn; 
	      WriteReal(tau, 15, 6); 
	      WriteReal(z, 15, 6); 
	      WriteReal(prob, 15, 6); 
	      WriteLn; 
	      WriteLn;
	   END;
	   ReadLn;
	   DisposeMatrix(TAB);
	ELSE
	   Error('XKendl2', 'Not enough memory.');
	END;
END XKendl2.
