MODULE XERFC; (* Driver for routine ERFC *) 

  FROM IncGamma IMPORT ErFC;
  FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                       ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                       Error;
   FROM NRBase  IMPORT Equal;

   TYPE 
      StrArray14 = ARRAY [0..14-1] OF CHAR; 
   VAR 
      i, nValue: INTEGER; 
      value, x: REAL; 
      text: StrArray14; 
      dataFile: File; 
       
BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Error Function'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString('Complementary error function'); 
   WriteLn; 
   WriteString('     x      actual     ErFC(x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      value := 1.0-value; 
      WriteReal(x, 6, 2); 
      WriteReal(value, 12, 7); 
      WriteReal(ErFC(x), 12, 7);
      WriteLn;
   END;
   Close(dataFile);
   ReadLn;
END XERFC.
