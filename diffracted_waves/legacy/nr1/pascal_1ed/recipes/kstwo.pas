(* BEGINENVIRON
CONST
   n12 =
TYPE
   RealArrayN12 = ARRAY [1..n12] OF real;
   RealArrayNP = RealArrayN12;
ENDENVIRON *)
PROCEDURE kstwo(VAR data1: RealArrayN12;
                       n1: integer;
                VAR data2: RealArrayN12;
                       n2: integer;
               VAR d,prob: real);
VAR
   i,j1,j2: integer;
   en1,en2,fn1,fn2,dt,d1,d2: real;
BEGIN
   sort(n1,data1);
   sort(n2,data2);
   en1 := n1;
   en2 := n2;
   j1 := 1;
   j2 := 1;
   fn1 := 0.0;
   fn2 := 0.0;
   d := 0.0;
   WHILE (j1 <= n1) AND (j2 <= n2) DO BEGIN
      d1 := data1[j1];
      d2 := data2[j2];
      IF d1 <= d2 THEN BEGIN
         fn1 := j1/en1;
         j1 := j1+1
      END;
      IF d2 <= d1 THEN BEGIN
         fn2 := j2/en2;
         j2 := j2+1
      END;
      dt := abs(fn2-fn1);
      IF dt > d THEN d := dt
   END;
   prob := probks(sqrt(en1*en2/(en1+en2))*d)
END;
