PROCEDURE badluk;
LABEL 10;
CONST
   zon = -5.0;
   iybeg = 1900;
   iyend = 2000;
VAR
   timzon,frac: real;
   ic,icon,idwk,im: integer;
   iyyy,n: integer;
   jd,jday: longint;

BEGIN
   timzon := zon/24.0;
   writeln('Full moons on Friday the 13th from',iybeg:5,' to',iyend:5);
   FOR iyyy := iybeg TO iyend DO BEGIN
      FOR im := 1 TO 12 DO BEGIN
         jday := julday(im,13,iyyy);
         idwk := (jday+1) MOD 7;
         IF idwk = 5 THEN BEGIN
            n := trunc(12.37*(iyyy-1900+(im-0.5)/12.0));
            icon := 0;
            WHILE true DO BEGIN
               flmoon(n,2,jd,frac);
               frac := 24.0*(frac+timzon);
               IF frac < 0.0 THEN BEGIN
                  jd := jd-1;
                  frac := frac+24.0
               END;
               IF frac > 12 THEN BEGIN
                  jd := jd+1;
                  frac := frac-12.0
               END
               ELSE
                  frac := frac+12.0;
               IF jd = jday THEN BEGIN
                  writeln;
                  writeln(im:2,'/',13:2,'/',iyyy:4);
                  writeln('Full moon ',frac:5:1,' hrs after midnight (EST).');
                  GOTO 10
               END
               ELSE BEGIN
                  IF jday >= jd THEN
                     ic := 1
                  ELSE
                     ic := -1;
                  IF ic = -icon THEN
                     GOTO 10;
                  icon := ic;
                  n := n+ic
               END
            END;
10:      END
      END
   END
END;
