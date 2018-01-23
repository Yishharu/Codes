IMPLEMENTATION MODULE TRED2M;

   FROM NRMath IMPORT Sqrt;
   FROM NRIO   IMPORT Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,  
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   VAR 
      l, k, j, i, n, nD, nE, mA: INTEGER; 
      scale, hh, h, g, f: REAL; 
      a: PtrToLines;
      d, e: PtrToReals;

   PROCEDURE sign(a, b: REAL): REAL; 
   BEGIN 
      IF b < 0.0 THEN 
         RETURN -ABS(a)
      ELSE 
         RETURN ABS(a)
      END; 
   END sign; 

   PROCEDURE TRED2(A:     Matrix; 
                   DD, E: Vector); 

   BEGIN 
      GetMatrixAttr(A, n, mA, a);
      GetVectorAttr(DD, nD, d);
      GetVectorAttr(E, nE, e);
      FOR i := n-1 TO 1 BY -1 DO 
         l := i-1; 
         h := 0.0; 
         scale := 0.0; 
         IF l > 0 THEN 
            FOR k := 0 TO l DO 
               scale := scale+ABS(a^[i]^[k])
            END; 
            IF scale = 0.0 THEN (* Skip transformation. *)
               e^[i] := a^[i]^[l]
            ELSE 
               FOR k := 0 TO l DO 
                  a^[i]^[k] := a^[i]^[k]/scale; (* Use scaled a's for transformation. *)
                  h := h+(a^[i]^[k]*a^[i]^[k])(* Form sigma in H. *)
               END; 
               f := a^[i]^[l]; 
               g := -sign(Sqrt(h), f); 
               e^[i] := scale*g; 
               h := h-f*g; (* Now h is equation (11.2.4). *)
               a^[i]^[l] := f-g; (* Store u in the ith row of A. *)
               f := 0.0; 
               FOR j := 0 TO l DO 
				   (*
				     Next statement can be omitted if eigenvectors not wanted.
				   *)
                  a^[j]^[i] := a^[i]^[j]/h; (* Store u/H in ith column of A. *)
                  g := 0.0; (* Form an element of A u in g. *)
                  FOR k := 0 TO j DO 
                     g := g+a^[j]^[k]*a^[i]^[k]
                  END; 
                  FOR k := j+1 TO l DO 
                     g := g+a^[k]^[j]*a^[i]^[k]
                  END; 
                  e^[j] := g/h; (* Form element of f in
                                   temporarily unused element of E. *)
                  f := f+e^[j]*a^[i]^[j]
               END; 
               hh := f/(h+h); (* Form K, equation (11.2.11). *)
               FOR j := 0 TO l DO (* Form qbf and store in E overwriting
                                     f. *)
                  f := a^[i]^[j]; (* Note that E[l]=E[i-1] survives. *)
                  g := e^[j]-hh*f; 
                  e^[j] := g; 
                  FOR k := 0 TO j DO (* Reduce A, equation (11.2.13). *)
                     a^[j]^[k] := a^[j]^[k]-f*e^[k]-g*a^[i]^[k]
                  END
               END
            END
         ELSE 
            e^[i] := a^[i]^[l]
         END; 
         d^[i] := h
      END; 
	   (*
	     Next statement can be omitted if eigenvectors not wanted.
	   *)
      d^[0] := 0.0; 
      e^[0] := 0.0; 
	   (*
	     Contents of following FOR i := 1 TO n loop can be omitted if eigenvectors
	     not wanted, except for the statement d[i] := a[i,i];.
	   *)
      FOR i := 0 TO n-1 DO (* Begin accumulation of transformation matrices. *)
         l := i-1; 
         IF d^[i] <> 0.0 THEN (* This block skipped when I=1. *)
            FOR j := 0 TO l DO 
               g := 0.0; 
               FOR k := 0 TO l DO (* Use u and u/H stored in A to form P Q. *)
                  g := g+a^[i]^[k]*a^[k]^[j]
               END; 
               FOR k := 0 TO l DO 
                  a^[k]^[j] := a^[k]^[j]-g*a^[k]^[i]
               END
            END
         END; 
         d^[i] := a^[i]^[i]; (* This statement remains. *)
         a^[i]^[i] := 1.0; (* Reset row and column of A to
                              identity matrix for next iteration. *)
         FOR j := 0 TO l DO 
            a^[i]^[j] := 0.0; 
            a^[j]^[i] := 0.0
         END
      END
   END TRED2; 

END TRED2M.
