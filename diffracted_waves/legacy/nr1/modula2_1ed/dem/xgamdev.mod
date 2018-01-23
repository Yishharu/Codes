MODULE XGamDev; (* driver for routine GamDev *)

   FROM Reject   IMPORT GamDev;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT ReadInt, WriteLn, WriteInt, WriteReal,
                        WriteString, WriteChar;

   CONST
      n = 20;
      npts = 1000;
      iscal = 200;
      llen = 50;
   TYPE
      CharArray50 = ARRAY [1..50] OF CHAR;
      RealArray21 = ARRAY [0..20] OF REAL;
      RealArray55 = ARRAY [1..55] OF REAL;
   VAR
      i, ia, idum, j, k, klim: INTEGER;
      words: CharArray50;
      dist: RealArray21;
BEGIN
   idum := -13;
   LOOP
      FOR j := 0 TO 20 DO dist[j] := 0.0 END;
      REPEAT
         ReadInt('Select order of Gamma distribution (n=1..20), -1 to end --', ia);
      UNTIL ia <= 20;
      IF ia < 0 THEN EXIT END;
      FOR i := 1 TO npts DO
         j := Trunc(GamDev(ia, idum));
         IF (j >= 0) AND (j <= 20) THEN
            dist[j] := dist[j]+1.0
         END
      END;
      WriteLn;
      WriteString('gamma-distribution deviate, order ');
      WriteInt(ia, 2);
      WriteString(' of ');
      WriteInt(npts, 6);
      WriteString(' points');
      WriteLn;
      WriteString('x');
      WriteString('p(x)');
      WriteString('graph:');
      WriteLn;
      FOR j := 0 TO 19 DO
         dist[j] := dist[j]/Float(npts);
         FOR k := 1 TO 50 DO words[k] := ' ' END;
         klim := Trunc(Float(iscal)*dist[j]);
         IF klim > llen THEN klim := llen END;
         FOR k := 1 TO klim DO words[k] := '*' END;
         WriteInt(j, 6);
         WriteReal(dist[j], 8, 4);
         WriteString('  ');
         FOR k := 1 TO klim DO WriteChar(words[k]) END;
         WriteLn
      END
   END;
END XGamDev.
