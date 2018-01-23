(* BEGINENVIRON
CONST
   np =
   mp =
   nn =
TYPE
   RealArrayNN = ARRAY [1..nn] OF real;
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
ENDENVIRON *)
PROCEDURE splie2(VAR x1a,x2a: RealArrayNN;
                      VAR ya: RealArrayMPbyNP;
                         m,n: integer;
                     VAR y2a: RealArrayMPbyNP);
VAR
   k,j: integer;
   ytmp,y2tmp: ^RealArrayNN;
BEGIN
   new(ytmp);
   new(y2tmp);
   FOR j := 1 TO m DO BEGIN
      FOR k := 1 TO n DO ytmp^[k] := ya[j,k];
      spline(x2a,ytmp^,n,1.0e30,1.0e30,y2tmp^);
      FOR k := 1 TO n DO y2a[j,k] := y2tmp^[k]
   END;
   dispose(y2tmp);
   dispose(ytmp)
END;
