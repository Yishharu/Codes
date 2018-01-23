IMPLEMENTATION MODULE TQLIM;

   FROM NRMath   IMPORT Sqrt;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,  
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE sign(a, b: REAL): REAL; 
   BEGIN 
      IF b < 0.0 THEN 
         RETURN -ABS(a)
      ELSE 
         RETURN ABS(a)
      END; 
   END sign; 

   PROCEDURE TQLI(DD, E: Vector; 
                  Z:     Matrix); 
      VAR 
         m, l, iter, i, k, n, nD, nE, nZ, mZ: INTEGER; 
         s, r, p, g, f, dd, c, b: REAL; 
         d, e: PtrToReals;
         z: PtrToLines;
   BEGIN 
      GetVectorAttr(E, n, e);
      GetVectorAttr(DD, nD, d);
      GetMatrixAttr(Z, nZ, mZ, z);
      FOR i := 1 TO n-1 DO (* Renumber the elements of E for convenience. *)
         e^[i-1] := e^[i]
      END; 
      e^[n-1] := 0.0; 
      FOR l := 0 TO n-1 DO (* Look for a single small subdiagonal element to split
                              the matrix. *)
         iter := 0; 
         LOOP 
	         m := l;
	         LOOP
	            dd := ABS(d^[m])+ABS(d^[m+1]); 
	            IF ABS(e^[m])+dd = dd THEN EXIT; END;
	            INC(m);
	            IF (m = n-2) THEN 
	               m := n-1; 
	               EXIT; 
	            END;
	         END; 
	         IF m <> l THEN 
	            IF iter = 30 THEN 
	               Error('TQLI', 'too many iterations'); 
	            END; 
	            INC(iter); 
	            g := (d^[l+1]-d^[l])/(2.0*e^[l]); (* Form shift. *)
	            r := Sqrt(g*g+1.0); 
	            g := d^[m]-d^[l]+e^[l]/(g+sign(r, g)); (* This is dm-ks. *)
	            s := 1.0; 
	            c := 1.0; 
	            p := 0.0; 
	            FOR i := m-1 TO l BY -1 DO (* a plane rotation as in the original QL, followed
                                           by Givens rotations to restore tridiagonal form. *)
	               f := s*e^[i]; 
	               b := c*e^[i]; 
	               IF ABS(f) >= ABS(g) THEN 
	                  c := g/f; 
	                  r := Sqrt(c*c+1.0); 
	                  e^[i+1] := f*r; 
	                  s := 1.0/r; 
	                  c := c*s
	               ELSE 
	                  s := f/g; 
	                  r := Sqrt(s*s+1.0); 
	                  e^[i+1] := g*r; 
	                  c := 1.0/r; 
	                  s := s*c
	               END; 
	               g := d^[i+1]-p; 
	               r := (d^[i]-g)*s+2.0*c*b; 
	               p := s*r; 
	               d^[i+1] := g+p; 
	               g := c*r-b; 
					   (*
					     Following FOR loop can be omitted if eigenvectors not wanted.
					   *)
	               FOR k := 0 TO n-1 DO (* Form eigenvectors. *)
	                  f := z^[k]^[i+1]; 
	                  z^[k]^[i+1] := s*z^[k]^[i]+c*f; 
	                  z^[k]^[i] := c*z^[k]^[i]-s*f
	               END
	            END; 
	            d^[l] := d^[l]-p; 
	            e^[l] := g; 
	            e^[m] := 0.0; 
	         END;
	         IF m=l THEN EXIT; END;
         END;
      END
   END TQLI; 

END TQLIM.
