FUNCTION bessi(n: integer;
               x: real): real;
CONST
   iacc = 40;
   bigno = 1.0e10;
   bigni = 1.0e-10;
VAR
   bi,bim,bip,tox,ans: real;
   j,m: integer;
BEGIN
   IF n < 2 THEN BEGIN
      writeln('pause in routine BESSI');
      writeln('index n is less than 2');
      readln
   END;
   IF x = 0.0 THEN bessi := 0.0 ELSE BEGIN
      ans := 0.0;
      tox := 2.0/abs(x);
      bip := 0.0;
      bi := 1.0;
      m := 2*(n+trunc(sqrt(iacc*n)));
      FOR j := m DOWNTO 1 DO BEGIN
         bim := bip+j*tox*bi;
         bip := bi;
         bi := bim;
         IF abs(bi) > bigno THEN BEGIN
            ans := ans*bigni;
            bi := bi*bigni;
            bip := bip*bigni
         END;
         IF j = n THEN ans := bip
      END;
      IF (x < 0.0) AND odd(n) THEN ans := -ans;
      bessi := ans*bessi0(x)/bi
   END
END;
