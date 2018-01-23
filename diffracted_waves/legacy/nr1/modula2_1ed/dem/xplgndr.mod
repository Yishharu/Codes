MODULE XPLGNDR; (* Driver for routine PLgndr *) 

   FROM SpherHar IMPORT PLgndr;
   FROM NRSystem IMPORT Float;
   FROM NRMath   IMPORT Sqrt;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;

   TYPE 
      StrArray20 = ARRAY [0..20-1] OF CHAR; 
   VAR 
      fac, value, x: REAL; 
      i, j, m, n, nValue: INTEGER; 
      text: StrArray20; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Legendre Polynomials'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('   n'); 
   WriteString('   m'); 
   WriteString('                   x'); 
   WriteString('              actual'); 
   WriteString('       PLgndr(n,m,x)'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetInt(dataFile, n); 
      GetInt(dataFile, m); 
      GetReal(dataFile, x); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      fac := 1.0; 
      IF m > 0 THEN 
         FOR j := n-m+1 TO n+m DO 
            fac := fac*Float(j)
         END;
      END; 
      fac := 2.0*fac/(2.0*Float(n)+1.0); 
      value := value*Sqrt(fac); 
      WriteInt(n, 4); 
      WriteInt(m, 4); 
      WriteReal(x, 20, -10); 
      WriteReal(value, 20, -10); 
      WriteReal(PLgndr(n, m, x), 20, -10);
      WriteLn;
   END; 
   Close(dataFile);
   ReadLn;
END XPLGNDR.
