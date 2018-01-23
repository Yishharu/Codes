(* BEGINENVIRON
CONST
   np =
TYPE
   DoubleArrayNP = ARRAY [1..np] OF double;
ENDENVIRON *)
PROCEDURE vander(VAR x,w,q: DoubleArrayNP;
                         n: integer);
VAR
   k1,k,j,i: integer;
   xx,t,s,b: double;
   c: ^DoubleArrayNP;
BEGIN
   new(c);
   IF n = 1 THEN
      w[1] := q[1]
   ELSE BEGIN
      FOR i := 1 TO n DO c^[i] := 0.0;
      c^[n] := -x[1];
      FOR i := 2 TO n DO BEGIN
         xx := -x[i];
         FOR j := n+1-i TO n-1 DO
            c^[j] := c^[j]+xx*c^[j+1];
         c^[n] := c^[n]+xx
      END;
      FOR i := 1 TO n DO BEGIN
         xx := x[i];
         t := 1.0;
         b := 1.0;
         s := q[n];
         k := n;
         FOR j := 2 TO n DO BEGIN
            k1 := k-1;
            b := c^[k]+xx*b;
            s := s+q[k1]*b;
            t := xx*t+b;
            k := k1
         END;
         w[i] := s/t
      END
   END;
   dispose(c);
END;
