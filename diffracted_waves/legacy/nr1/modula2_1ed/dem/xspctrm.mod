MODULE XSpctrm; (* driver for routine Spctrm *) 

   FROM SpctrmM IMPORT Spctrm;
   FROM NRIO    IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetReal, ReadLn,
                       ReadReal, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                       GetVectorAttr, NilVector;

   CONST 
      m = 16; 
      m4 = 64; (* m4=4*m *) 
   VAR 
      j, k: INTEGER; 
      ovrlap: BOOLEAN; 
      P, Q: Vector;
      p, q: PtrToReals;
      dataFile: File; 
       
BEGIN 
   CreateVector(m, P, p);
   CreateVector(m, Q, q);
   IF (P # NilVector) AND (Q # NilVector) THEN
	   Open('Spctrl.dat', dataFile); 
	   k := 8; 
	   ovrlap := TRUE; 
	   Spctrm(P, m, k, ovrlap, dataFile); 
	   Close(dataFile); 
	   Open('Spctrl.dat', dataFile); 
	   k := 16; 
	   ovrlap := FALSE; 
	   Spctrm(Q, m, k, ovrlap, dataFile); 
	   Close(dataFile); 
	   WriteString('Spectrum of data in file SPCTRL.DAT'); WriteLn; 
	   WriteString('              overlapped '); 
	   WriteString('      non-overlapped'); WriteLn; 
	   FOR j := 1 TO m DO 
	      WriteInt(j, 6); 
	      WriteString('     '); 
	      WriteReal(p^[j-1], 14, 0); 
	      WriteString('     '); 
	      WriteReal(q^[j-1], 14, 0); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XSpctrm', 'Not enough memory.');
	END;
	IF P # NilVector THEN DisposeVector(P) END;
	IF Q # NilVector THEN DisposeVector(Q) END;
END XSpctrm.
