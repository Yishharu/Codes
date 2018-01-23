FUNCTION probks(alam: real): real;
LABEL 99;
CONST
   eps1 = 0.001;
   eps2 = 1.0e-8;
VAR
   a2,fac,sum,term,termbf: real;
   j: integer;
BEGIN
   a2 := -2.0*alam*alam;
   fac := 2.0;
   sum := 0.0;
   termbf := 0.0;
   FOR j := 1 TO 100 DO BEGIN
      term := fac*exp(a2*sqr(j));
      sum := sum+term;
      IF (abs(term) <= eps1*termbf) OR (abs(term) <= eps2*sum) THEN BEGIN
         probks := sum;
         GOTO 99
      END
      ELSE BEGIN
         fac := -fac;
         termbf := abs(term)
      END
   END;
   probks := 1.0;
99:
END;
