IMPLEMENTATION MODULE IterImpr;

   FROM NRSystem IMPORT LongReal, D, S;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, GetMatrixAttr, PtrToLines;
   FROM NRIVect  IMPORT IVector;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        GetVectorAttr;
   FROM LUDecomp IMPORT LUBKSB;

   PROCEDURE Mprove(A, 
                    ALUD: Matrix; 
                    INDX: IVector; 
                    B, 
                    X:    Vector); 
      VAR 
         j, i, n, nA, mA, nX: INTEGER; 
         sdp: LongReal; 
         R:  Vector;
         b, r, x:  PtrToReals; 
         a: PtrToLines;
   BEGIN 
      GetMatrixAttr(A, nA, mA, a);
      GetVectorAttr(B, n, b);
      GetVectorAttr(X, nX, x);
      IF (nA = mA) AND (nA = n) AND (n = nX) THEN
	      CreateVector(n, R, r);
	      FOR i := 0 TO n-1 DO (* Calculate the right-hand side, accumulating
                                 the residual in double precision. *)
	         sdp := D(-b^[i]);
	         FOR j := 0 TO n-1 DO
	            sdp := sdp+D(a^[i]^[j])*D(x^[j])
	         END; 
	         r^[i] := S(sdp)
	      END; 
	      LUBKSB(ALUD, INDX, R); (* Solve for the error term, *)
	      FOR i := 0 TO n-1 DO (* and subtract it from the old solution. *)
	         x^[i] := x^[i]-r^[i]
	      END; 
	      DisposeVector(R)
	   ELSE
	      Error('Mprove', 'Inproper input data!');
	   END;
   END Mprove; 

END IterImpr.
