MODULE XGSER; (* Driver for routine GSER *) 
 
   FROM IncGamma IMPORT GSer;
   FROM GammBeta IMPORT GammLn;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase          IMPORT Equal;

   TYPE 
      StrArray25 = ARRAY [0..25-1] OF CHAR; 
   VAR 
      a, gamser, gammaLn, value, x: REAL; 
      i, nValue: INTEGER; 
      text: StrArray25; 
      dataFile: File; 
       
BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Incomplete Gamma Function'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('     a'); 
   WriteString('           x'); 
   WriteString('      actual'); 
   WriteString('   GSer(a,x)'); 
   WriteString('   GammLn(a)'); 
   WriteString('     gammaLn'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, a); 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      GSer(a, x, gamser, gammaLn); 
      WriteReal(a, 6, 2); 
      WriteReal(x, 12, 6); 
      WriteReal(value, 12, 6); 
      WriteReal(gamser, 12, 6); 
      WriteReal(GammLn(a), 12, 6);
      WriteReal(gammaLn, 12, 6);
      WriteLn;
   END;
   Close(dataFile);
   ReadLn;
END XGSER.
