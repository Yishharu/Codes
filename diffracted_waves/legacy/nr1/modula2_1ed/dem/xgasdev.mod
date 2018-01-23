MODULE XGasDev; (* driver for routine GasDev *) 
 
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Round;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, WriteChar;

   CONST 
      n = 20; 
      nover2 = 10; (* n/2 *) 
      npts = 1000; 
      iscal = 400; 
      llen = 50; 
   TYPE 
      CharArray50 = ARRAY [1..50] OF CHAR; 
      RealArray55 = ARRAY [1..55] OF REAL; 
   VAR 
      i, idum, iset, j, k, klim: INTEGER; 
      gset: REAL; 
      words: CharArray50; 
      dist: ARRAY [-nover2..nover2] OF REAL; 
      Ran3Inext, Ran3Inextp: INTEGER; 
      Ran3Ma: RealArray55; 
      GasdevIset: INTEGER; 
      GasdevGset: REAL; 
       
BEGIN 
   GasdevIset := 0; (* initializes routine GasDev *) 
   idum := -13; (* initializes ran3 *) 
   FOR j := -nover2 TO nover2 DO 
      dist[j] := 0.0
   END; 
   FOR i := 1 TO npts DO 
      j := Round(0.25*Float(n)*GasDev(idum)); 
      IF (j >= -nover2) AND (j <= nover2) THEN 
         dist[j] := dist[j]+Float(1)
      END
   END; 
   WriteString('normally distributed deviate of '); 
   WriteInt(npts, 6); 
   WriteString(' points'); 
   WriteLn; 
   WriteString('x'); 
   WriteString('p(x)'); 
   WriteString('graph:'); 
   WriteLn; 
   FOR j := -nover2 TO nover2 DO 
      dist[j] := dist[j]/Float(npts); 
      FOR k := 1 TO 50 DO words[k] := ' ' END; 
      klim := Trunc(Float(iscal)*dist[j]); 
      IF klim > llen THEN klim := llen END; 
      FOR k := 1 TO klim DO 
         words[k] := '*'
      END; 
      WriteReal(Float(j)/(0.25*Float(n)), 8, 4); 
      WriteReal(dist[j], 8, 4); 
      WriteString('  '); 
      FOR k := 1 TO 50 DO WriteChar(words[k]) END; 
      WriteLn
   END;
   ReadLn;
END XGasDev.
