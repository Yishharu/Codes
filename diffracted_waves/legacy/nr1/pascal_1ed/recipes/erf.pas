FUNCTION erf(x: real): real;
BEGIN
   IF x < 0.0 THEN erf := -gammp(0.5,sqr(x))
   ELSE erf := gammp(0.5,sqr(x))
END;
