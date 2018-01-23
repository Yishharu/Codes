IMPLEMENTATION MODULE PolRat;

   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, PtrToReals, GetVectorAttr;

   PROCEDURE DDPoly(C:  Vector; 
                    x:   REAL; 
                    PD: Vector); 
      VAR 
         nnd, j, i, nc, nd: INTEGER; 
         cnst: REAL; 
         c, pd: PtrToReals;
   BEGIN 
      GetVectorAttr(C, nc, c);
      GetVectorAttr(PD, nd, pd);
      pd^[0] := c^[nc-1]; 
      FOR j := 1 TO nd-1 DO pd^[j] := 0.0 END; 
      FOR i := nc-2 TO 0 BY -1 DO 
         IF nd < nc-i THEN 
            nnd := nd
         ELSE 
            nnd := nc-i
         END; 
         FOR j := nnd-1 TO 1 BY -1 DO 
            pd^[j] := pd^[j]*x+pd^[j-1]
         END; 
         pd^[0] := pd^[0]*x+c^[i]
      END; 
      cnst := 2.0; 
	   (*
	     After the first derivative, factorial constants
	     come in.
	   *)
      FOR i := 2 TO nd-1 DO 
         pd^[i] := cnst*pd^[i]; 
         cnst := cnst*Float(i+1)
      END
   END DDPoly; 

   PROCEDURE PolDiv(U, V, Q, R: Vector); 
      VAR 
         k, j, n, nv, nq, nr: INTEGER; 
         u, v, q, r: PtrToReals;
   BEGIN 
      GetVectorAttr(U, n, u);
      GetVectorAttr(V, nv, v);
      GetVectorAttr(Q, nq, q);
      GetVectorAttr(R, nr, r);
      IF (nr = n) AND (nq = n) THEN
	      FOR j := 0 TO n-1 DO 
	         r^[j] := u^[j]; 
	         q^[j] := 0.0
	      END; 
	      FOR k := n-nv-1 TO -1 BY -1 DO 
	         q^[k+1] := r^[nv+k]/v^[nv-1]; 
	         FOR j := nv+k-1 TO k+1 BY -1 DO 
	            r^[j] := r^[j]-q^[k+1]*v^[j-k-1]
	         END
	      END; 
	      FOR j := nv-1 TO n-1 DO 
	         r^[j] := 0.0
	      END
	   ELSE
	      Error('PolDiv', 'Inproper input vectors.');
	   END;
   END PolDiv; 

END PolRat.
