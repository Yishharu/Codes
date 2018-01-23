MODULE XGCF; (* Driver for routine GCF *) 

   FROM IncGamma IMPORT GCF;
   FROM GammBeta IMPORT GammLn;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;

   TYPE 
      StrArray25 = ARRAY [0..25-1] OF CHAR; 
   VAR 
      a, gammaCF, gammaLn, value, x: REAL; 
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
   WriteString('    GCF(a,x)'); 
   WriteString('   GammLn(a)'); 
   WriteString('     gammaLn'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, a); 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      IF x >= a+1.0 THEN 
         GCF(a, x, gammaCF, gammaLn); 
         WriteReal(a, 6, 2); 
         WriteReal(x, 12, 6); 
         WriteReal((1.0-value), 12, 6); 
         WriteReal(gammaCF, 12, 6); 
         WriteReal(GammLn(a), 12, 6);
         WriteReal(gammaLn, 12, 6);
         WriteLn;
      END
   END;
   Close(dataFile);
   ReadLn;
END XGCF.
