MODULE XSpear; (* driver for routine Spear *) 

   FROM Correl2 IMPORT Spear;
   FROM NRMath  IMPORT Round;
   FROM NRIO    IMPORT File, Open, Close, GetChars, GetLine, GetEOL, GetInt, GetWord, 
                       GetReal, ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                       WriteText, Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,
                       NilMatrix, PtrToLines;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       NilVector;

   CONST 
      ndat = 20; 
      nmon = 12; 
      n = ndat; 
   TYPE 
      StrArray64 = ARRAY [0..64-1] OF CHAR; 
      StrArray15 = ARRAY [0..15-1] OF CHAR; 
      StrArray4 = ARRAY [0..4-1] OF CHAR; 
   VAR 
      d, probd, probrs, rs, zd: REAL; 
      i, j: INTEGER; 
      AVE, DATA1, DATA2, ZLAT: Vector; 
      ave, data1, data2, zlat: PtrToReals; 
      RAYS: Matrix;
      rays: PtrToLines; 
      city: ARRAY [1..ndat] OF StrArray15; 
      mon: ARRAY [1..nmon] OF StrArray4; 
      text: StrArray64; 
      dataFile: File; 
       
BEGIN 
   CreateVector(n, AVE, ave);
   CreateVector(n, DATA1, data1);
   CreateVector(n, DATA2, data2);
   CreateVector(n, ZLAT, zlat);
   CreateMatrix(ndat, nmon, RAYS, rays);
   IF (AVE # NilVector) AND (DATA1 # NilVector) AND (DATA2 # NilVector) AND
      (ZLAT # NilVector) AND (RAYS # NilMatrix) THEN
	   Open('table2.dat', dataFile); 
	   GetEOL(dataFile); 
	   GetLine(dataFile, text); 
	   GetWord(dataFile, city[1]); 
	   FOR i := 1 TO nmon DO 
	      GetWord(dataFile, mon[i])
	   END; 
	   GetEOL(dataFile); 
	   FOR i := 1 TO ndat DO 
	      GetChars(dataFile, 15, city[i]); 
	      FOR j := 1 TO nmon DO 
	         GetReal(dataFile, rays^[i-1]^[j-1])
	      END; 
	      GetReal(dataFile, ave^[i-1]); 
	      GetReal(dataFile, zlat^[i-1]); 
	      GetEOL(dataFile)
	   END; 
	   Close(dataFile); 
	   WriteString(text); 
	   WriteLn; 
	   WriteString('               '); 
	   FOR i := 1 TO nmon DO WriteText(mon[i], 4) END; 
	   WriteLn; 
	   FOR i := 1 TO ndat DO 
	      WriteText(city[i], 15); 
	      FOR j := 1 TO nmon DO 
	         WriteInt(Round(rays^[i-1]^[j-1]), 4)
	      END; 
	      WriteLn
	   END; (* check temperature correlations between different months *) 
	   WriteLn; 
	   WriteString('Are sunny summer places also sunny winter places'); 
	   WriteLn; 
	   WriteString('Check correlation of sampled U.S. solar radiation'); 
	   WriteLn; 
	   WriteString('(july with other months)'); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('month'); 
	   WriteString('        d      st. dev.      probd     spearman-r'); 
	   WriteString('    probrs'); 
	   WriteLn; 
	   FOR i := 0 TO ndat-1 DO 
	      data1^[i] := rays^[i]^[0]
	   END; 
	   FOR j := 1 TO nmon DO 
	      FOR i := 1 TO ndat DO 
	         data2^[i-1] := rays^[i-1]^[j-1]
	      END; 
	      Spear(DATA1, DATA2, d, zd, probd, rs, probrs); 
	      WriteString(mon[j]); 
	      WriteReal(d, 12, 2); 
	      WriteReal(zd, 12, 6); 
	      WriteReal(probd, 12, 6); 
	      WriteReal(rs, 13, 6); 
	      WriteReal(probrs, 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XSpear', 'Not enough memory.');
	END;
	IF AVE # NilVector THEN DisposeVector(AVE); END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1); END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2); END;
	IF ZLAT # NilVector THEN DisposeVector(ZLAT); END;
	IF RAYS # NilMatrix THEN DisposeMatrix(RAYS); END;
END XSpear.
