(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE kendl1(VAR data1,data2: RealArrayNP;
                               n: integer;
                  VAR tau,z,prob: real);
VAR
   n2,n1,k,j,is: integer;
   svar,aa,a2,a1: real;
BEGIN
   n1 := 0;
   n2 := 0;
   is := 0;
   FOR j := 1 TO n-1 DO BEGIN
      FOR k := j+1 TO n DO BEGIN
         a1 := data1[j]-data1[k];
         a2 := data2[j]-data2[k];
         aa := a1*a2;
         IF aa <> 0.0 THEN BEGIN
            n1 := n1+1;
            n2 := n2+1;
            IF aa > 0.0 THEN
               is := is+1
            ELSE
               is := is-1
         END
         ELSE BEGIN
            IF a1 <> 0.0 THEN n1 := n1+1;
            IF a2 <> 0.0 THEN n2 := n2+1
         END
      END
   END;
   tau := is/(sqrt(n1)*sqrt(n2));
   svar := (4.0*n+10.0)/(9.0*n*(n-1.0));
   z := tau/sqrt(svar);
   prob := erfcc(abs(z)/1.4142136)
END;
