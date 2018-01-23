MODULE XPZExtr; (* driver for routine PZExtr *) 
 
   FROM BSStepM  IMPORT PZExtr;
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
	      FOR j := 1 TO nvar DO 
	         dum := dum/(xest+1.0); 
	         yest^[j-1] := dum
	      END; 
	      PZExtr(iest, xest, YEST, YZ, DY, nuse); 
	      WriteLn; 
	      WriteString('i  :=  '); 
	      WriteInt(i, 2); 
	      WriteLn; 
	      WriteString('Extrap. function:'); 
	      FOR j := 1 TO nvar DO 
	         WriteReal(yz^[j-1], 12, 6)
	      END; 
	      WriteLn; 
	      WriteString('Estimated error: '); 
	      FOR j := 1 TO nvar DO 
	         WriteReal(dy^[j-1], 12, 6)
	      END; 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('actual values:   '); 
	   WriteReal(1.0, 12, 6); 
	   WriteReal(1.0, 12, 6); 
	   WriteReal(1.0, 12, 6); 
	   WriteReal(1.0, 12, 6); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XPZExtr', 'Not enough memory.');
	END;
	IF DY # NilVector THEN DisposeVector(DY) END;
	IF YEST # NilVector THEN DisposeVector(YEST) END;
	IF YZ # NilVector THEN DisposeVector(YZ) END;
END XPZExtr.
