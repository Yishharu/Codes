PROCEDURE qsimp(a,b: real;
              VAR s: real);
LABEL 99;
CONST
   eps = 1.0e-6;
   jmax = 20;
VAR
   j: integer;
   st,ost,os: real;
BEGIN
   ost := -1.0e30;
   os := -1.0e30;
   FOR j := 1 TO jmax DO BEGIN
      trapzd(a,b,st,j);
      s := (4.0*st-ost)/3.0;
      IF abs(s-os) < eps*abs(os) THEN GOTO 99;
      os := s;
      ost := st
   END;
   writeln ('pause in QSIMP - too many steps');
   readln;
99:
END;
