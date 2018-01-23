MODULE XAveVar; (* driver for routine AveVar *) 

   FROM Tests1   IMPORT AveVar;
   FROM Transf   IMPORT GasDev;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      npts = 1000; 
      eps = 0.1; 
   VAR 
      i, idum, j: INTEGER; 
      ave, shift, vrnce: REAL; 
      DATA: Vector;
      data: PtrToReals; 
       
BEGIN 
   CreateVector(npts, DATA, data);
   IF DATA # NilVector THEN
	(* generate gaussian distributed data *) 
	   idum := -5; 
	   WriteString('      shift'); 
	   WriteString('    average'); 
	   WriteString('    variance'); 
	   WriteLn; 
	   FOR i := 1 TO 11 DO 
	      shift := Float(i-1)*eps; 
	      FOR j := 0 TO npts-1 DO 
	         data^[j] := shift+Float(i)*GasDev(idum)
	      END; 
	      AveVar(DATA, ave, vrnce); 
	      WriteReal(shift, 8, 2); 
	      WriteReal(ave, 11, 2); 
	      WriteReal(vrnce, 12, 2); 
	      WriteLn;
	   END;
	   DisposeVector(DATA);
	   ReadLn;
	ELSE
	   Error('XAveVar', 'Not enough memory.');
	END;
END XAveVar.
