(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE locate(VAR xx: RealArrayNP;
                      n: integer;
                      x: real;
                  VAR j: integer);
VAR
   ju,jm,jl: integer;
   ascnd: boolean;
BEGIN
   ascnd := xx[n] > xx[1];
   jl := 0;
   ju := n+1;
   WHILE ju-jl > 1 DO BEGIN
      jm := (ju+jl) DIV 2;
      IF (x > xx[jm]) = ascnd THEN
         jl := jm
      ELSE ju := jm
   END;
   j := jl
END;
