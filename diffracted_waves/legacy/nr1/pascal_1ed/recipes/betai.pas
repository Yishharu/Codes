FUNCTION betai(a,b,x: real): real;
VAR
   bt: real;
BEGIN
   IF (x < 0.0) OR (x > 1.0) THEN BEGIN
      writeln('pause in routine BETAI');
      readln
   END;
   IF (x = 0.0) OR (x = 1.0) THEN bt := 0.0
   ELSE bt := exp(gammln(a+b)-gammln(a)-gammln(b)
      +a*ln(x)+b*ln(1.0-x));
   IF x < (a+1.0)/(a+b+2.0) THEN
      betai := bt*betacf(a,b,x)/a
   ELSE
      betai := 1.0-bt*betacf(b,a,1.0-x)/b
END;
