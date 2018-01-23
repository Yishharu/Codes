MODULE XMMid; (* driver for routine MMid *) 
 
   FROM MMidM  IMPORT MMid;
   FROM Bessel IMPORT BessJ0, BessJ1, BessJ;
   FROM NRIO   IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                      Error;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   CONST 
      nvar = 4; 
      x1 = 1.0; 
      htot = 0.5; 
   VAR 
      b1, b2, b3, b4, xf: REAL; 
      i, ii: INTEGER; 
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
   CreateVector(nvar, Y, y);
   CreateVector(nvar, DYDX, dydx);
   CreateVector(nvar, YOUT, yout);
   IF (Y # NilVector) AND (DYDX # NilVector) AND (YOUT # NilVector) THEN
	   y^[0] := BessJ0(x1);    y^[1] := BessJ1(x1); 
	   y^[2] := BessJ(2, x1);  y^[3] := BessJ(3, x1); 
	   dydx^[0] := -y^[1];    dydx^[1] := y^[0]-y^[1]; 
	   dydx^[2] := y^[1]-2.0*y^[2];  dydx^[3] := y^[2]-3.0*y^[3]; 
	   xf := x1+htot; 
	   b1 := BessJ0(xf); 
	   b2 := BessJ1(xf); 
	   b3 := BessJ(2, xf); 
	   b4 := BessJ(3, xf); 
	   WriteString('First four Bessel functions:'); 
	   WriteLn; 
	   FOR ii := 1 TO 10 DO 
	      i := 5*ii; 
	      MMid(Y, DYDX, x1, htot, i, derivs, YOUT); 
	      WriteLn; 
	      WriteString('x := '); 
	      WriteReal(x1, 5, 2); 
	      WriteString(' to '); 
	      WriteReal(x1+htot, 5, 2); 
	      WriteString(' in '); 
	      WriteInt(i, 2); 
	      WriteString(' steps'); 
	      WriteLn; 
	      WriteString('    integration    BessJ'); 
	      WriteLn; 
	      WriteReal(yout^[0], 12, 6); 
	      WriteReal(b1, 12, 6); 
	      WriteLn; 
	      WriteReal(yout^[1], 12, 6); 
	      WriteReal(b2, 12, 6); 
	      WriteLn; 
	      WriteReal(yout^[2], 12, 6); 
	      WriteReal(b3, 12, 6); 
	      WriteLn; 
	      WriteReal(yout^[3], 12, 6); 
	      WriteReal(b4, 12, 6); 
	      WriteLn; 
	      WriteString('press return to continue...'); 
	      WriteLn; 
	      ReadLn
	   END;
	ELSE
	   Error('XMMid', 'Not enough memory.');
	END;
	IF Y # NilVector THEN DisposeVector(Y) END;
	IF DYDX # NilVector THEN DisposeVector(DYDX) END;
	IF YOUT # NilVector THEN DisposeVector(YOUT) END;
END XMMid.
