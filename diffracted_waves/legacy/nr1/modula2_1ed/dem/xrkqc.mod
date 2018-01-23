MODULE XRKQC; (* driver for routine RKQC *) 
 
   FROM AccMon   IMPORT RKQC;
   FROM Bessel   IMPORT BessJ0, BessJ1, BessJ;
   FROM NRMath   IMPORT Exp;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      n = 4; 
   VAR 
      eps, hdid, hnext, htry, x: REAL; 
      i: INTEGER; 
      Y, DYDX, YSCAL: Vector;
      y, dydx, yscal: PtrToReals; 
       
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
   CreateVector(n, YSCAL, yscal);
   IF (Y # NilVector) AND (DYDX # NilVector) AND (YSCAL # NilVector) THEN
	   x := 1.0; 
	   y^[0] := BessJ0(x);        y^[1] := BessJ1(x); 
	   y^[2] := BessJ(2, x);      y^[3] := BessJ(3, x); 
	   dydx^[0] := -y^[1];           dydx^[1] := y^[0]-y^[1]; 
	   dydx^[2] := y^[1]-2.0*y^[2];  dydx^[3] := y^[2]-3.0*y^[3]; 
	   FOR i := 0 TO n-1 DO yscal^[i] := 1.0 END; 
	   htry := 0.1; 
	   WriteString('     eps         htry        hdid        hnext'); 
	   WriteLn; 
	   FOR i := 1 TO 15 DO 
	      eps := Exp(Float(-i)); 
	      RKQC(Y, DYDX, x, htry, eps, YSCAL, derivs, hdid, hnext); 
	      WriteReal(eps, 14, -10); 
	      WriteReal(htry, 8, 2); 
	      WriteReal(hdid, 14, 6); 
	      WriteReal(hnext, 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XMMid', 'Not enough memory.');
	END;
	IF Y # NilVector THEN DisposeVector(Y) END;
	IF DYDX # NilVector THEN DisposeVector(DYDX) END;
	IF YSCAL # NilVector THEN DisposeVector(YSCAL) END;
END XRKQC.
