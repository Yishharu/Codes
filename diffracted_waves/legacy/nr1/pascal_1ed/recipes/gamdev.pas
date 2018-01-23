FUNCTION gamdev(VAR ia,idum: integer): real;
VAR
   am,e,s,v1,v2,x,y: real;
   j: integer;
BEGIN
   IF ia < 1 THEN BEGIN
      writeln('pause in routine GAMDEV');
      readln
   END;
   IF ia < 6 THEN BEGIN
      x := 1.0;
      FOR j := 1 TO ia DO x := x*ran3(idum);
      x := -ln(x)
   END
   ELSE BEGIN
      REPEAT
         REPEAT
            REPEAT
               v1 := 2.0*ran3(idum)-1.0;
               v2 := 2.0*ran3(idum)-1.0;
            UNTIL sqr(v1)+sqr(v2) <= 1.0;
            y := v2/v1;
            am := ia-1;
            s := sqrt(2.0*am+1.0);
            x := s*y+am;
         UNTIL x > 0.0;
         e := (1.0+sqr(y))
            *exp(am*ln(x/am)-s*y);
      UNTIL ran3(idum) <= e
   END;
   gamdev := x
END;
