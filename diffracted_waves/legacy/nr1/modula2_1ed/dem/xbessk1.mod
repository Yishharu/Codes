MODULE XBessK1; (* Driver for routine BessK1 *) 

   FROM BessMod IMPORT BessK1;
   FROM NRIO    IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                       ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                       Error;
   FROM NRBase IMPORT Equal;

   TYPE 
      StrArray27 = ARRAY [0..27-1] OF CHAR; 
   VAR 
      i, nValue: INTEGER; 
      value, x: REAL; 
      text: StrArray27; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Modified Bessel Function K1'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteLn; 
   WriteString('     x          actual       BessK1(x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      WriteReal(x, 6, 2); 
      WriteReal(value, 16, 7); 
      WriteReal(BessK1(x), 16, 7);
      WriteLn
   END;
   Close(dataFile);
   ReadLn;
END XBessK1.
