MODULE XFLMoon; (* driver for routine FlMoon *)

   FROM Intro    IMPORT FlMoon;
   FROM Pre      IMPORT JulDay, CalDat;
   FROM NRSystem IMPORT LongInt, Float, FloatDS, Trunc;
   FROM NRIO     IMPORT ReadLn,  ReadIntegers, WriteLn, WriteInt, WriteString,
                        WriteReal;

   CONST
      zon = -5.0;
   TYPE
      CharArray13 = ARRAY [1..13] OF CHAR;
   VAR
      timzon, frac, secs, a, b: REAL;
      i, i1, i2, i3, id, im, iy, n, nph: INTEGER;
      j1, j2: LongInt;
      phase: ARRAY [0..3] OF CharArray13;

BEGIN
   timzon := zon/24.0;
   phase[0] := 'new moon     ';
   phase[1] := 'first quarter';
   phase[2] := 'full moon    ';
   phase[3] := 'last quarter ';
   WriteString('date of the next few phases of the moon');
   WriteLn;
   WriteString("enter today's date (e.g. 1 31 1982)  :  ");
   WriteLn;
   ReadIntegers('month day year', im, id, iy);
   (* approximate number of full moons since january 1900 *)
   a := Float(im);
   b := (a-0.5)/12.0;
   n := Trunc(12.37*Float((iy-1900+Trunc(b))));
   nph := 2;
   j1 := JulDay(im, id, iy);
   FlMoon(n, nph, j2, frac);
   INC(n, Trunc(FloatDS(j1-j2)/28.0));
   WriteLn;
   WriteString('      date');
   WriteString('          time(est)');
   WriteString('    phase');
   WriteLn;
   FOR i := 1 TO 20 DO
      FlMoon(n, nph, j2, frac);
      frac := 24.0*(frac+timzon);
      IF frac < 0.0 THEN
         j2 := j2-1;
         frac := frac+24.0
      END;
      IF frac > 12.0 THEN
         j2 := j2+1;
         frac := frac-12.0
      ELSE
         frac := frac+12.0
      END;
      i1 := Trunc(frac);
      secs := 3600.0*(frac-Float(i1));
      i2 := Trunc(secs/60.0);
      i3 := Trunc(secs-Float(60*i2));
      CalDat(j2, im, id, iy);
      WriteInt(im, 5);
      WriteInt(id, 3);
      WriteInt(iy, 5);
      WriteInt(i1, 9);
      WriteString(':');
      WriteInt(i2, 2);
      WriteString(':');
      WriteInt(i3, 2);
      WriteString('     ');
      WriteString(phase[nph]);
      WriteLn;
      IF nph = 3 THEN
         nph := 0;
         INC(n, 1)
      ELSE 
         INC(nph, 1)
      END
   END;
   ReadLn;

END XFLMoon.
