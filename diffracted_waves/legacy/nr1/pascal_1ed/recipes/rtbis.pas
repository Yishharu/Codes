(* BEGINENVIRON

FUNCTION fx(x: real): real;
ENDENVIRON *)
FUNCTION rtbis(x1,x2,xacc: real): real;
LABEL 99;
CONST
   jmax = 40;
VAR
   dx,f,fmid,xmid,rtb: real;
   j: integer;
BEGIN
   fmid := fx(x2);
   f := fx(x1);
   IF f*fmid >= 0.0 THEN BEGIN
      writeln('pause in RTBIS');
      writeln('Root must be bracketed for bisection.');
      readln
   END;
   IF f < 0.0 THEN BEGIN
      rtb := x1;
      dx := x2-x1
   END
   ELSE BEGIN
      rtb := x2;
      dx := x1-x2
   END;
   FOR j := 1 TO jmax DO BEGIN
      dx := dx*0.5;
      xmid := rtb+dx;
      fmid := fx(xmid);
      IF fmid <= 0.0 THEN rtb := xmid;
      IF (abs(dx) < xacc) OR (fmid = 0.0) THEN GOTO 99
   END;
   writeln('pause in RTBIS - too many bisections');
   readln;
99:
   rtbis := rtb
END;
