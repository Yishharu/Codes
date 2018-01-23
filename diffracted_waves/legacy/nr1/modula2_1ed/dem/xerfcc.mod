MODULE XErFCC;  (* Driver for routine ErFCC *) 

  FROM IncGamma IMPORT ErFCC;
  FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                       ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                       Error;
   FROM NRBase  IMPORT Equal;

   TYPE 
      StrArray14 = ARRAY [0..14-1] OF CHAR; 
   VAR 
      i, nValue: INTEGER; 
      x, value: REAL; 
      text: StrArray14; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Error Function'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString('complementary error function'); 
   WriteLn; 
   WriteString('     x      actual    ErFCC(x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      value := 1.0-value; 
      WriteReal(x, 6, 2); 
      WriteReal(value, 12, 7); 
      WriteReal(ErFCC(x), 12, 7);
      WriteLn
   END;
   Close(dataFile);
   ReadLn;
END XErFCC.
