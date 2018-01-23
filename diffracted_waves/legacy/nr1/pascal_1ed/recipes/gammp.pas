FUNCTION gammp(a,x: real): real;
VAR
   gamser,gammcf,gln: real;
BEGIN
   IF (x < 0.0) OR (a <= 0.0) THEN BEGIN
      writeln('pause in GAMMP - invalid arguments');
      readln
   END;
   IF x < a+1.0 THEN BEGIN
      gser(a,x,gamser,gln);
      gammp := gamser
   END
   ELSE BEGIN
      gcf(a,x,gammcf,gln);
      gammp := 1.0-gammcf
   END
END;
