MODULE XPoiDev; (* driver for routine PoiDev *)

   FROM Reject   IMPORT PoiDev;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString;

   CONST 
      n = 20; 
      npts = 1000; 
      iscal = 200; 
      llen = 50; 
   TYPE 
      RealArray21 = ARRAY [0..20] OF REAL; 
      RealArray55 = ARRAY [1..55] OF REAL; 
      CharArray50 = ARRAY [1..50] OF CHAR; 
   VAR 
      i, idum, j, k, klim: INTEGER; 
      xm: REAL; 
      dist: RealArray21; 
      text: CharArray50; 
      PoidevOldm, PoidevSq, PoidevAlxm, PoidevG: REAL; 
      Ran3Inext, Ran3Inextp: INTEGER;
      Ran3Ma: RealArray55; 

BEGIN
   LOOP
      PoidevOldm := -1.0; (* initializes routine PoiDev *)
      idum := -13;
      FOR j := 0 TO 20 DO
         dist[j] := 0.0
      END;
      REPEAT
         ReadReal('Mean of Poisson distribution (x := 0.0 to 20.0); neg. to end', xm);
      UNTIL xm <= 20.0;
      IF xm < 0.0 THEN
         EXIT
      END;
      FOR i := 1 TO npts DO
         j := Trunc(PoiDev(xm, idum));
         IF (j >= 0) AND (j <= 20) THEN
            dist[j] := dist[j]+1.0
         END
      END;
      WriteString('Poisson-distributed deviate, mean ');
      WriteReal(xm, 5, 2);
      WriteString(' of ');
      WriteInt(npts, 6);
      WriteString(' points');
      WriteLn;
      WriteString('    x    p(x)    graph:');
      WriteLn;
      FOR j := 0 TO 19 DO
         dist[j] := dist[j]/Float(npts);
         FOR k := 1 TO 50 DO
            text[k] := ' '
         END;
         klim := Trunc(Float(iscal)*dist[j]);
         IF klim > llen THEN
            klim := llen
         END;
         FOR k := 1 TO klim DO
            text[k] := '*'
         END;
         WriteReal(1.0*Float(j), 6, 2);
         WriteReal(dist[j], 8, 4); 
         WriteString('   '); 
         WriteString(text); 
         WriteLn
      END
   END; 
END XPoiDev.
