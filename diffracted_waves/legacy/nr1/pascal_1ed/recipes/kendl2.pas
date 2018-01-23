(* BEGINENVIRON
CONST
   ip =
   jp =
TYPE
   RealArrayIPbyJP = ARRAY [1..ip,1..jp] OF real;
ENDENVIRON *)
PROCEDURE kendl2(VAR tab: RealArrayIPbyJP;
                     i,j: integer;
          VAR tau,z,prob: real);
VAR
   nn,mm,m2,m1,lj,li,l,kj,ki,k: integer;
   svar,s,points,pairs,en2,en1: real;
BEGIN
   en1 := 0.0;
   en2 := 0.0;
   s := 0.0;
   nn := i*j;
   points := tab[i,j];
   FOR k := 0 TO nn-2 DO BEGIN
      ki := k DIV j;
      kj := k-j*ki;
      points := points+tab[ki+1,kj+1];
      FOR l := k+1 TO nn-1 DO BEGIN
         li := l DIV j;
         lj := l-j*li;
         m1 := li-ki;
         m2 := lj-kj;
         mm := m1*m2;
         pairs := tab[ki+1,kj+1]*tab[li+1,lj+1];
         IF mm <> 0 THEN BEGIN
            en1 := en1+pairs;
            en2 := en2+pairs;
            IF mm > 0 THEN
               s := s+pairs
            ELSE
               s := s-pairs
         END
         ELSE BEGIN
            IF m1 <> 0 THEN en1 := en1+pairs;
            IF m2 <> 0 THEN en2 := en2+pairs
         END
      END
   END;
   tau := s/sqrt(en1*en2);
   svar := (4.0*points+10.0)/(9.0*points*(points-1.0));
   z := tau/sqrt(svar);
   prob := erfcc(abs(z)/1.4142136)
END;
