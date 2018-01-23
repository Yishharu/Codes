(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   IntegerArrayNP = ARRAY [1..np] OF integer;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE lubksb(VAR a: RealArrayNPbyNP;
                     n: integer;
              VAR indx: IntegerArrayNP;
                 VAR b: RealArrayNP);
VAR
   j,ip,ii,i: integer;
   sum: real;
BEGIN
   ii := 0;
   FOR i := 1 TO n DO BEGIN
      ip := indx[i];
      sum := b[ip];
      b[ip] := b[i];
      IF ii <> 0 THEN
         FOR j := ii TO i-1 DO
            sum := sum-a[i,j]*b[j]
      ELSE IF sum <> 0.0 THEN
         ii := i;
      b[i] := sum
   END;
   FOR i := n DOWNTO 1 DO BEGIN
      sum := b[i];
      FOR j := i+1 TO n DO
         sum := sum-a[i,j]*b[j];
      b[i] := sum/a[i,i]
   END
END;
