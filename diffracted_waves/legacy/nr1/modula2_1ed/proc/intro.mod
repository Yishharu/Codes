IMPLEMENTATION MODULE Intro;

   FROM NRMath IMPORT    
	        Sin;
   FROM NRSystem IMPORT
	        LongInt, DI, Float, Trunc;
   FROM NRIO IMPORT 
           Error;

   PROCEDURE FlMoon(    n, 
                        nph:  INTEGER; 
                    VAR jd:   LongInt; 
                    VAR frac: REAL); 
      VAR 
         i: INTEGER; 
         nl: LongInt; 
         rad, xtra, t2, t, c, as, am: REAL; 
   BEGIN 
      rad := 3.14159265/180.0; 
      c := Float(n)+Float(nph)/4.0; (* This is how we comment an individual line. *)
      t := c/1236.85;
      t2 := t*t;
      as := 359.2242+29.105356*c; (* You aren't really intended
                                     to understand this algorithm, but it does work! *)
      am := 306.0253+385.816918*c+0.010730*t2;
      nl := DI(n); (* Cast integer to LongInt. *)
      jd := 2415020+28*nl+7*DI(nph);
      xtra := 0.75933+1.53058868*c+(1.178E-4-1.55E-7*t)*t2;
      IF (nph = 0) OR (nph = 2) THEN
         xtra := xtra+(0.1734-3.93E-4*t)*Sin(rad*as)-0.4068*Sin(rad*am)
      ELSIF (nph = 1) OR (nph = 3) THEN
         xtra := xtra+(0.1721-4.0E-4*t)*Sin(rad*as)-0.6280*Sin(rad*am)
      ELSE (* This is how we will
              indicate error conditions. *)
         Error('FLMoon', 'nph is unknown.');
      END;
      IF xtra >= 0.0 THEN
         i := Trunc(xtra)
      ELSE
         i := Trunc(xtra-1.0)
      END;
      jd := jd+DI(i);
      frac := xtra-Float(i)
   END FlMoon;

END Intro.
