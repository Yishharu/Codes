FUNCTION betacf(a,b,x: real): real;
LABEL 99;
CONST
   itmax = 100;
   eps = 3.0e-7;
VAR
   tem,qap,qam,qab,em,d: real;
   bz,bpp,bp,bm,az,app: real;
   am,aold,ap: real;
   m: integer;
BEGIN
   am := 1.0;
   bm := 1.0;
   az := 1.0;
   qab := a+b;
   qap := a+1.0;
   qam := a-1.0;
   bz := 1.0-qab*x/qap;
   FOR m := 1 TO itmax DO BEGIN
      em := m;
      tem := em+em;
      d := em*(b-m)*x/((qam+tem)*(a+tem));
      ap := az+d*am;
      bp := bz+d*bm;
      d := -(a+em)*(qab+em)*x/((a+tem)*(qap+tem));
      app := ap+d*az;
      bpp := bp+d*bz;
      aold := az;
      am := ap/bpp;
      bm := bp/bpp;
      az := app/bpp;
      bz := 1.0;
      IF abs(az-aold) < eps*abs(az) THEN GOTO 99
   END;
   writeln('pause in BETACF');
   writeln('a or b too big, or itmax too small');
   readln;
99:
   betacf := az
END;
