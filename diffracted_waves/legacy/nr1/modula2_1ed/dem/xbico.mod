MODULE XBiCo; (* Driver for routine BiCo *) 

   FROM GammBeta IMPORT BiCo;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;

   TYPE 
      StrArray21 = ARRAY [0..21-1] OF CHAR; 
      RealArray100 = ARRAY [1..100] OF REAL; 
   VAR 
      binCo: REAL; 
      i, k, n, nValue: INTEGER; 
      text: StrArray21; 
      dataFile: File; 
       
BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Binomial Coefficients'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('     n     k      actual   BiCo(n,k)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetInt(dataFile, n); 
      GetInt(dataFile, k); 
      GetReal(dataFile, binCo); 
      GetEOL(dataFile); 
      WriteInt(n, 6); 
      WriteInt(k, 6); 
      WriteReal(binCo, 12, 1); 
      WriteReal(BiCo(n, k), 12, 1);
      WriteLn;
   END;
   Close(dataFile);
   ReadLn;
END XBiCo.
