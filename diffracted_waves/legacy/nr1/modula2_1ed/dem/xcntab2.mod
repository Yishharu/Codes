MODULE XCnTab2; (* driver for routine CnTab2 *) 
                (* contingency table in file TABLE1.DAT *) 

   FROM CnTabs  IMPORT CnTab2;
   FROM NRIO    IMPORT File, Open, Close, GetLine, GetWord,  GetEOL, GetInt,  
                       ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                       WriteText, Error;
   FROM NRIMatr IMPORT IMatrix, CreateIMatrix, DisposeIMatrix, GetIMatrixAttr, 
                       NilIMatrix, PtrToILines;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       NilVector;

   CONST 
      ni = 9; 
      nmon = 12; 
      nj = nmon; 
   TYPE 
      StrArray5 = ARRAY [0..5-1] OF CHAR; 
      StrArray15 = ARRAY [0..15-1] OF CHAR; 
      StrArray64 = ARRAY [0..64-1] OF CHAR; 
   VAR 
      h, hx, hxgy, hy, hygx: REAL; 
      uxgy, uxy, uygx: REAL; 
      i, j: INTEGER; 
      NMBR: IMatrix;
      nmbr: PtrToILines; 
      fate: ARRAY [1..ni] OF StrArray15; 
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
	      GetWord(dataFile, mon[i])
	   END; 
	   GetEOL(dataFile); 
	   FOR i := 1 TO ni DO 
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
	   FOR i := 1 TO ni DO 
	      WriteText(fate[i], 15); 
	      FOR j := 1 TO 12 DO 
	         WriteInt(nmbr^[i-1]^[j-1], 5)
	      END; 
	      WriteLn
	   END; 
	   CnTab2(NMBR, h, hx, hy, hygx, hxgy, uygx, uxgy, uxy); 
	   WriteLn; 
	   WriteString('entropy of table           '); 
	   WriteReal(h, 10, 4); 
	   WriteLn; 
	   WriteString('entropy of x-distribution  '); 
	   WriteReal(hx, 10, 4); 
	   WriteLn; 
	   WriteString('entropy of y-distribution  '); 
	   WriteReal(hy, 10, 4); 
	   WriteLn; 
	   WriteString('entropy of y given x       '); 
	   WriteReal(hygx, 10, 4); 
	   WriteLn; 
	   WriteString('entropy of x given y       '); 
	   WriteReal(hxgy, 10, 4); 
	   WriteLn; 
	   WriteString('dependency of y on x       '); 
	   WriteReal(uygx, 10, 4); 
	   WriteLn; 
	   WriteString('dependency of x on y       '); 
	   WriteReal(uxgy, 10, 4); 
	   WriteLn; 
	   WriteString('symmetrical dependency     '); 
	   WriteReal(uxy, 10, 4); 
	   WriteLn;
	   ReadLn;
	   DisposeIMatrix(NMBR);
	ELSE
	   Error('CnTab1', 'Not enough memory.');
	END;
END XCnTab2.
