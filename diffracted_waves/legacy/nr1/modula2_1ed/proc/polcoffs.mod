IMPLEMENTATION MODULE PolCoffs;

   FROM PolIntM  IMPORT PolInt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        GetVectorAttr, NilVector;

   PROCEDURE PolCoe(X, Y, COF: Vector); 
      VAR 
         k, j, i, n, ny, nCof: INTEGER; 
         phi, ff, b: REAL; 
         S: Vector;
         x, y, cof, s: PtrToReals; 
   BEGIN 
      GetVectorAttr(X, n, x);
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(COF, nCof, cof);
      IF (n = ny) AND (ny = nCof) THEN
         CreateVector(n, S, s);
	      FOR i := 0 TO n-1 DO 
	         s^[i] := 0.0; 
	         cof^[i] := 0.0
	      END; 
	      s^[n-1] := -x^[0]; 
	      FOR i := 1 TO n-1 DO (* Coefficients si of the master polynomial P(x)
                               are found by recurrence. *)
	         FOR j := n-i-1 TO n-2 DO 
	            s^[j] := s^[j]-x^[i]*s^[j+1]
	         END; 
	         s^[n-1] := s^[n-1]-x^[i]
	      END; 
	      FOR j := 0 TO n-1 DO 
	         phi := Float(n); 
	         FOR k := n-2 TO 0 BY -1 DO (* The quantity PHI =odj neq k
                                        (xj-xk) is found as a derivative of P(xj). *)
	            phi := Float(k+1)*s^[k+1]+x^[j]*phi
	         END; 
	         ff := y^[j]/phi; 
	         b := 1.0; (* Coefficients of polynomials in each term of
                       the Lagrange formula are found by synthetic division of P(x)
                       by (x-xj).  The solution Ck is accumulated. *)
	         FOR k := n-1 TO 0 BY -1 DO 
	            cof^[k] := cof^[k]+b*ff; 
	            b := s^[k]+x^[j]*b
	         END
	      END; 
	      DisposeVector(S)
	   ELSE
	      Error('PolCoe', 'Length of input vectors are different.');
	   END;
   END PolCoe; 

   PROCEDURE DisposeVectors(disposeWs:    BOOLEAN;
                            X, Y, W1, W2: Vector);
   BEGIN
      IF X # NilVector THEN DisposeVector(X) END;
      IF Y # NilVector THEN DisposeVector(Y) END;
      IF disposeWs THEN
         IF W1 # NilVector THEN DisposeVector(W1) END;
         IF W2 # NilVector THEN DisposeVector(W2) END;
      END;
   END DisposeVectors;

   PROCEDURE PolCof(XA, YA, COF: Vector); 
      VAR 
         k, j, i, n, nya, nCof: INTEGER; 
         xmin, dy: REAL; 
         X, Y, W1, W2: Vector;
         x, y, cof, xa, ya, w1, w2: PtrToReals; 
   BEGIN 
      GetVectorAttr(XA, n, xa);
      GetVectorAttr(YA, nya, ya);
      GetVectorAttr(COF, nCof, cof);
      IF (n = nya) AND (nya = nCof) THEN
	      CreateVector(n, X, x);
	      CreateVector(n, Y, y);
	      IF (X # NilVector) AND (Y # NilVector) THEN
		      FOR j := 0 TO n-1 DO 
		         x^[j] := xa^[j]; 
		         y^[j] := ya^[j]
		      END; 
		      FOR j := 0 TO n-1 DO 
	            CreateVector(n-j, W1, w1);
	            CreateVector(n-j, W2, w2);
	            IF (W1 # NilVector) AND (W2 # NilVector) THEN
		            FOR k := 0 TO n-j-1 DO
		               w1^[k] := x^[k];
		               w2^[k] := y^[k];
		            END;
			         PolInt(W1, W2, 0.0, cof^[j], dy); (* Polynomial interpolation routine of section 3.1. *)
		            FOR k := 0 TO n-j-1 DO
		               x^[k] := w1^[k];
		               y^[k] := w2^[k];
		            END;
		            DisposeVector(W1);
		            DisposeVector(W2);
		         ELSE
		            Error('PolCof', 'Not enough memory.');
		            DisposeVectors(TRUE, X, Y, W1, W2);
		            RETURN;
		         END;
	            xmin := 1.0E38; (* We extrapolate to x=0. *)
		         k := 0; 
		         FOR i := 0 TO n-j-1 DO (* Find the remaining xi of
                                     smallest absolute value, *)
		            IF ABS(x^[i]) < xmin THEN 
		               xmin := ABS(x^[i]); 
		               k := i
		            END; 
		            IF x^[i] <> 0.0 THEN (* (meanwhile reducing all the terms) *)
		               y^[i] := (y^[i]-cof^[j])/x^[i]
		            END
		         END; 
		         FOR i := k+1 TO n-j-1 DO (* and eliminate it. *)
		            y^[i-1] := y^[i]; 
		            x^[i-1] := x^[i]
		         END;
		      END; 
		      DisposeVector(X);
		      DisposeVector(Y);
         ELSE
            Error('PolCof', 'Not enough memory.');
            DisposeVectors(FALSE, X, Y, W1, W2);
         END;
         DisposeVectors(FALSE, X, Y, W1, W2);
	   ELSE
	      Error('PolCof', 'Length of input vectors are different.');
	   END;
   END PolCof; 

END PolCoffs.
