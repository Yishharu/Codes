MODULE XCnTab1; (* driver for routine CnTab1 *) 
                (* contingency table in file TABLE1.DAT *) 

   FROM CnTabs  IMPORT CnTab1;
   FROM NRIO    IMPORT File, Open, Close, GetLine, GetWord, GetEOL, GetInt, 
                       ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                       WriteText, Error;
   FROM NRIMatr IMPORT IMatrix, CreateIMatrix, DisposeIMatrix, GetIMatrixAttr, 
                       NilIMatrix, PtrToILines;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       NilVector;

   CONST 
      ndat = 9; 
      nmon = 12; 
      ni = ndat; 
      nj = nmon; 
   TYPE 
      StrArray15 = ARRAY [0..15-1] OF CHAR; 
      StrArray5 = ARRAY [0..5-1] OF CHAR; 
      StrArray64 = ARRAY [0..64-1] OF CHAR; 
   VAR 
      ccc, chisq, cramrv, df, prob: REAL; 
      i, j: INTEGER; 
      NMBR: IMatrix;
      nmbr: PtrToILines; 
      fate: ARRAY [1..ndat] OF StrArray15; 
      mon: ARRAY [1..nmon] OF StrArray5; 
      text: StrArray64; 
      dataFile: File; 
       
BEGIN 
   CreateIMatrix(ni, nj, NMBR, nmbr);
   IF NMBR # NilIMatrix THEN
	   Open('table1.dat', dataFile); 
	   GetEOL(dataFile); 
	   GetLine(dataFile, text); 
	   GetWord(dataFile, fate[1]); 
	   FOR i := 1 TO 12 DO 
	      GetWord(dataFile, mon[i]); 
	   END; 
	   GetEOL(dataFile); 
	   FOR i := 1 TO ndat DO 
	      GetWord(dataFile, fate[i]); 
	      FOR j := 1 TO 12 DO 
	         GetInt(dataFile, nmbr^[i-1]^[j-1])
	      END; 
	      GetEOL(dataFile)
	   END; 
	   Close(dataFile); 
	   WriteLn; 
	   WriteString(text); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('                 '); 
	   FOR i := 1 TO 12 DO 
	      WriteString(mon[i]);
	      WriteString("  ");
	   END; 
	   WriteLn; 
	   FOR i := 1 TO ndat DO 
	      WriteText(fate[i], 15); 
	      FOR j := 1 TO 12 DO 
	         WriteInt(nmbr^[i-1]^[j-1], 5)
	      END; 
	      WriteLn
	   END; 
	   CnTab1(NMBR, chisq, df, prob, cramrv, ccc); 
	   WriteLn; 
	   WriteString('chi-squared       '); 
	   WriteReal(chisq, 20, 2); 
	   WriteLn; 
	   WriteString('degrees of freedom'); 
	   WriteReal(df, 20, 2); 
	   WriteLn; 
	   WriteString('probability       '); 
	   WriteReal(prob, 20, 4); 
	   WriteLn; 
	   WriteString('cramer-v          '); 
	   WriteReal(cramrv, 20, 4); 
	   WriteLn; 
	   WriteString('contingency coeff.'); 
	   WriteReal(ccc, 20, 4); 
	   WriteLn;
	   ReadLn;
	   DisposeIMatrix(NMBR);
	ELSE
	   Error('CnTab1', 'Not enough memory.');
	END;
END XCnTab1.
