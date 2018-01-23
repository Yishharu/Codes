MODULE XMemCof; (* driver for routine MEMCof *) 

   FROM MaxEntr IMPORT MEMCof;
   FROM NRIO    IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal, ReadLn,  
                       ReadReal, WriteLn, WriteInt, WriteReal, WriteString,  Error;   
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                       GetVectorAttr, NilVector;

   CONST 
      n = 1000; 
      m = 10; 
   VAR 
      i: INTEGER; 
      pm: REAL; 
      DATA, COF: Vector;
      data, cof: PtrToReals; 
      dataFile: File;
      
BEGIN 
   CreateVector(n, DATA, data);
   CreateVector(m, COF, cof);
   IF (DATA # NilVector) AND (COF # NilVector) THEN
	   Open('Spctrl.dat', dataFile); 
	   FOR i := 1 TO n DO 
	      GetReal(dataFile, data^[i-1]);
	   END; 
	   Close(dataFile); 
	   MEMCof(DATA, pm, COF); 
	   WriteString('Coefficients for spectral estimation of SPCTRL.DAT'); 
	   WriteLn; 
	   WriteLn; 
	   FOR i := 1 TO m DO 
	      WriteString('a['); 
	      WriteInt(i, 2); 
	      WriteString('] ='); 
	      WriteReal(cof^[i-1], 12, 6); 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('a0 ='); 
	   WriteReal(pm, 12, 6); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XMemCof', 'Not enough memory.');
	END;
	IF DATA # NilVector THEN DisposeVector(DATA) END;
	IF COF # NilVector THEN DisposeVector(COF) END;
END XMemCof.
