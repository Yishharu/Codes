IMPLEMENTATION MODULE MMidM;

   FROM NRMath   IMPORT DerivFunction;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE MMid(Y, DYDX: Vector; 
                  xs, htot: REAL; 
                  nstep: INTEGER; 
                  derivs: DerivFunction;
                  YOUT: Vector); 
      VAR 
         step, i, n, ndydx, nyout: INTEGER; 
         x, swap, h2, h: REAL; 
         YM, YN: Vector;
         y, dydx, yout, ym, yn: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, n, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      GetVectorAttr(YOUT, nyout, yout);
      CreateVector(n, YM, ym);
      CreateVector(n, YN, yn);
      IF (YM # NilVector) AND (YN # NilVector) THEN
	      h := htot/Float(nstep); (* Stepsize this trip. *)
	      FOR i := 0 TO n-1 DO 
	         ym^[i] := y^[i]; 
	         yn^[i] := y^[i]+h*dydx^[i]
			   (*
			     First step.
			   *)
	      END; 
	      x := xs+h; 
	      derivs(x, YN, YOUT); (* Will use YOUT for temporary
                               storage of derivatives. *)
	      h2 := 2.0*h; 
	      FOR step := 2 TO nstep DO (* General step. *)
	         FOR i := 0 TO n-1 DO 
	            swap := ym^[i]+h2*yout^[i]; 
	            ym^[i] := yn^[i]; 
	            yn^[i] := swap
	         END; 
	         x := x+h; 
	         derivs(x, YN, YOUT)
	      END; 
	      FOR i := 0 TO n-1 DO (* Last step. *)
	         yout^[i] := 0.5*(ym^[i]+yn^[i]+h*yout^[i])
	      END;
	   ELSE
	      Error('MMid', 'Not enough memory.');
	   END;
      IF YM # NilVector THEN DisposeVector(YM); END;
      IF YN # NilVector THEN DisposeVector(YN); END;
   END MMid; 

END MMidM.
