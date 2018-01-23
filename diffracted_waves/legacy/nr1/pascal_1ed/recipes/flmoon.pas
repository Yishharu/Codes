PROCEDURE flmoon(n,nph: integer;
                VAR jd: longint;
              VAR frac: real);
VAR
   i: integer;
   nl: longint;
   rad,xtra,t2,t,c,as,am: real;
BEGIN
   rad := 3.14159265/180.0;
   c := n+nph/4.0;
   t := c/1236.85;
   t2 := sqr(t);
   as := 359.2242+29.105356*c;
   am := 306.0253+385.816918*c+0.010730*t2;
   nl := n;
   jd := 2415020+28*nl+7*nph;
   xtra := 0.75933+1.53058868*c+(1.178e-4-1.55e-7*t)*t2;
   IF (nph = 0) OR (nph = 2) THEN
      xtra := xtra+(0.1734-3.93e-4*t)*sin(rad*as)-0.4068*sin(rad*am)
   ELSE IF (nph = 1) OR (nph = 3) THEN
      xtra := xtra+(0.1721-4.0e-4*t)*sin(rad*as)-0.6280*sin(rad*am)
   ELSE BEGIN
      writeln('pause in FLMOON - nph is unknown.');
      readln
   END;
   IF xtra >= 0.0 THEN
      i := trunc(xtra)
   ELSE
      i := trunc(xtra-1.0);
   jd := jd+i;
   frac := xtra-i
END;
