MODULE XBetaI; (* Driver for routines BetaI *) 

   FROM IncBeta IMPORT BetaI;
   FROM NRIO    IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                       ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                       Error;
   FROM NRBase IMPORT Equal;

   TYPE 
      StrArray24 = ARRAY [0..24-1] OF CHAR; 
   VAR 
      a, b, value, x: REAL; 
      i, nValue: INTEGER; 
      text: StrArray24; 
      dataFile: File; 
       
BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Incomplete Beta Function'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('     a           b           x'); 
   WriteString('      actual    BetaI(x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, a); 
      GetReal(dataFile, b); 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      WriteReal(a, 6, 2); 
      WriteReal(b, 12, 6); 
      WriteReal(x, 12, 6); 
      WriteReal(value, 12, 6); 
      WriteReal(BetaI(a, b, x), 12, 6);
      WriteLn;
   END;
   Close(dataFile);
   ReadLn;
END XBetaI.
