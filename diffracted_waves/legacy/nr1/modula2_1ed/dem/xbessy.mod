MODULE XBessY; (* Driver for routine BessY *) 
 
   FROM Bessel IMPORT BessY;
   FROM NRIO   IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                      ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                      Error;
   FROM NRBase IMPORT Equal;

   TYPE 
      StrArray18 = ARRAY [0..18-1] OF CHAR; 
   VAR 
      i, n, nValue: INTEGER; 
      value, x: REAL; 
      text: StrArray18; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Bessel Function Yn'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('   n'); 
   WriteString('       x          actual      BessY(n,x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetInt(dataFile, n); 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      WriteInt(n, 4); 
      WriteReal(x, 8, 2); 
      WriteReal(value, 16, 0); 
      WriteReal(BessY(n, x), 16, 0);
      WriteLn;
   END; 
   Close(dataFile);
   ReadLn;
END XBessY.
