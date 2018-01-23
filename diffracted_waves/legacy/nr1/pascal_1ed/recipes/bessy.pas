FUNCTION bessy(n: integer;
               x: real): real;
VAR
   by,bym,byp,tox: real;
   j: integer;
BEGIN
   IF n < 2 THEN BEGIN
      writeln('pause in BESSY - index n less than 2');
      readln
   END;
   tox := 2.0/x;
   by := bessy1(x);
   bym := bessy0(x);
   FOR j := 1 TO n-1 DO BEGIN
      byp := j*tox*by-bym;
      bym := by;
      by := byp
   END;
   bessy := by
END;
