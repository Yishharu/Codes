(* BEGINENVIRON
CONST
   np =
   mp =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayMP = ARRAY [1..mp] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
ENDENVIRON *)
PROCEDURE svbksb(VAR u: RealArrayMPbyNP;
                 VAR w: RealArrayNP;
                 VAR v: RealArrayNPbyNP;
                   m,n: integer;
                 VAR b: RealArrayMP;
                 VAR x: RealArrayNP);
VAR
   jj,j,i: integer;
   s: real;
   tmp: ^RealArrayNP;
BEGIN
   new(tmp);
   FOR j := 1 TO n DO BEGIN
      s := 0.0;
      IF w[j] <> 0.0 THEN BEGIN
         FOR i := 1 TO m DO
            s := s+u[i,j]*b[i];
         s := s/w[j]
      END;
      tmp^[j] := s
   END;
   FOR j := 1 TO n DO BEGIN
      s := 0.0;
      FOR jj := 1 TO n DO
         s := s+v[j,jj]*tmp^[jj];
      x[j] := s
   END;
   dispose(tmp)
END;
