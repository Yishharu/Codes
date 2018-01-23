FUNCTION erfc(x: real): real;
BEGIN
   IF x < 0.0 THEN erfc := 1.0+gammp(0.5,sqr(x))
   ELSE erfc := gammq(0.5,sqr(x))
END;
