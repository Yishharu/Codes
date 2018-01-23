MODULE XBessI; (* Driver for routine BessI *) 

   FROM BessMod IMPORT BessI;
   FROM NRIO IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                    ReadLn, WriteLn, WriteString, WriteReal, Error;
   FROM NRBase IMPORT Equal;

   TYPE 
      StrArray27 = ARRAY [0..27-1] OF CHAR; 
   VAR 
      n, i, nValue: INTEGER; 
      value, x: REAL; 
      text: StrArray27; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL (Equal(text, 'Modified Bessel Function In')); 
   WriteString(text); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile);
   WriteLn; 
   WriteLn; 
   WriteString('     x            actual        BessI(n,x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetInt(dataFile, n); 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile);
      WriteReal(x, 6, 2); 
      WriteReal(value, 16, 0); 
      WriteReal(BessI(n, x), 16, 0);
      WriteLn;
   END; 
   ReadLn;
   Close(dataFile)
END XBessI.
