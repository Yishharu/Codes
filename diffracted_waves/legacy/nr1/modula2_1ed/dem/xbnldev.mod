MODULE XBnlDev; (* driver for routine BnlDev *) 

   FROM Reject   IMPORT BnlDev;
   FROM NRMath   IMPORT Round;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString;

   CONST 
      n = 20; 
      npts = 1000; 
      iscal = 200; 
      nn = 100; 

   TYPE 
      RealArray55 = ARRAY [1..55] OF REAL; 
      RealArray21 = ARRAY [0..20] OF REAL; 
      CharArray50 = ARRAY [1..50] OF CHAR; 

   VAR 
      Ran3Inext, Ran3Inextp: INTEGER; 
      Ran3Ma: RealArray55; 
      BnldevNold: INTEGER; 
      BnldevPold: REAL; 
      BnldevOldg: REAL; 
      BnldevEn: REAL; 
      BnldevPc: REAL; 
      BnldevPlog: REAL; 
      BnldevPclog: REAL; 
      i, j, k, idum, klim, llen: INTEGER; 
      pp, xm: REAL; 
      dist: RealArray21; 
      text: CharArray50; 
       
       
       
BEGIN 
   idum := -133; 
   BnldevNold := -1; 
   BnldevPold := -1.0; 
   llen := 50; 
   LOOP 
      FOR j := 0 TO 20 DO 
         dist[j] := 0.0
      END; 
      ReadReal('Mean of binomial distribution (0 to 20) (neg to end)', xm); 
      IF xm < Float(0) THEN 
         EXIT 
      END; 
      pp := xm/Float(nn); 
      FOR i := 1 TO npts DO 
         j := Round(BnlDev(pp, nn, idum)); 
         IF (j >= 0) AND (j <= 20) THEN 
            dist[j] := dist[j]+1.0
         END
      END; 
      WriteString('   x'); 
      WriteString('    p(x)'); 
      WriteString('    graph:'); 
      WriteLn; 
      FOR j := 0 TO 19 DO 
         FOR k := 1 TO llen DO 
            text[k] := ' '
         END; 
         dist[j] := dist[j]/Float(npts); 
         klim := Round(Float(iscal)*dist[j])+1; 
         IF klim > llen THEN 
            klim := llen
         END; 
         FOR k := 1 TO klim DO 
            text[k] := '*'
         END; 
         WriteInt(j, 4); 
         WriteReal(dist[j], 9, 4); 
         WriteString('   '); 
         WriteString(text); 
         WriteLn
      END
   END; 
END XBnlDev.
