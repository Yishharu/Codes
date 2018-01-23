(* BEGINENVIRON

FUNCTION fx(x: real): real;
ENDENVIRON *)
FUNCTION rtflsp(x1,x2,xacc: real): real;
LABEL 99;
CONST
   maxit = 30;
VAR
   xl,xh,swap,fl: real;
   dx,del,f,fh,rtf: real;
   j: integer;
BEGIN
   fl := fx(x1);
   fh := fx(x2);
   IF fl*fh > 0.0 THEN BEGIN
      writeln('pause in routine RTFLSP');
      writeln('Root must be bracketed for false position');
      readln
   END;
   IF fl < 0.0 THEN BEGIN
      xl := x1;
      xh := x2
   END
   ELSE BEGIN
      xl := x2;
      xh := x1;
      swap := fl;
      fl := fh;
      fh := swap
   END;
   dx := xh-xl;
   FOR j := 1 TO maxit DO BEGIN
      rtf := xl+dx*fl/(fl-fh);
      f := fx(rtf);
      IF f < 0.0 THEN BEGIN
         del := xl-rtf;
         xl := rtf;
         fl := f
      END
      ELSE BEGIN
         del := xh-rtf;
         xh := rtf;
         fh := f
      END;
      dx := xh-xl;
      IF (abs(del) < xacc) OR (f = 0.0) THEN
         GOTO 99
   END;
   writeln('pause in routine RTFLSP');
   writeln('maximum number of iterations exceeded');
   readln;
99:
   rtflsp := rtf
END;
