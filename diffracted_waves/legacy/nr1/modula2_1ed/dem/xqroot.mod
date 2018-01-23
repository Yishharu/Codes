MODULE XQRoot; (* driver for routine Qroot *) 
 
   FROM LaguQ    IMPORT Qroot;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,
                        NilVector;

   CONST 
      n = 7; 
      nv = 3; 
      eps = 1.0E-6; 
      ntry = 10; 
      tiny = 1.0E-5; 
   VAR 
      i, j, nflag, nroot: INTEGER; 
      P, B, C: Vector; 
      p, b, c: PtrToReals;
       
BEGIN 
   CreateVector(n, P, p);
   CreateVector(ntry, B, b);
   CreateVector(ntry, C, c);
   IF (P # NilVector) AND (B # NilVector) AND (C # NilVector) THEN
	   p^[0] := 10.0; 
	   p^[1] := -18.0; 
	   p^[2] := 25.0; 
	   p^[3] := -24.0; 
	   p^[4] := 16.0; 
	   p^[5] := -6.0; 
	   p^[6] := 1.0; 
	   WriteLn; 
	   WriteString('P(x) := x^6-6x^5+16x^4-24x^3+25x^2-18x+10'); 
	   WriteLn; 
	   WriteString('Quadratic factors x^2+bx+c'); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('factor'); 
	   WriteString('         b'); 
	   WriteString('         c'); 
	   WriteLn; 
	   WriteLn; 
	   nroot := -1; 
	   FOR i := 0 TO ntry-1 DO 
	      c^[i] := 0.5*Float(i+1); 
	      b^[i] := -0.5*Float(i+1); 
	      Qroot(P, b^[i], c^[i], eps); 
	      IF nroot = -1 THEN 
	         WriteInt(nroot+1, 4); 
	         WriteString('   '); 
	         WriteReal(b^[i], 12, 6); 
	         WriteReal(c^[i], 12, 6); 
	         WriteLn; 
	         nroot := 0
	      ELSE 
	         nflag := 0; 
	         FOR j := 0 TO nroot DO 
	            IF (ABS(b^[i]-b^[j]) < tiny) AND (ABS(c^[i]-c^[j]) < tiny) THEN 
	               nflag := 1
	            END
	         END; 
	         IF nflag = 0 THEN 
	            WriteInt(nroot+1, 4); 
	            WriteString('   '); 
	            WriteReal(b^[i], 12, 6); 
	            WriteReal(c^[i], 12, 6); 
	            WriteLn; 
	            INC(nroot, 1)
	         END
	      END
	   END;
	   ReadLn;
	ELSE
	   Error('XQRoots', 'Not enough memory.');
	END;
   IF (P # NilVector) THEN DisposeVector(P) END;
   IF (B # NilVector) THEN DisposeVector(B) END;
   IF (C # NilVector) THEN DisposeVector(C) END;
END XQRoot.
