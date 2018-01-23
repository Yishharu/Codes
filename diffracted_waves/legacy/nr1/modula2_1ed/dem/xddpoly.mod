MODULE XDDPoly; (* driver for routine DDPOLY *) 
                (* polynomial (x-1)**5 *) 

   FROM PolRat   IMPORT DDPoly;
   FROM GammBeta IMPORT Factrl;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn,  ReadInt, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector;

   CONST 
      nc = 6; 
      nd = 5; (* nd=nc-1 *) 
      np = 20; 
   TYPE 
      CharArray15 = ARRAY [1..15] OF CHAR; 
   VAR 
      i, j: INTEGER; 
      x: REAL; 
      C, PD: Vector; 
      c, pd: PtrToReals; 
      D: Matrix; 
      d: PtrToLines;
      a: ARRAY [0..nd-1] OF CharArray15; 
      FactrlNtop: INTEGER; 

   PROCEDURE power(x: REAL; n: INTEGER): REAL; 
   BEGIN 
      IF n = 0 THEN RETURN 1.0 ELSE RETURN x*power(x, n-1) END; 
   END power; 
    
BEGIN 
   CreateVector(nc, C, c);
   CreateVector(nd, PD, pd);
   CreateMatrix(nd, np, D, d);
   IF (C # NilVector) AND (PD # NilVector) AND (D # NilMatrix) THEN
	   FactrlNtop := 0; 
	   a[0] := 'polynomial:    '; 
	   a[1] := 'first deriv:   '; 
	   a[2] := 'second deriv:  '; 
	   a[3] := 'third deriv:   '; 
	   a[4] := 'fourth deriv:  '; 
	   c^[0] := -1.0; 
	   c^[1] := 5.0; 
	   c^[2] := -10.0; 
	   c^[3] := 10.0; 
	   c^[4] := -5.0; 
	   c^[5] := 1.0; 
	   FOR i := 0 TO np-1 DO 
	      x := 0.1*Float(i+1); 
	      DDPoly(C, x, PD); 
	      FOR j := 0 TO nc-2 DO 
	         d^[j]^[i] := pd^[j]
	      END
	   END; 
	   FOR i := 0 TO nc-2 DO 
	      WriteString('       '); 
	      WriteString(a[i]); 
	      WriteLn; 
	      WriteString('           x'); 
	      WriteString('           DDPOLY'); 
	      WriteString('         actual'); 
	      WriteLn; 
	      FOR j := 0 TO np-1 DO 
	         x := 0.1*Float(j+1); 
	         WriteReal(x, 15, 6); 
	         WriteReal(d^[i]^[j], 15, 6); 
	         WriteReal((Factrl(nc-1)/Factrl(nc-i-1))*power(x-1.0, nc-i-1), 15, 6); 
	         WriteLn
	      END; 
	      WriteString('press ENTER to continue...'); 
	      WriteLn; 
	      ReadLn
	   END;
	   IF (C # NilVector) THEN DisposeVector(C) END;
	   IF (PD # NilVector) THEN DisposeVector(PD) END;
	   IF (D # NilMatrix) THEN DisposeMatrix(D) END;
	ELSE
	   Error('XDDPoly', 'Not enough memory.');
	END;
END XDDPoly.
