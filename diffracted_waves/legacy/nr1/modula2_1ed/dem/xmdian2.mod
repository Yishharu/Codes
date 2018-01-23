MODULE XMdian2; (* driver for routine Mdian2 *) 

   FROM Mdians IMPORT Mdian1, Mdian2;
   FROM Transf IMPORT GasDev;
   FROM NRIO   IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                      Error;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                      NilVector;

   CONST 
      npts = 50; 
   VAR 
      GasdevIset: INTEGER; 
      i, idum: INTEGER; 
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
	   Mdian2(DATA, xmed); 
	   WriteString('Data drawn from a gaussian distribution'); WriteLn; 
	   WriteString('with zero mean, unit variance'); WriteLn; 
	   WriteLn; 
	   WriteString('median according to mdian2 is'); 
	   WriteReal(xmed, 9, 6); 
	   WriteLn; 
	   Mdian1(DATA, xmed); 
	   WriteString('median according to mdian1 is'); 
	   WriteReal(xmed, 9, 6); 
	   WriteLn;
	   ReadLn;
	   DisposeVector(DATA);
	ELSE
	   Error('XMdian2', 'Not enough memory');
	END;
END XMdian2.
