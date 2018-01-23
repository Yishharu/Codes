(* BEGINENVIRON
CONST
   np =
   nvp =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNV = ARRAY [1..nvp] OF real;
ENDENVIRON *)
PROCEDURE poldiv(VAR u: RealArrayNP;
                     n: integer;
                 VAR v: RealArrayNV;
                    nv: integer;
               VAR q,r: RealArrayNP);
VAR
   k,j: integer;
BEGIN
   FOR j := 1 TO n DO BEGIN
      r[j] := u[j];
      q[j] := 0.0
   END;
   FOR k := n-nv DOWNTO 0 DO BEGIN
      q[k+1] := r[nv+k]/v[nv];
      FOR j := nv+k-1 DOWNTO k+1 DO r[j] := r[j]-q[k+1]*v[j-k]
   END;
   FOR j := nv TO n DO
      r[j] := 0.0
END;
