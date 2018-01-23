IMPLEMENTATION MODULE ElmHesM;

   FROM NRIO   IMPORT Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,  
                      NilMatrix, PtrToLines;

   PROCEDURE ElmHes(VAR A: Matrix); 
      VAR 
         m, j, i, n, mA: INTEGER; 
         y, x: REAL; 
         a: PtrToLines;
   BEGIN 
      GetMatrixAttr(A, n, mA, a);(* m is called r+1 in the text. *)
      FOR m := 1 TO n-2 DO 
         x := 0.0; 
         i := m; 
         FOR j := m TO n-1 DO (* Find the pivot. *)
            IF ABS(a^[j]^[m-1]) > ABS(x) THEN 
               x := a^[j]^[m-1]; 
               i := j
            END
         END; 
         IF i <> m THEN (* Interchange rows and columns. *)
            FOR j := m-1 TO n-1 DO 
               y := a^[i]^[j]; 
               a^[i]^[j] := a^[m]^[j]; 
               a^[m]^[j] := y
            END; 
            FOR j := 0 TO n-1 DO 
               y := a^[j]^[i]; 
               a^[j]^[i] := a^[j]^[m]; 
               a^[j]^[m] := y
            END
         END; 
         IF x <> 0.0 THEN (* Carry out the elimination. *)
            FOR i := m+1 TO n-1 DO 
               y := a^[i]^[m-1]; 
               IF y <> 0.0 THEN 
                  y := y/x; 
                  a^[i]^[m-1] := y; 
                  FOR j := m TO n-1 DO 
                     a^[i]^[j] := a^[i]^[j]-y*a^[m]^[j]
                  END; 
                  FOR j := 0 TO n-1 DO 
                     a^[j]^[m] := a^[j]^[m]+y*a^[j]^[i]
                  END
               END
            END
         END
      END
   END ElmHes; 

END ElmHesM.
