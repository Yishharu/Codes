MODULE XRK4; (* driver for routine RK4 *) 
 
   FROM RKs      IMPORT RK4;
   FROM Bessel   IMPORT BessJ0, BessJ1, BessJ;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      n = 4; 
   VAR 
      h, x: REAL; 
      i, j: INTEGER; 
      Y, DYDX, YOUT: Vector;
      y, dydx, yout: PtrToReals; 
       
   PROCEDURE derivs(x: REAL; 
                    Y, DYDX: Vector); 
      VAR
         ny, ndydx: INTEGER;
         y, dydx: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      dydx^[0] := -y^[1]; 
      dydx^[1] := y^[0]-(1.0/x)*y^[1]; 
      dydx^[2] := y^[1]-(2.0/x)*y^[2]; 
      dydx^[3] := y^[2]-(3.0/x)*y^[3]
   END derivs; 
    
BEGIN 
   CreateVector(n, Y, y);
   CreateVector(n, DYDX, dydx);
   CreateVector(n, YOUT, yout);
   IF (Y # NilVector) AND (DYDX # NilVector) AND (YOUT # NilVector) THEN
	   x := 1.0; 
	   y^[0] := BessJ0(x);    y^[1] := BessJ1(x); 
	   y^[2] := BessJ(2, x);  y^[3] := BessJ(3, x); 
	   dydx^[0] := -y^[1];    dydx^[1] := y^[0]-y^[1]; 
	   dydx^[2] := y^[1]-2.0*y^[2];  dydx^[3] := y^[2]-3.0*y^[3]; 
	   WriteLn; 
	   WriteString('Bessel function:'); 
	   WriteString('   j0          j1          j3          j4'); 
	   WriteLn; 
	   FOR i := 1 TO 5 DO 
	      h := 0.2*Float(i); 
	      RK4(Y, DYDX, x, h, derivs, YOUT); 
	      WriteLn; 
	      WriteString('for a step size of:'); 
	      WriteReal(h, 6, 2); 
	      WriteLn; 
	      WriteString('      RK4: '); 
	      FOR j := 0 TO 3 DO 
	         WriteReal(yout^[j], 12, 6);
	      END; 
	      WriteLn; 
	      WriteString('   actual: '); 
	      WriteReal(BessJ0(x+h), 12, 6);
	      WriteReal(BessJ1(x+h), 12, 6);
	      WriteReal(BessJ(2, x+h), 12, 6);
	      WriteReal(BessJ(3, x+h), 12, 6);
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('', 'Not enough memory.');
	END;
	IF Y # NilVector THEN DisposeVector(Y) END;
	IF DYDX # NilVector THEN DisposeVector(DYDX) END;
	IF YOUT # NilVector THEN DisposeVector(YOUT) END;
END XRK4.
