MODULE XMdian1; (* driver for routine Mdian1 *) 

   FROM Mdians   IMPORT Mdian1;
   FROM Transf   IMPORT GasDev;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      npts = 50; 
   VAR 
      GasdevIset, i, j, idum: INTEGER; 
      xmed: REAL; 
      DATA: Vector;
      data: PtrToReals;

BEGIN 
   CreateVector(npts, DATA, data);
   IF DATA # NilVector THEN
	   GasdevIset := 0; 
	   idum := -5; 
	   FOR i := 0 TO npts-1 DO 
	      data^[i] := GasDev(idum)
	   END; 
	   Mdian1(DATA, xmed); 
	   WriteString('Data drawn from a gaussian distribution'); WriteLn; 
	   WriteString('with zero mean and unit variance'); WriteLn; 
	   WriteLn; 
	   WriteString('Median of data set is'); 
	   WriteReal(xmed, 9, 6); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('Sorted data'); 
	   WriteLn; 
	   FOR i := 1 TO npts DIV 5 DO 
	      FOR j := 1 TO 5 DO 
	         WriteReal(data^[5*i-5+j-1], 12, 6)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	   DisposeVector(DATA);
	ELSE
	   Error('XMdian1', 'Not enough memory');
	END;
END XMdian1.
