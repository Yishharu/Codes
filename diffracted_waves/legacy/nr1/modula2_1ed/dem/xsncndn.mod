MODULE XSnCnDn; (* Driver for routine SnCnDn *) 

   FROM Elliptic IMPORT SnCnDn;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal,
                        ReadLn, WriteLn, WriteString, WriteInt, WriteReal,
                        Error;
   FROM NRBase   IMPORT Equal;

   TYPE 
      StrArray26 = ARRAY [0..26-1] OF CHAR; 
   VAR 
      cn, dn, em, emmc, sn, uu, value: REAL; 
      i, nValue: INTEGER; 
      text: StrArray26; 
      dataFile: File; 

BEGIN 
   Open('FncVal.DAT', dataFile); 
   REPEAT 
      GetLine(dataFile, text); 
   UNTIL Equal(text, 'Jacobian Elliptic Function'); 
   GetInt(dataFile, nValue); 
   GetEOL(dataFile); 
   WriteString(text); 
   WriteLn; 
   WriteString('   mc'); 
   WriteString('       u'); 
   WriteString('         actual'); 
   WriteString('             sn'); 
   WriteString('   sn^2+cn^2'); 
   WriteString('  (mc)*(sn^2)+dn^2'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      GetReal(dataFile, em); 
      GetReal(dataFile, uu); 
      GetReal(dataFile, value); 
      GetEOL(dataFile); 
      emmc := 1.0-em; 
      SnCnDn(uu, emmc, sn, cn, dn); 
      WriteReal(emmc, 5, 2); 
      WriteReal(uu, 8, 2); 
      WriteReal(value, 15, 5); 
      WriteReal(sn, 15, 5); 
      WriteReal((sn*sn+cn*cn), 12, 5); 
      WriteReal((em*sn*sn+dn*dn), 16, 5); 
      WriteLn;
   END; 
   Close(dataFile);
   ReadLn;
END XSnCnDn.
