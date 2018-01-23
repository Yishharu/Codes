MODULE XHQR; (* driver for routine HQR *)

   FROM BalancM IMPORT Balanc;
   FROM ElmHesM IMPORT ElmHes;
   FROM HQRM    IMPORT HQR;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,
                       NilMatrix, PtrToLines;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr,
                       NilVector;

   CONST 
      np = 5; 
   VAR 
      i, j: INTEGER; 
      A: Matrix; 
      WI, WR: Vector; 
      a: PtrToLines;
      wi, wr: PtrToReals;
       
BEGIN 
   CreateMatrix(np, np, A, a);
   CreateVector(np, WI, wi);
   CreateVector(np, WR, wr);
   IF (A # NilMatrix) AND (WI # NilVector) AND (WR # NilVector) THEN
	   a^[0]^[0] := 1.0;    a^[0]^[1] := 2.0;   a^[0]^[2] := 0.0; 
	   a^[0]^[3] := 0.0;    a^[0]^[4] := 0.0;   a^[1]^[0] := -2.0; 
	   a^[1]^[1] := 3.0;    a^[1]^[2] := 0.0;   a^[1]^[3] := 0.0; 
	   a^[1]^[4] := 0.0;    a^[2]^[0] := 3.0;   a^[2]^[1] := 4.0; 
	   a^[2]^[2] := 50.0;   a^[2]^[3] := 0.0;   a^[2]^[4] := 0.0; 
	   a^[3]^[0] := -4.0;   a^[3]^[1] := 5.0;   a^[3]^[2] := -60.0; 
	   a^[3]^[3] := 7.0;    a^[3]^[4] := 0.0;   a^[4]^[0] := -5.0; 
	   a^[4]^[1] := 6.0;    a^[4]^[2] := -70.0; a^[4]^[3] := 8.0; 
	   a^[4]^[4] := -9.0; 
	   WriteString('matrix:'); 
	   WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      FOR j := 0 TO np-1 DO 
	         WriteReal(a^[i]^[j], 12, 2)
	      END; 
	      WriteLn
	   END; 
	   Balanc(A); 
	   ElmHes(A); 
	   HQR(A, WR, WI); 
	   WriteString('eigenvalues:'); 
	   WriteLn; 
	   WriteString('       real'); 
	   WriteString('           imag.'); 
	   WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      WriteString('  '); 
	      WriteReal(wr^[i], 14, 0); 
	      WriteString('  '); 
	      WriteReal(wi^[i], 14, 0); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XElmHes', 'Not enough memory.');
	END;
	IF (A # NilMatrix) THEN DisposeMatrix(A) END;
	IF (WI # NilVector) THEN DisposeVector(WI) END;
	IF (WR # NilVector) THEN DisposeVector(WR) END;
END XHQR.
