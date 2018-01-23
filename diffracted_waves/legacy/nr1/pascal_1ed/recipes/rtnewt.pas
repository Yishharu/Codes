(* BEGINENVIRON

PROCEDURE funcd(x: real;
         VAR f,df: real);
ENDENVIRON *)
FUNCTION rtnewt(x1,x2,xacc: real): real;
LABEL 99;
CONST
   jmax = 20;
VAR
   df,dx,f,rtn: real;
   j: integer;
BEGIN
   rtn := 0.5*(x1+x2);
   FOR j := 1 TO jmax DO BEGIN
      funcd(rtn,f,df);
      dx := f/df;
      rtn := rtn-dx;
      IF (x1-rtn)*(rtn-x2) < 0.0 THEN BEGIN
         writeln('pause in routine RTNEWT');
         writeln('jumped out of brackets');
         readln
      END;
      IF abs(dx) < xacc THEN GOTO 99
   END;
   writeln('pause in routine RTNEWT');
   writeln('maximum number of iterations exceeded');
   readln;
99:
   rtnewt := rtn
END;
