MODULE XPearsn; (* driver for routine Pearsn *)

   FROM PearsnM IMPORT Pearsn;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                       Error;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       NilVector;

   CONST 
      n = 10; 
   VAR 
      prob, r, z: REAL; 
      i: INTEGER;
      DOSE, SPORE: Vector;
      dose, spore: PtrToReals; 
       
BEGIN 
   CreateVector(n, DOSE, dose);
   CreateVector(n, SPORE, spore);
   IF (DOSE # NilVector) AND (SPORE # NilVector) THEN
	   dose^[0] := 56.1;  dose^[1] := 64.1;  dose^[2] := 70.0; 
	   dose^[3] := 66.6;  dose^[4] := 82.0;  dose^[5] := 91.3; 
	   dose^[6] := 90.0;  dose^[7] := 99.7;  dose^[8] := 115.3; 
	   dose^[9] := 110.0; 
	   spore^[0] := 0.11;  spore^[1] := 0.40;  spore^[2] := 0.37; 
	   spore^[3] := 0.48;  spore^[4] := 0.75;  spore^[5] := 0.66; 
	   spore^[6] := 0.71;  spore^[7] := 1.20;  spore^[8] := 1.01; 
	   spore^[9] := 0.95; 
	   WriteLn; 
	   WriteString('Effect of Gamma Rays on Man-in-the-Moon Marigolds'); 
	   WriteLn; 
	   WriteString('Count Rate (cpm)'); 
	   WriteString('           Pollen Index'); 
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      WriteReal(dose^[i], 10, 2); 
	      WriteReal(spore^[i], 25, 2); 
	      WriteLn
	   END; 
	   Pearsn(DOSE, SPORE, r, prob, z); 
	   WriteLn; 
	   WriteString('                        Pearsn        Expected'); 
	   WriteLn; 
	   WriteString('Corr. Coeff.'); 
	   WriteString('        '); 
	   WriteReal(r, 13, -10); 
	   WriteString('  '); 
	   WriteReal(0.9069586, 13, -10); 
	   WriteLn; 
	   WriteString('Probability'); 
	   WriteString('         '); 
	   WriteReal(prob, 13, -10); 
	   WriteString('  '); 
	   WriteReal(0.2926505E-3, 13, -10); 
	   WriteLn; 
	   WriteString("Fisher's z"); 
	   WriteString('          '); 
	   WriteReal(z, 13, -10); 
	   WriteString('  '); 
	   WriteReal(1.510110, 13, -10); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XPearsn', 'Not enough memory.');
	END;
	IF DOSE # NilVector THEN DisposeVector(DOSE) END;
	IF SPORE # NilVector THEN DisposeVector(SPORE) END;
END XPearsn.
