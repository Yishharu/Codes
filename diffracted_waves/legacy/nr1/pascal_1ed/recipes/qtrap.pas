PROCEDURE qtrap(a,b: real;
              VAR s: real);
LABEL 99;
CONST
   eps = 1.0e-6;
   jmax = 20;
VAR
   j: integer;
   olds: real;
BEGIN
   olds := -1.0e30;
   FOR j := 1 TO jmax DO BEGIN
      trapzd(a,b,s,j);
      IF abs(s-olds) < eps*abs(olds) THEN GOTO 99;
      olds := s
   END;
   writeln ('pause in QTRAP - too many steps');
   readln;
99:
END;
