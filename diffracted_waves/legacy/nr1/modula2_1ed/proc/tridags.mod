IMPLEMENTATION MODULE TridagS;

   FROM NRIO   IMPORT Error;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                      GetVectorAttr;

   PROCEDURE Tridag(A, B, C, R, U: Vector); 
      VAR 
         j, nA, nB, nC, nR, n:   INTEGER; 
         bet: REAL; 
         GAM: Vector; 
         a, b, c, r, u, gam: PtrToReals;
   BEGIN 
      GetVectorAttr(U, n,  u);
      GetVectorAttr(A, nA, a);
      GetVectorAttr(B, nB, b);
      GetVectorAttr(C, nC, c);
      GetVectorAttr(R, nR, r);
      IF (n = nA) AND (nA = nB) AND (nB = nC) AND (nC = nR) THEN
         CreateVector(n, GAM, gam); 
	      IF b^[0] = 0.0 THEN (* If this happens, you should rewrite
                              your equations as a set of order n-1, 
                              with u2 trivially eliminated. *)
	         Error('Tridag', ''); 
	      ELSE; 
		      bet := b^[0]; 
		      u^[0] := r^[0]/bet; 
		      FOR j := 1 TO n-1 DO (* Decomposition and forward substitution. *)
		         gam^[j] := c^[j-1]/bet; 
		         bet := b^[j]-a^[j]*gam^[j]; 
		         IF bet = 0.0 THEN 
		            Error('Tridag', ''); (* Algorithm fails; see below. *)
		         END; 
		         u^[j] := (r^[j]-a^[j]*u^[j-1])/bet
		      END; 
		      FOR j := n-2 TO 0 BY -1 DO (* Backsubstitution. *)
		         u^[j] := u^[j]-gam^[j+1]*u^[j+1]
		      END; 
		      DisposeVector(GAM)
		   END;
		ELSE
		   Error('Tridag', 'Inproper input vectors.');
		END;
   END Tridag; 

END TridagS.
