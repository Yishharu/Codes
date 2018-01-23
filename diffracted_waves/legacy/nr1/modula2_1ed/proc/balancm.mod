IMPLEMENTATION MODULE BalancM;

   FROM NRIO   IMPORT Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,  
                      NilMatrix, PtrToLines;

   PROCEDURE Balanc(VAR A: Matrix); 
      CONST 
         radix = 2.0; (* The constant radix should be the machine's 
                         floating point radix. *)
      VAR 
         last, j, i, n, mA: INTEGER; 
         s, r, g, f, c, sqrdx: REAL; 
         a: PtrToLines;
   BEGIN 
      GetMatrixAttr(A, n, mA, a);
      sqrdx := (radix*radix); 
      REPEAT 
         last := 1; 
         FOR i := 0 TO n-1 DO 
            c := 0.0; 
            r := 0.0; 
            FOR j := 0 TO n-1 DO 
               IF j <> i THEN 
                  c := c+ABS(a^[j]^[i]); 
                  r := r+ABS(a^[i]^[j]);
               END
            END; 
            IF (c <> 0.0) AND (r <> 0.0) THEN 
               g := r/radix; 
               f := 1.0; 
               s := c+r; 
               WHILE c < g DO 
                  f := f*radix; 
                  c := c*sqrdx
               END; 
               g := r*radix; 
               WHILE c > g DO 
                  f := f/radix; 
                  c := c/sqrdx
               END; 
               IF (c+r)/f < 0.95*s THEN 
                  last := 0; 
                  g := 1.0/f; 
                  FOR j := 0 TO n-1 DO 
                     a^[i]^[j] := a^[i]^[j]*g
                  END; 
                  FOR j := 0 TO n-1 DO 
                     a^[j]^[i] := a^[j]^[i]*f
                  END
               END
            END
         END; 
      UNTIL (last <> 0)
   END Balanc; 

END BalancM.
