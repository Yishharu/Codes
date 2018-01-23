IMPLEMENTATION MODULE RKs;

   FROM NRMath   IMPORT DerivFunction;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE RK4(Y, DYDX: Vector;
                 x, h: REAL; 
                 derivs: DerivFunction; 
                 YOUT: Vector); 
      VAR 
         i, n, ndydx, nyout: INTEGER; 
         xh, hh, h6: REAL; 
         y, dydx, yout, dym, dyt, yt: PtrToReals;
         DYM, DYT, YT: Vector; 
   BEGIN 
      GetVectorAttr(Y, n, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      GetVectorAttr(YOUT, nyout, yout);
      CreateVector(n, DYM, dym);
      CreateVector(n, DYT, dyt);
      CreateVector(n, YT, yt);
      IF (DYM # NilVector) AND (DYT # NilVector) AND (YT # NilVector) THEN
	      hh := h*0.5; 
	      h6 := h/6.0; 
	      xh := x+hh; 
	      FOR i := 0 TO n-1 DO (* First step *)
	         yt^[i] := y^[i]+hh*dydx^[i]
	      END; 
	      derivs(xh, YT, DYT); (* Second step *)
	      FOR i := 0 TO n-1 DO 
	         yt^[i] := y^[i]+hh*dyt^[i]
	      END; 
	      derivs(xh, YT, DYM); (* Third step *)
	      FOR i := 0 TO n-1 DO 
	         yt^[i] := y^[i]+h*dym^[i]; 
	         dym^[i] := dyt^[i]+dym^[i]
	      END; 
	      derivs(x+h, YT, DYT); (* Fourth step *)
	      FOR i := 0 TO n-1 DO (* Accumulate the increments with proper weights. *)
	         yout^[i] := y^[i]+h6*(dydx^[i]+dyt^[i]+2.0*dym^[i])
	      END; 
	   ELSE
	      Error('RK4', 'Not enough memory.');
	   END;
      IF DYM # NilVector THEN DisposeVector(DYM); END;
      IF DYT # NilVector THEN DisposeVector(DYT); END;
      IF YT # NilVector THEN DisposeVector(YT); END;
   END RK4; 

   PROCEDURE RKDumb(VSTART: Vector; 
                    x1, x2: REAL; 
                    nstep: INTEGER;
                    derivs: DerivFunction;
                    RKDumbX: Vector;
                    RKDumbY: Matrix); 
      VAR 
         k, i, n, nX, nY, mY: INTEGER; 
         x, h: REAL; 
         V, VOUT, DV: Vector;
         v, vout, dv, rkdumbx, vstart: PtrToReals; 
         rkdumby: PtrToLines;
   BEGIN 
      GetVectorAttr(VSTART, n, vstart);
      CreateVector(n, V, v);
      CreateVector(n, VOUT, vout);
      CreateVector(n, DV, dv);
      GetVectorAttr(RKDumbX, nX, rkdumbx);
      GetMatrixAttr(RKDumbY, nY, mY, rkdumby);
      IF (V # NilVector) AND (VOUT # NilVector) AND (DV # NilVector) THEN
	      FOR i := 0 TO n-1 DO (* Load starting values. *)
	         v^[i] := vstart^[i]; 
	         rkdumby^[i]^[0] := v^[i]
	      END; 
	      rkdumbx^[0] := x1; 
	      x := x1; 
	      h := (x2-x1)/Float(nstep); 
	      FOR k := 0 TO nstep-1 DO 
		   (*
		     Take nstep steps.
		   *)
	         derivs(x, V, DV); 
	         RK4(V, DV, x, h, derivs, VOUT); 
	         IF x+h = x THEN 
	            Error('RKDumb', 'stepsize to small'); 
	         END; 
	         x := x+h; 
	         rkdumbx^[k+1] := x; (* Store intermediate steps. *)
	         FOR i := 0 TO n-1 DO 
	            v^[i] := vout^[i]; 
	            rkdumby^[i]^[k+1] := v^[i]
	         END
	      END; 
	   ELSE
	      Error('RK4', 'Not enough memory.');
	   END;
      IF DV # NilVector THEN DisposeVector(DV); END;
      IF VOUT # NilVector THEN DisposeVector(VOUT); END;
      IF V # NilVector THEN DisposeVector(V); END;
   END RKDumb; 
END RKs.
