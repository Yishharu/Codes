MODULE XPolDiv; (* driver for routine PolDiv *) 
                (* (x-1)**5/(x+1)**3 *) 

   FROM PolRat   IMPORT PolDiv;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn,  ReadInt, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector;

   CONST 
      n = 6; 
      nv = 4; 
   VAR 
      i: INTEGER; 
      U, Q, R, V: Vector; 
      u, q, r, v: PtrToReals; 
BEGIN 
   CreateVector(n, U, u);
   CreateVector(n, Q, q);
   CreateVector(n, R, r);
   CreateVector(nv, V, v);
   IF (U # NilVector) AND (Q # NilVector) AND 
      (R # NilVector) AND (V # NilVector) THEN
	   u^[0] := -1.0; 
	   u^[1] := 5.0; 
	   u^[2] := -10.0; 
	   u^[3] := 10.0; 
	   u^[4] := -5.0; 
	   u^[5] := 1.0; 
	   v^[0] := 1.0; 
	   v^[1] := 3.0; 
	   v^[2] := 3.0; 
	   v^[3] := 1.0; 
	   PolDiv(U, V, Q, R); 
	   WriteLn; 
	   WriteString('       x^0       x^1       x^2'); 
	   WriteString('       x^3       x^4       x^5'); 
	   WriteLn; 
	   WriteString('quotient polynomial coefficients:'); 
	   WriteLn; 
	   FOR i := 0 TO 5 DO 
	      WriteReal(q^[i], 10, 2)
	   END; 
	   WriteLn; 
	   WriteString('expected quotient coefficients:'); 
	   WriteLn; 
	   WriteReal(31.0, 10, 2); 
	   WriteReal(-8.0, 10, 2); 
	   WriteReal(1.0, 10, 2); 
	   WriteReal(0.0, 10, 2); 
	   WriteReal(0.0, 10, 2); 
	   WriteReal(0.0, 10, 2); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('remainder polynomial coefficients:'); 
	   WriteLn; 
	   FOR i := 0 TO 3 DO 
	      WriteReal(r^[i], 10, 2)
	   END; 
	   WriteLn; 
	   WriteString('expected remainder coefficients:'); 
	   WriteLn; 
	   WriteReal(-32.0, 10, 2); 
	   WriteReal(-80.0, 10, 2); 
	   WriteReal(-80.0, 10, 2); 
	   WriteReal(0.0, 10, 2); 
	   WriteLn;
	   ReadLn;
	   IF (U # NilVector) THEN DisposeVector(U); END;
	   IF (Q # NilVector) THEN DisposeVector(Q); END;
	   IF (R # NilVector) THEN DisposeVector(R); END;
	   IF (V # NilVector) THEN DisposeVector(V); END;
	ELSE
      Error("XPolDiv", "Not enough memory.");
	END;
END XPolDiv.
