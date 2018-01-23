MODULE XPredic; (* driver for routine Predic *) 

   FROM LinPred  IMPORT Predic, FixRts;
   FROM MaxEntr  IMPORT MEMCof;
   FROM NRMath   IMPORT Exp, Sin;
   FROM NRSystem IMPORT Float;  
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                        GetVectorAttr, NilVector;

   CONST 
      npts = 300; 
      npoles = 10; 
      npolp1 = 11; (* npolp1 = npoles+1 *) 
      nfut = 20; 
      pi = 3.1415926; 
   VAR 
      i: INTEGER; 
      dum: REAL; 
      DATA, DD, FUTURE: Vector; 
      data, d, future: PtrToReals;

   PROCEDURE f(n, npts: INTEGER): REAL; 
   BEGIN 
      RETURN Exp((-1.0)*Float(n)/Float(npts))*Sin(2.0*pi*Float(n)/50.0)+Exp((-2.0)*Float(n)/Float(npts))*Sin(2.2*pi*
      Float(n)/50.0); 
   END f; 
    
BEGIN 
   CreateVector(npoles, DD, d);
   CreateVector(npts, DATA, data);
   CreateVector(nfut, FUTURE, future);
   IF (DD # NilVector) AND (DATA # NilVector) AND (FUTURE # NilVector) THEN
	   FOR i := 1 TO npts DO 
	      data^[i-1] := f(i, npts)
	   END; 
	   MEMCof(DATA, dum, DD); 
	   FixRts(DD); 
	   Predic(DATA, DD, FUTURE); 
	   WriteString('     I'); 
	   WriteString('     Actual'); 
	   WriteString('      Predic'); 
	   WriteLn; 
	   FOR i := 1 TO nfut DO 
	      WriteInt(i, 6); 
	      WriteReal(f(i+npts, npts), 12, 6); 
	      WriteReal(future^[i-1], 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XPredic', 'Not enough memory.');
	END;
	IF DD # NilVector THEN DisposeVector(DD) END;
	IF DATA # NilVector THEN DisposeVector(DATA) END;
	IF FUTURE # NilVector THEN DisposeVector(FUTURE) END;
END XPredic.
