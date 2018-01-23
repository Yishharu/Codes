MODULE XVander; (* driver for routine Vander *)
 
   FROM VanderM  IMPORT Vander;
   FROM NRSystem IMPORT LongReal;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteLongReal,
                        WriteString, Error;
   FROM NRLVect  IMPORT LVector, DisposeLVector, PtrToLongReals, CreateLVector, 
                        GetLVectorAttr, NilLVector, LVectorPtr;

   CONST 
      n = 5; 
   VAR 
      i, j: INTEGER; 
      sum: LongReal; 
      Q, TERM, W, X: LVector;
      q, term, w, x: PtrToLongReals;

BEGIN 
   CreateLVector(n, Q, q);
   CreateLVector(n, TERM, term);
   CreateLVector(n, W, w);
   CreateLVector(n, X, x);
   IF ((Q # NilLVector) AND (TERM # NilLVector) AND (W # NilLVector) AND 
       (X # NilLVector)) THEN
	   x^[0] := 1.0;  x^[1] := 1.5;   x^[2] := 2.0;
	   x^[3] := 2.5;  x^[4] := 3.0; 
	   q^[0] := 1.0;   q^[1] := 1.5;    q^[2] := 2.0; 
	   q^[3] := 2.5;   q^[4] := 3.0; 
	   Vander(X, W, Q); 
	   WriteString('Solution vector:');
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      WriteString('    w^[');
	      WriteInt(i, 1); 
	      WriteString('] := '); 
	      WriteLongReal(w^[i], 12, 0);
	      WriteLn
	   END;
	   WriteLn;
	   WriteString('Test of solution vector:');
	   WriteLn;
	   WriteString("   mtrx*sol'n");
	   WriteString('   original');
	   WriteLn;
	   sum := 0.0;
	   FOR i := 0 TO n-1 DO
	      term^[i] := w^[i];
	      sum := sum+w^[i]
	   END;
	   WriteLongReal(sum, 12, 4);
	   WriteLongReal(q^[0], 12, 4);
	   WriteLn;
	   FOR i := 1 TO n-1 DO
	      sum := 0.0;
	      FOR j := 0 TO n-1 DO
	         term^[j] := term^[j]*x^[j];
	         sum := sum+term^[j];
	      END;
	      WriteLongReal(sum, 12, 4);
	      WriteLongReal(q^[i], 12, 4);
	      WriteLn;
	   END;
   ELSE
      Error('XVander', 'Not enough memory');
   END;
   IF Q # NilLVector    THEN DisposeLVector(Q); END;
   IF TERM # NilLVector THEN DisposeLVector(TERM); END;
   IF W # NilLVector    THEN DisposeLVector(W); END;
   IF X # NilLVector    THEN DisposeLVector(X); END;
	ReadLn;
END XVander.
