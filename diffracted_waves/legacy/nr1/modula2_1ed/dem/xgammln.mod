MODULE XGammLn; (* Driver for routine GammLn *)

   FROM GammBeta IMPORT GammLn;
   FROM NRMath   IMPORT Exp, ExpDD, Sin;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;

   CONST
      Pi = 3.1415926;
   TYPE
      StrArray14 = ARRAY [0..14] OF CHAR;
   VAR 
      i, nValue: INTEGER; 
      actual, calculated, x, y: REAL; 
      text: StrArray14; 
      dataFile: File; 
       
BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Gamma Function'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString('gamma function:'); 
   WriteLn; 
   WriteString('           x'); 
   WriteString('               actual'); 
   WriteString('       from GammLn(x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, x); 
      GetReal(dataFile, actual); 
      GetEOL(dataFile); 
      IF x > 0.0 THEN 
         IF x >= 1.0 THEN 
            calculated := Exp(GammLn(x));
         ELSE 
            calculated := Exp(GammLn(x+1.0))/x;
         END
      ELSE 
         y := 1.0-x; 
         calculated := Pi*Exp((-GammLn(y)))/Sin(Pi*y);
      END; 
      WriteReal(x, 12, 2); 
      WriteReal(actual,21, -10); 
      WriteReal(calculated, 21, -10); 
      WriteLn;
   END; 
   Close(dataFile);
   ReadLn;
END XGammLn.
