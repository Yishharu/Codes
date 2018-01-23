(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
FUNCTION func(x: real): real;
ENDENVIRON *)
PROCEDURE ksone(VAR data: RealArrayNP;
                       n: integer;
              VAR d,prob: real);
VAR
   j: integer;
   fo,fn,ff,en,dt: real;
BEGIN
   sort(n,data);
   en := n;
   d := 0.0;
   fo := 0.0;
   FOR j := 1 TO n DO BEGIN
      fn := j/en;
      ff := func(data[j]);
      IF abs(fo-ff) > abs(fn-ff) THEN
         dt := abs(fo-ff)
      ELSE
         dt := abs(fn-ff);
      IF dt > d THEN d := dt;
      fo := fn
   END;
   prob := probks(sqrt(en)*d)
END;
