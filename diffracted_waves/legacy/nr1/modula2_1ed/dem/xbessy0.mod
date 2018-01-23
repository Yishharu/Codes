MODULE XBessY0; (* Driver for routine BessY0 *) 

   FROM Bessel IMPORT BessY0;
   FROM NRIO   IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                      ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                      Error;
   FROM NRBase IMPORT Equal;

   TYPE 
      StrArray18 = ARRAY [0..18-1] OF CHAR; 
   VAR 
      i, nValue: INTEGER; 
      value, x: REAL; 
      text: StrArray18; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Bessel Function Y0'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('     x      actual   BessY0(x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      WriteReal(x, 6, 2); 
      WriteReal(value, 12, 7); 
      WriteReal(BessY0(x), 12, 7);
      WriteLn;
   END;
   Close(dataFile);
   ReadLn;
END XBessY0.
