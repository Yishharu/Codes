(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   IntegerArrayNP = ARRAY [1..np] OF integer;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE mprove(VAR a,alud: RealArrayNPbyNP;
                          n: integer;
                   VAR indx: IntegerArrayNP;
                      VAR b: RealArrayNP;
                      VAR x: RealArrayNP);
VAR
   j,i: integer;
   sdp: double;
   r: ^RealArrayNP;
BEGIN
   new(r);
   FOR i := 1 TO n DO BEGIN
      sdp := -b[i];
      FOR j := 1 TO n DO
         sdp := sdp+a[i,j]*x[j];
      r^[i] := sdp
   END;
   lubksb(alud,n,indx,r^);
   FOR i := 1 TO n DO
      x[i] := x[i]-r^[i];
   dispose(r)
END;
