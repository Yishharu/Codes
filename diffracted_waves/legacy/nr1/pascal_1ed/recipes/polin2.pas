(* BEGINENVIRON
CONST
   mp =
   np =
TYPE
   RealArrayMP = ARRAY [1..mp] OF real;
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
ENDENVIRON *)
PROCEDURE polin2(VAR x1a: RealArrayMP;
                 VAR x2a: RealArrayNP;
                  VAR ya: RealArrayMPbyNP;
                     m,n: integer;
                   x1,x2: real;
                VAR y,dy: real);
VAR
   k,j: integer;
   ymtmp: ^RealArrayMP;
   yntmp: ^RealArrayNP;
BEGIN
   new(ymtmp);
   new(yntmp);
   FOR j := 1 TO m DO BEGIN
      FOR k := 1 TO n DO yntmp^[k] := ya[j,k];
      polint(x2a,yntmp^,n,x2,ymtmp^[j],dy)
   END;
   polint(x1a,ymtmp^,m,x1,y,dy);
   dispose(yntmp);
   dispose(ymtmp)
END;
