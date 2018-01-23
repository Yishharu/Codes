
IMPLEMENTATION MODULE Pre;

   FROM Intro    IMPORT FlMoon;
   FROM NRSystem IMPORT LongInt, DI, SI, Float, FloatDS, Trunc, TruncSD;
   FROM NRMath   IMPORT MODD;
   FROM NRIO     IMPORT WriteLn, WriteInt, WriteReal, WriteString, WriteChar,
                        Error;

   PROCEDURE JulDay(mm, id, iyyy: INTEGER): LongInt; 
      CONST 
         igreg = 588829;
		   (*
		     Gregorian Calendar was adopted on Oct.15, 1582.
		   *)
      VAR
         ja, jm, jy: INTEGER;
         jul, jyyy: LongInt;
   BEGIN
      IF iyyy = 0 THEN
         Error('JulDay', 'there is no year zero.');
      END;
      IF iyyy < 0 THEN
         INC(iyyy, 1)
      END;
      IF mm > 2 THEN
	   (*
	     Here is an example of a block IF-structure.
	   *)
         jy := iyyy;
         jm := mm+1
      ELSE
         jy := iyyy-1;
         jm := mm+13
      END;
      jul := TruncSD(365.25*Float(jy))+TruncSD(30.6001*Float(jm))+DI(id)+
             1720995;
      jyyy := DI(iyyy); (* Cast integer to LongInt. *)
      IF DI(id+31)*(DI(mm+12)*jyyy) >= igreg THEN (* Test whether to change
                                                     to Gregorian Calendar. *)
         ja := Trunc(0.01*Float(jy));
         jul := jul+DI(2-ja)+TruncSD(0.25*Float(ja))
      END;
      RETURN jul;
   END JulDay;

   PROCEDURE BadLuk;
      CONST
         zon = -5.0; (* Time zone -5 is Eastern Standard Time. *)
         iybeg = 1900; (* The range of dates to be searched. *)
         iyend = 2000;
      VAR
         timzon, frac: REAL;
         ic, icon, idwk, im: INTEGER;
         iyyy, n: INTEGER;
         jd, jday: LongInt;
   BEGIN
      timzon := zon/24.0;
      WriteString('Full moons on Friday the 13th from');
      WriteInt(iybeg, 5);
      WriteString(' to');
      WriteInt(iyend, 5);
      WriteLn;
      FOR iyyy := iybeg TO iyend DO (* Loop over each year, *)
         FOR im := 1 TO 12 DO (* and each month. *)
            jday := JulDay(im, 13, iyyy); (* Is the thirteenth a Friday? *)
            idwk := SI(MODD(jday+1, 7));
            IF idwk = 5 THEN
               n := Trunc(12.37*(Float(iyyy-1900)+(Float(im)-0.5)/12.0));
				   (*
				     This value n is a first approximation to how many full moons
				     have occurred since 1900.  We will feed it into the phase routine and
				     adjust it up or down until we determine that our desired 13th was or
				     was not a full moon.  The variable icon signals the direction of
				     adjustment.
				   *)
               icon := 0;
               LOOP
                  FlMoon(n, 2, jd, frac); (* Get date of full moon n. *)
                  frac := 24.0*(frac+timzon); (* Convert to hours in correct time zone. *)
                  IF frac < 0.0 THEN (* Convert from Julian Days beginning at noon
                                        to civil days beginning at midnight. *)
                     jd := jd-DI(1);
                     frac := frac+24.0
                  END;
                  IF frac > Float(12) THEN
		               jd := jd+DI(1);
		               frac := frac-12.0
                  ELSE
                     frac := frac+12.0
                  END;
                  IF jd = jday THEN (* Did we hit our target day? *)
                     WriteLn;
		               WriteInt(im, 2);
		               WriteChar('/');
		               WriteInt(13, 2);
		               WriteChar('/');
		               WriteInt(iyyy, 4);
		               WriteLn;
		               WriteString('Full moon ');
		               WriteReal(frac, 5, 1);
		               WriteString(' hrs after midnight (EST).');
		               WriteLn;
		               EXIT;
						   (*
						     Don't worry if you are unfamiliar with Pascal's esoteric
						     input/output statements; very few programs in this book do any input/output.
						   *)
                  ELSE (* Didn't hit it. *)
		               IF jday >= jd THEN
		                 ic := 1
		               ELSE
		                 ic := -1
		               END;
		               IF ic = -icon THEN (* Another break, case of no match. *)
		                 EXIT;
		               END;
		               icon := ic;
		               INC(n, ic)
                  END;
               END;
            END;
         END;
      END;
   END BadLuk;

   PROCEDURE CalDat(    julian:       LongInt;
                    VAR mm, id, iyyy: INTEGER);
      CONST
         igreg = 2299161;
      VAR
         je, jd, jc, jb, jalpha, ja: LongInt;
   BEGIN
      IF julian >= igreg THEN (* Cross-over to Gregorian Calendar produces this correction, *)
         jalpha := TruncSD((FloatDS(julian-1867216)-0.25)/36524.25);
         ja := julian+1+jalpha-TruncSD(0.25*FloatDS(jalpha))
      ELSE
         ja := julian (* or else no correction. *)
      END;
      jb := ja+1524;
      jc := TruncSD(6680.0+(FloatDS(jb-2439870)-122.1)/365.25);
      jd := 365*jc+TruncSD(0.25*FloatDS(jc));
      je := TruncSD(FloatDS((jb-jd))/30.6001);
      id := SI(jb-jd-TruncSD(30.6001*FloatDS(je)));
      mm := SI(je-1);
      IF mm > 12 THEN
         DEC(mm, 12)
      END;
      iyyy :=SI(jc-4715);
      IF mm > 2 THEN
         DEC(iyyy, 1)
      END;
      IF iyyy <= 0 THEN
         DEC(iyyy, 1)
      END
   END CalDat;

END Pre.
