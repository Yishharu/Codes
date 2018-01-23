MODULE XBeta; (* Driver for routine Beta *) 

   FROM GammBeta IMPORT Beta;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase IMPORT Equal;

   TYPE 
      StrArray13 = ARRAY [0..13-1] OF CHAR; 
   VAR 
      i, nValue: INTEGER; 
      value, w, z: REAL; 
      text: StrArray13; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Beta Function'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('     w     z            actual         Beta(w,z)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, w); 
      GetReal(dataFile, z); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      WriteReal(w, 6, 2); 
      WriteReal(z, 6, 2); 
      WriteReal(value, 18, 0); 
      WriteReal(Beta(w, z), 18, 0);
      WriteLn;
   END; 
   Close(dataFile);
   ReadLn;
END XBeta.
