FUNCTION bessk(n: integer;
               x: real): real;
VAR
   tox,bkp,bkm,bk: real;
   j: integer;
BEGIN
   IF n < 2 THEN BEGIN
      writeln('pause in routine BESSK');
      writeln('index n less than 2');
      readln
   END;
   tox := 2.0/x;
   bkm := bessk0(x);
   bk := bessk1(x);
   FOR j := 1 TO n-1 DO BEGIN
      bkp := bkm+j*tox*bk;
      bkm := bk;
      bk := bkp
   END;
   bessk := bk
END;
