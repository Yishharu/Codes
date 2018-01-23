IMPLEMENTATION MODULE AccMon;

   FROM RKs    IMPORT RK4;
   FROM NRMath IMPORT DerivFunction, Exp, Ln;
   FROM NRIO   IMPORT Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   PROCEDURE RKQC(    Y, DYDX: Vector; 
                  VAR x: REAL; 
                      htry, eps: REAL; 
                      YSCAL: Vector; 
                      derivs: DerivFunction;
                  VAR hdid, hnext: REAL); 
      CONST 
         pgrow = -0.20; 
         pshrnk = -0.25; 
         fcor = 0.06666666; (* This is 1/15. *)
         safety = 0.9; (* The value errcon equals (4/safety) raised to
                          the power (1/pgrow), see use below. *)
         errcon = 6.0E-4; 
      VAR 
         i, n, ndydx, nyscal: INTEGER; 
         xsav, hh, h, temp, errmax: REAL; 
         DYSAV, YSAV, YTEMP: Vector;
         y, dydx, yscal, dysav, ysav, ytemp: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, n, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      GetVectorAttr(YSCAL, nyscal, yscal);
      CreateVector(n, DYSAV, dysav);
      CreateVector(n, YSAV, ysav);
      CreateVector(n, YTEMP, ytemp);
      IF (DYSAV # NilVector) AND (YSAV # NilVector) AND (YTEMP # NilVector) THEN
	      xsav := x; (* Save initial values. *)
	      FOR i := 0 TO n-1 DO 
	         ysav^[i] := y^[i]; 
	         dysav^[i] := dydx^[i]
	      END; 
	      h := htry; (* Set stepsize to the initial trial value. *)
	      LOOP 
	         hh := 0.5*h; (* Take two half steps. *)
	         RK4(YSAV, DYSAV, xsav, hh, derivs, YTEMP); 
	         x := xsav+hh; 
	         derivs(x, YTEMP, DYDX); 
	         RK4(YTEMP, DYDX, x, hh, derivs, Y); (* Take the large step. *)
	         x := xsav+h; 
	         IF x = xsav THEN Error('RKQC', 'stepsize too small'); END; 
	         RK4(YSAV, DYSAV, xsav, h, derivs, YTEMP); 
	         errmax := 0.0; (* Evaluate accuracy. *)
	         FOR i := 0 TO n-1 DO 
	            ytemp^[i] := y^[i]-ytemp^[i]; (* YTEMP now contains the error estimate. *)
	            temp := ABS(ytemp^[i]/yscal^[i]); 
	            IF errmax < temp THEN errmax := temp END
	         END; 
	         errmax := errmax/eps; (* Scale relative to required tolerance. *)
	         IF errmax <= 1.0 THEN (* Step succeeded.  Compute size of next step. *)
	            hdid := h; 
	            IF errmax > errcon THEN 
	               hnext := safety*h*Exp(pgrow*Ln(errmax))
	            ELSE 
	               hnext := 4.0*h
	            END; 
	            EXIT; 
	         ELSE (* Truncation error too large, reduce
                  stepsize and try again. *)
	            h := safety*h*Exp(pshrnk*Ln(errmax))
	         END; 
	      END; 
	      FOR i := 0 TO n-1 DO (* Mop up fifth-order truncation error. *)
	         y^[i] := y^[i]+ytemp^[i]*fcor
	      END; 
	   ELSE
	      Error('RKQC', 'Not enough memory.');
	   END;
      IF DYSAV # NilVector THEN DisposeVector(DYSAV); END;
      IF YSAV # NilVector THEN DisposeVector(YSAV); END;
      IF YTEMP # NilVector THEN DisposeVector(YTEMP); END;
   END RKQC; 

   PROCEDURE ODEInt(    YSTART: Vector; 
                        x1, x2, eps, h1, hmin: REAL; 
                        derivs: DerivFunction;
                        OdeintDxsav: REAL;
                        OdeintKmax: INTEGER;
                        ODEIntXp: Vector;
                        ODEIntYp: Matrix;
                    VAR OdeintKount: INTEGER;
                    VAR nok, nbad: INTEGER); 
      CONST 
         maxstp = 10000; 
         tiny = 1.0E-30; 
      VAR 
         nstp, i, n, nstep, nYp, mYp: INTEGER; 
         xsav, x, hnext, hdid, h: REAL; 
         YSCAL, Y, DYDX: Vector;
         ystart, yscal, y, dydx, odeIntXp: PtrToReals; 
         odeIntYp: PtrToLines;
   BEGIN 
      GetVectorAttr(YSTART, n, ystart);
      GetVectorAttr(ODEIntXp, nstep, odeIntXp);
      GetMatrixAttr(ODEIntYp, nYp, mYp, odeIntYp);
      CreateVector(n, YSCAL, yscal);
      CreateVector(n, Y, y);
      CreateVector(n, DYDX, dydx);
      IF (YSCAL # NilVector) AND (Y # NilVector) AND (DYDX # NilVector) THEN
	      x := x1; 
	      IF x2 >= x1 THEN 
	         h := ABS(h1)
	      ELSE 
	         h := -ABS(h1)
	      END; 
	      nok := 0; 
	      nbad := 0; 
	      OdeintKount := 0; 
	      FOR i := 0 TO n-1 DO 
	         y^[i] := ystart^[i]
	      END; 
	      IF OdeintKmax > 0 THEN (* Assures storage of first step. *)
	         xsav := x-2.0*OdeintDxsav
	      END; 
	      FOR nstp := 1 TO maxstp DO (* Take at most maxstp steps. *)
	         derivs(x, Y, DYDX); 
	         FOR i := 0 TO n-1 DO (* Scaling used to monitor accuracy.  This
                                  general-purpose choice can
                                  be modified if need be. *)
	            yscal^[i] := ABS(y^[i])+ABS(dydx^[i]*h)+tiny
	         END; 
	         IF OdeintKmax > 0 THEN 
	            IF ABS(x-xsav) > ABS(OdeintDxsav) THEN (* Store intermediate results. *)
	               IF OdeintKount < OdeintKmax-1 THEN 
	                  OdeintKount := OdeintKount+1; 
	                  odeIntXp^[OdeintKount-1] := x; 
	                  FOR i := 1 TO n DO 
	                     odeIntYp^[i-1]^[OdeintKount-1] := y^[i-1]
	                  END; 
	                  xsav := x
	               END
	            END
	         END; 
	         IF (x+h-x2)*(x+h-x1) > 0.0 THEN (* If step can overshoot end, cut down stepsize. *)
	            h := x2-x
	         END; 
	         RKQC(Y, DYDX, x, h, eps, YSCAL, derivs, hdid, hnext); 
	         IF hdid = h THEN 
	            INC(nok, 1)
	         ELSE 
	            INC(nbad, 1)
	         END; 
	         IF (x-x2)*(x2-x1) >= 0.0 THEN (* Are we done? *)
	            FOR i := 0 TO n-1 DO 
	               ystart^[i] := y^[i]
	            END; 
	            IF OdeintKmax <> 0 THEN 
	               OdeintKount := OdeintKount+1; (* Save final step. *)
	               odeIntXp^[OdeintKount-1] := x; 
	               FOR i := 1 TO n DO 
	                  odeIntYp^[i-1]^[OdeintKount-1] := y^[i-1]
	               END
	            END; 
			      IF DYDX # NilVector THEN DisposeVector(DYDX); END;
			      IF Y # NilVector THEN DisposeVector(Y); END;
			      IF YSCAL # NilVector THEN DisposeVector(YSCAL); END;
			      RETURN;(* Normal exit. *)
	         END; 
	         IF ABS(hnext) < hmin THEN 
	            Error('ODEInt', 'Stepsize too small'); 
	         END; 
	         h := hnext; 
	      END; 
	      Error('ODEInt', 'Too many steps.'); 
	   ELSE
	      Error('ODEInt', 'Not enough memory.');
	   END;
      IF DYDX # NilVector THEN DisposeVector(DYDX); END;
      IF Y # NilVector THEN DisposeVector(Y); END;
      IF YSCAL # NilVector THEN DisposeVector(YSCAL); END;
   END ODEInt; 

END AccMon.
