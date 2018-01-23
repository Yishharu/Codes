MODULE XEvlMEM; (* driver for routine EvlMEM *) 

   FROM MaxEntr  IMPORT EvlMEM, MEMCof;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt,  GetReal, ReadLn,  
                        ReadReal, WriteLn, WriteInt, WriteReal, WriteString, Error;   
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                        GetVectorAttr, NilVector;

   CONST 
      n = 1000; 
      m = 10; 
      nfdt = 16; 
   VAR 
      i: INTEGER; 
      fdt, pm: REAL; 
      DATA, COF: Vector;
      data, cof: PtrToReals; 
      dataFile: File; 
       
BEGIN 
   CreateVector(n, DATA, data);
   CreateVector(m, COF, cof);
   IF (DATA # NilVector) AND (COF # NilVector) THEN
	   Open('Spctrl.dat', dataFile); 
	   FOR i := 1 TO n DO 
	      GetReal(dataFile, data^[i-1])
	   END; 
	   Close(dataFile); 
	   MEMCof(DATA, pm, COF); 
	   WriteString('Power spectum estimate of data in SPCTRL.DAT'); WriteLn; 
	   WriteString('    f*delta'); 
	   WriteString('       power'); 
	   WriteLn; 
	   FOR i := 0 TO nfdt DO 
	      fdt := 0.5*Float(i)/Float(nfdt); 
	      WriteReal(fdt, 12, 6); 
	      WriteReal(EvlMEM(fdt, COF, pm), 12, 6);
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('XMemCof', 'Not enough memory.');
	END;
	IF DATA # NilVector THEN DisposeVector(DATA) END;
	IF COF # NilVector THEN DisposeVector(COF) END;
END XEvlMEM.
