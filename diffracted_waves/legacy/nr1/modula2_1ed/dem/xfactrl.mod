MODULE XFactrl; (* Driver for routine Factrl *) 

   FROM GammBeta IMPORT Factrl;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;
          
   TYPE 
      StrArray11 = ARRAY [0..11-1] OF CHAR; 
      RealArray33 = ARRAY [1..33] OF REAL; 
   VAR 
      actual: REAL; 
      factrlNtop, i, n, nValue: INTEGER; 
      text: StrArray11; 
      dataFile: File; 
      FactrlA: RealArray33; 
       
BEGIN 
   factrlNtop := 0; (* initialize Factrl *) 
   FactrlA[1] := 1.0; 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'N-factorial'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('     n'); 
   WriteString('              actual'); 
   WriteString('           Factrl(n)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetInt(dataFile, n); 
      GetReal(dataFile, actual); 
      GetEOL(dataFile); 
      WriteInt(n, 6); 
      IF actual < 1.0E10 THEN 
         WriteReal(actual, 20, 1); 
         WriteReal(Factrl(n), 20, 1);
      ELSE 
         WriteReal(actual, 20, 0); 
         WriteReal(Factrl(n), 20, 0);
      END;
      WriteLn;
   END;
   Close(dataFile);
   ReadLn;
END XFactrl.
