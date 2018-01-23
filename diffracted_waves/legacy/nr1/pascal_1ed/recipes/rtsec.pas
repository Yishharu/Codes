(* BEGINENVIRON

FUNCTION fx(x: real): real;
ENDENVIRON *)
FUNCTION rtsec(x1,x2,xacc: real): real;
LABEL 99;
CONST
   maxit = 30;
VAR
   dx,f,fl,swap,xl,rts: real;
   j: integer;
BEGIN
   fl := fx(x1);
   f := fx(x2);
   IF abs(fl) < abs(f) THEN BEGIN
      rts := x1;
      xl := x2;
      swap := fl;
      fl := f;
      f := swap
   END
   ELSE BEGIN
      xl := x1;
      rts := x2
   END;
   FOR j := 1 TO maxit DO BEGIN
      dx := (xl-rts)*f/(f-fl);
      xl := rts;
      fl := f;
      rts := rts+dx;
      f := fx(rts);
      IF (abs(dx) < xacc) OR (f = 0.0) THEN
         GOTO 99
   END;
   writeln('pause in routine RTSEC');
   writeln('maximum number of iterations exceeded');
   readln;
99:
   rtsec := rts
END;
