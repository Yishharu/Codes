MODULE XSmooFT; (* driver for routine SmooFT *) 

   FROM SmooFTM  IMPORT SmooFT;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Round, Exp;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      n = 100; 
      hash = 0.05; 
      scale = 100.0; 
      pts = 10.0; 
      m = 258; (* 2 + first integral power of 2 that is greater or
                    equal to (n+2*pts) *) 
   TYPE 
      RealArrayMP = ARRAY [1..m] OF REAL; 
      CharArray50 = ARRAY [1..50] OF CHAR; 
   VAR 
      GasdevIset, i, ii, idum, j, k, nstp: INTEGER; 
      GasdevGset, bar: REAL; 
      Y: Vector; 
      y: PtrToReals;
      text: CharArray50; 
       
BEGIN 
   CreateVector(m, Y, y);
   IF Y # NilVector THEN
	   GasdevIset := 0; 
	   idum := -7; 
	   FOR i := 0 TO n-1 DO 
	      y^[i] := 3.0*Float(i+1)/Float(n)*Exp(-3.0*Float(i+1)/Float(n)); 
	      y^[i] := y^[i]+hash*GasDev(idum)
	   END; 
	   FOR k := 1 TO 3 DO 
	      nstp := n DIV 20; 
	      WriteString('    data      graph'); WriteLn; 
	      FOR i := 1 TO 20 DO 
	         ii := nstp*(i-1)+1; 
	         FOR j := 1 TO 50 DO 
	            text[j] := ' '
	         END; 
	         bar := Float(Round(scale*y^[ii-1])); 
	         FOR j := 1 TO 50 DO 
	            IF Float(j) <= bar THEN 
	               text[j] := '*'
	            END
	         END; 
	         WriteReal(y^[ii-1], 10, 6); 
	         WriteString('    '); 
	         WriteString(text); 
	         WriteLn
	      END; 
	      WriteString(' press return to smooth ...'); 
	      WriteLn; 
	      ReadLn; 
	      SmooFT(Y, n, pts)
	   END;
	   ReadLn;
	   DisposeVector(Y);
	ELSE
	   Error('XSmooFT', 'Not enough memory.');
	END;
END XSmooFT.
