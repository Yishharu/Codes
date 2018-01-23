FUNCTION bessj(n: integer;
               x: real): real;
CONST
   iacc = 40;
   bigno = 1.0e10;
   bigni = 1.0e-10;
VAR
   bj,bjm,bjp,sum,tox,ans: real;
   j,jsum,m: integer;
BEGIN
   IF n < 2 THEN BEGIN
      writeln('pause in BESSJ');
      readln
   END;
   IF x = 0.0 THEN ans := 0.0
   ELSE IF abs(x) > 1.0*n THEN BEGIN
      tox := 2.0/abs(x);
      bjm := bessj0(abs(x));
      bj := bessj1(abs(x));
      FOR j := 1 TO n-1 DO BEGIN
         bjp := j*tox*bj-bjm;
         bjm := bj;
         bj := bjp
      END;
      ans := bj
   END
   ELSE BEGIN
      tox := 2.0/abs(x);
      m := 2*((n+trunc(sqrt(1.0*(iacc*n)))) DIV 2);
      ans := 0.0;
      jsum := 0;
      sum := 0.0;
      bjp := 0.0;
      bj := 1.0;
      FOR j := m DOWNTO 1 DO BEGIN
         bjm := j*tox*bj-bjp;
         bjp := bj;
         bj := bjm;
         IF abs(bj) > bigno THEN BEGIN
            bj := bj*bigni;
            bjp := bjp*bigni;
            ans := ans*bigni;
            sum := sum*bigni
         END;
         IF jsum <> 0 THEN sum := sum+bj;
         jsum := 1-jsum;
         IF j = n THEN ans := bjp
      END;
      sum := 2.0*sum-bj;
      ans := ans/sum
   END;
   IF (x < 0.0) AND odd(n) THEN ans := -ans;
   bessj := ans
END;
