IMPLEMENTATION MODULE ToeplzM;

   FROM NRIO     IMPORT Error;
   FROM NRSystem IMPORT LongReal, D, S;
   FROM NRMatr   IMPORT Matrix, GetMatrixAttr, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        GetVectorAttr, VectorPtr;

   PROCEDURE Toeplz(R, X, Y: Vector); 
      VAR 
         m2, m1, m, k, j, n, nY, nR: INTEGER; 
         sxn, shn, sgn, sgd, sd, qt2, qt1, qq, pt2, pt1, pp: LongReal; 
         G, H: Vector;
         g, h, r, x, y: PtrToReals; 
   BEGIN 
      GetVectorAttr(X, n, x);
      GetVectorAttr(Y, nY, y);
      GetVectorAttr(R, nR, r);
      IF (n = nY) AND (nR = 2*n-1) THEN
         IF (r^[n-1] # 0.0) THEN
				x^[0] := y^[0]/r^[n-1]; (* Initialize for the recursion. *)
	         IF (n # 1) THEN
			      CreateVector(n, G, g);
			      CreateVector(n, H, h);
			      g^[0] := r^[n-2]/r^[n-1]; 
			      h^[0] := r^[n]/r^[n-1]; 
	            m := 0;
			      LOOP  (* Main loop over the recursion. *)
			         m1 := m+1; 
			         sxn := D(-y^[m1]); (* Compute numerator and denominator for x, *)
			         sd := D(-r^[n-1]);
			         FOR j := 0 TO m DO
			            sxn := sxn+D(r^[n-1+m1-j])*D(x^[j]);
			            sd := sd+D(r^[n-1+m1-j])*D(g^[m-j])
			         END;
			         IF sd = 0.0 THEN
					      Error('Toeplz',
					      'Levinson method fails. Matrix has a singular principal minor');
					      DisposeVector(G);
					      DisposeVector(H);
					      EXIT;
			         END;
			         x^[m1] := S(sxn/sd); (* whence x. *)
			         FOR j := 0 TO m DO
			            x^[j] := x^[j]-x^[m1]*g^[m-j]
			         END;
			         IF m1 = n-1 THEN
					      DisposeVector(G);
					      DisposeVector(H);
					      EXIT;
			         END; 
			         sgn := D(-r^[n-1-m1-1]); (* Compute numerator and denominator
                                     for G and H, *)
			         shn := D(-r^[n-1+m1+1]);
			         sgd := D(-r^[n-1]);
			         FOR j := 0 TO m DO
			            sgn := sgn+D(r^[n-1+j-m1])*D(g^[j]);
			            shn := shn+D(r^[n-1+m1-j])*D(h^[j]);
			            sgd := sgd+D(r^[n-1+j-m1])*D(h^[m-j])
			         END;
			         IF (sd = 0.0) OR (sgd = 0.0) THEN
					      Error('Toeplz', 
					            'Levinson method fails. Matrix has a singular principal minor'); 
					      DisposeVector(G); 
					      DisposeVector(H);
					      EXIT;
			         END; 
			         g^[m1] := S(sgn/sgd); (* whence G and H. *)
			         h^[m1] := S(shn/sd);
			         k := m;
			         m2 := (m) DIV 2;
			         pp := D(g^[m1]);
			         qq := D(h^[m1]);
			         FOR j := 0 TO m2 DO 
			            pt1 := D(g^[j]);
			            pt2 := D(g^[k]);
			            qt1 := D(h^[j]);
			            qt2 := D(h^[k]);
			            g^[j] := S(pt1-pp*qt2);
			            g^[k] := S(pt2-pp*qt1);
			            h^[j] := S(qt1-qq*pt2);
			            h^[k] := S(qt2-qq*pt1);
			            DEC(k, 1)
			         END;
			         INC(m);
			         IF m = n-1 THEN 
					      Error('Toeplz', 'Should not arrive here!'); 
					      DisposeVector(G); 
					      DisposeVector(H);
			         END;
			      END; (* Back for another recurrence. *)
				END;
		   ELSE
		      Error('Toeplz', 
		            'Levinson method fails. Matrix has a singular principal minor'); 
		   END;
	   ELSE
	      Error('Toeplz', 'Inproper input vectors!');
	   END;
   END Toeplz; 

END ToeplzM.
