MODULE XRZExtr; (* driver for routine RZExtr *) 
 
   FROM BSStepM  IMPORT RZExtr;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      nvar = 4; 
      nuse = 5; 
   VAR 
      dum, xest: REAL; 
      i, iest, j: INTEGER; 
      DY, YEST, YZ: Vector;
      dy, yest, yz: PtrToReals; 
       
BEGIN 
   CreateVector(nvar, DY, dy);
   CreateVector(nvar, YEST, yest);
   CreateVector(nvar, YZ, yz);
   IF (DY # NilVector) AND (YEST # NilVector) AND (YZ # NilVector) THEN
		(* feed values from a rational function *) 
		(* fn(x) := (1-x+x**3)/(x+1)**n *) 
	   FOR i := 1 TO 10 DO 
	      iest := i; 
	      xest := 1.0/Float(i); 
	      dum := 1.0-xest+xest*xest*xest; 
	      FOR j := 0 TO nvar-1 DO 
	         dum := dum/(xest+1.0); 
	         yest^[j] := dum
	      END; 
	      RZExtr(iest, xest, YEST, YZ, DY, nuse); 
	      WriteLn; 
	      WriteString('iest  :=  '); 
	      WriteInt(i, 2); 
	      WriteString('   xest ='); 
	      WriteReal(xest, 8, 4); 
	      WriteLn; 
	      WriteString('Extrap. function: '); 
	      FOR j := 0 TO nvar-1 DO 
	         WriteReal(yz^[j], 12, 6)
	      END; 
	      WriteLn; 
	      WriteString('Estimated error:  '); 
	      FOR j := 0 TO nvar-1 DO 
	         WriteReal(dy^[j], 12, 6)
	      END; 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('Actual values:    '); 
	   WriteReal(1.0, 12, 6); 
	   WriteReal(1.0, 12, 6); 
	   WriteReal(1.0, 12, 6); 
	   WriteReal(1.0, 12, 6); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XRZExtr', 'Not enough memory.');
	END;
	IF DY # NilVector THEN DisposeVector(DY) END;
	IF YEST # NilVector THEN DisposeVector(YEST) END;
	IF YZ # NilVector THEN DisposeVector(YZ) END;
END XRZExtr.
