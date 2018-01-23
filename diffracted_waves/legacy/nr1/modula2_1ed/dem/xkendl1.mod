MODULE XKendl1; (* driver for routine Kendl1 *) 
                (* look for correlations in Ran1, Ran2 and Ran3 *) 

   FROM Correl2 IMPORT Kendl1;
   FROM Uniform IMPORT Ran1, Ran2, Ran3;
   FROM NRSystem  IMPORT LongInt;
   FROM NRIO    IMPORT File,  Open, Close, GetLine, GetInt, ReadLn,
                       WriteLn, WriteInt, WriteReal, WriteString, 
                       WriteText, Error;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       NilVector;

   CONST 
      ndat = 200; 
   TYPE 
      CharArray4 = ARRAY [1..4] OF CHAR; 
   VAR 
      infile: File; 
      Ran1Ix1, Ran1Ix2, Ran1Ix3: LongInt; 
      iduml, Ran2Iy: LongInt; 
      Ran3Inext, Ran3Inextp: INTEGER; 
      i, idum, j: INTEGER; 
      prob, tau, z: REAL; 
      DATA1, DATA2: Vector; 
      data1, data2: PtrToReals; 
      text: ARRAY [1..3] OF CharArray4; 
       
BEGIN 
   CreateVector(ndat, DATA1, data1);
   CreateVector(ndat, DATA2, data2);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) THEN
	   text[1] := 'Ran1'; 
	   text[2] := 'Ran2'; 
	   text[3] := 'Ran3'; 
	   WriteLn; 
	   WriteString('Pair correlations of Ran1, Ran2 and Ran3'); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('  Program      Kendall tau       Std. Dev.'); 
	   WriteString('       Probability'); 
	   WriteLn; 
	   FOR i := 1 TO 3 DO 
	      idum := -1357; 
	      iduml := -1357; 
	      FOR j := 0 TO ndat-1 DO 
	         IF i = 1 THEN 
	            data1^[j] := Ran1(idum); 
	            data2^[j] := Ran1(idum)
	         ELSIF i = 2 THEN 
	            data1^[j] := Ran2(iduml); 
	            data2^[j] := Ran2(iduml)
	         ELSIF i = 3 THEN 
	            data1^[j] := Ran3(idum); 
	            data2^[j] := Ran3(idum)
	         END
	      END; 
	      Kendl1(DATA1, DATA2, tau, z, prob); 
	      WriteText(text[i], 8); 
	      WriteReal(tau, 17, 6); 
	      WriteReal(z, 17, 6); 
	      WriteReal(prob, 17, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XKendl1', 'Not enough memory.');
	END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1); END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2); END;
END XKendl1.
