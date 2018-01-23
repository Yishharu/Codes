IMPLEMENTATION MODULE VanderM;

   FROM NRSystem IMPORT LongReal;
   FROM NRIO     IMPORT Error;
   FROM NRLVect  IMPORT LVector, DisposeLVector, PtrToLongReals, CreateLVector, 
                        GetLVectorAttr;

   PROCEDURE Vander(X, W, Q: LVector); 
      VAR 
         k1, k, j, i, n, nQ, nW: INTEGER; 
         xx, t, s, b: LongReal; 
         C: LVector; 
         c, x, q, w: PtrToLongReals;
   BEGIN 
      GetLVectorAttr(X, n, x);
      GetLVectorAttr(Q, nQ, q);
      GetLVectorAttr(W, nW, w);
      IF (n = nQ) AND (nQ = nW) THEN
	      CreateLVector(n, C, c); 
	      IF n = 1 THEN 
	         w^[0] := q^[0] 
	      ELSE 
	         FOR i := 0 TO n-1 DO (* Initialize array. *)
	            c^[i] := 0.0
	         END; 
	         c^[n-1] := -x^[0]; (* Coefficients of the master
                                polynomial are found by recursion. *)
	         FOR i := 1 TO n-1 DO 
	            xx := -x^[i]; 
	            FOR j := n-i-1 TO n-2 DO  
	               c^[j] := c^[j]+xx*c^[j+1]
	            END; 
	            c^[n-1] := c^[n-1]+xx
	         END; 
	         FOR i := 0 TO n-1 DO (* Each subfactor in turn *)
	            xx := x^[i]; 
	            t := 1.0; 
	            b := 1.0; 
	            s := q^[n-1]; 
	            k := n-1; 
	            FOR j := 1 TO n-1 DO (* is synthetically divided, *)
	               k1 := k-1; 
	               b := c^[k]+xx*b; 
	               s := s+q^[k1]*b; (* matrix-multiplied
                                    by the right-hand side, *)
	               t := xx*t+b; 
	               k := k1
	            END; 
	            w^[i] := s/t(* and supplied with a denominator. *)
	         END
	      END; 
	      DisposeLVector(C); 
	   ELSE
	      Error('Vander', 'Inproper input vectors!');
      END;
   END Vander; 

END VanderM.
