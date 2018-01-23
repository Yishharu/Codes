(* BEGINENVIRON
CONST
   ncp =
   ndp =
TYPE
   IntegerArrayNC = ARRAY [1..ncp] OF integer;
   IntegerArrayND = ARRAY [1..ndp] OF integer;
ENDENVIRON *)
PROCEDURE ddpoly(VAR c: IntegerArrayNC;
                    nc: integer;
                     x: real;
                VAR pd: IntegerArrayND;
                    nd: integer);
VAR
   nnd,j,i: integer;
   cnst: real;
BEGIN
   pd[1] := c[nc];
   FOR j := 2 TO nd DO pd[j] := 0.0;
   FOR i := nc-1 DOWNTO 1 DO BEGIN
      IF nd < nc+1-i THEN nnd := nd ELSE nnd := nc+1-i;
      FOR j := nnd DOWNTO 2 DO pd[j] := pd[j]*x+pd[j-1];
      pd[1] := pd[1]*x+c[i]
   END;
   cnst := 2.0;
   FOR i := 3 TO nd DO BEGIN
      pd[i] := cnst*pd[i];
      cnst := cnst*i
   END
END;
