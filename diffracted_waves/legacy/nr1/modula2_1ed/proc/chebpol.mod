IMPLEMENTATION MODULE ChebPol;

   FROM NRIO   IMPORT Error;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr;

   PROCEDURE ChebPC(C, D: Vector); 
      VAR 
         k, j, n, nD: INTEGER; 
         sv: REAL; 
         DD: Vector;
         dd, c, d: PtrToReals; 
   BEGIN 
      GetVectorAttr(C, n, c);
      GetVectorAttr(D, nD, d);
      IF  (n = nD) THEN
	      CreateVector(n, DD, dd); 
	      FOR j := 0 TO n-1 DO 
	         d^[j] := 0.0; 
	         dd^[j] := 0.0
	      END; 
	      d^[0] := c^[n-1]; 
	      FOR j := n-2 TO 1 BY -1 DO 
	         FOR k := n-j TO 1 BY -1 DO 
	            sv := d^[k]; 
	            d^[k] := 2.0*d^[k-1]-dd^[k]; 
	            dd^[k] := sv
	         END; 
	         sv := d^[0]; 
	         d^[0] := -dd^[0]+c^[j]; 
	         dd^[0] := sv
	      END; 
	      FOR j := n-1 TO 1 BY -1 DO 
	         d^[j] := d^[j-1]-dd^[j]
	      END; 
	      d^[0] := -dd^[0]+0.5*c^[0]; 
	      DisposeVector(DD)
	   ELSE
	      Error('ChebPC', 'Lengths of input vectors are different.');
	   END;
   END ChebPC; 



   PROCEDURE PCShft(a, b: REAL; 
                    D:    Vector); 
      VAR 
         k, j, n: INTEGER; 
         fac, cnst: REAL; 
         d: PtrToReals;
   BEGIN 
      GetVectorAttr(D, n, d);
      cnst := 2.0/(b-a); 
      fac := cnst; 
      FOR j := 1 TO n-1 DO (* First we rescale by the factor cnst... *)
         d^[j] := d^[j]*fac; 
         fac := fac*cnst
      END; 
      cnst := 0.5*(a+b); (* ...which is then redefined as the desired shift. *)
      FOR j := 0 TO n-2 DO (* We accomplish the shift by synthetic division.
                              Synthetic division is a miracle of high-school algebra.  
                              If you never learned it, go do so.  You won't be sorry. *)
         FOR k := n-2 TO j BY -1 DO 
            d^[k] := d^[k]-cnst*d^[k+1]
         END
      END
   END PCShft; 

END ChebPol.
