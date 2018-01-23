MODULE XFactLn; (* Driver for routine FactLn *) 

   FROM GammBeta IMPORT FactLn;
   FROM NRMath   IMPORT Ln, LnDD;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;

   TYPE 
      StrArray11 = ARRAY [0..11-1] OF CHAR; 
   VAR 
      i, n, nValue: INTEGER; 
      value: REAL; 
      text: StrArray11; 
      dataFile: File; 
       
BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'N-factorial'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString('log of n-factorial'); 
   WriteLn; 
   WriteString('     n'); 
   WriteString('              actual'); 
   WriteString('           FactLn(n)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetInt(dataFile, n); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      WriteInt(n, 6); 
      WriteReal(Ln(value), 20, 7); 
      WriteReal(FactLn(n), 20, 7);
      WriteLn;
   END;
   Close(dataFile);
   ReadLn;
END XFactLn.
