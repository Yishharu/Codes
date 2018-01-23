IMPLEMENTATION MODULE BSStepM;

   FROM MMidM    IMPORT MMid;
   FROM NRMath   IMPORT DerivFunction;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

	CONST
	   RzextrImax  =  11;(* Maximum expected value of iest is RzextrImax;
                           of n is RzextrNmax; of nuse is RzextrNcol.
                           Usually tRzextrNmax=nvar. *)
	   RzextrNmax  =  10;
	   RzextrNcol  =  7;
	   PzextrImax  =  11;(* Maximum expected value of iest is PzextrImax;
                           of n is PzextrNmax; of use is PzextrNcol.
                           Usually tPzextrNmax=nvar. *)
	   PzextrNmax  =  10;
	   PzextrNcol  =  7;
   VAR
	   RzextrX: ARRAY [1..RzextrImax] OF REAL;
	   RzextrD: ARRAY [1..RzextrNmax],[1..RzextrNcol] OF REAL;
	   PzextrX: ARRAY [1..PzextrImax] OF REAL;
	   PzextrQcol: ARRAY [1..PzextrNmax],[1..PzextrNcol] OF REAL;

   PROCEDURE RZExtr(iest: INTEGER; 
                    xest: REAL; 
                    YEST, YZ, DY: Vector; 
                    nuse: INTEGER); 
      VAR 
         m1, k, j, n, nyz, ndy: INTEGER; 
         yy, v, ddy, c, b1, b: REAL; 
          yest, yz, dy: PtrToReals;
         fx: ARRAY [1..RzextrNcol] OF REAL; 

   BEGIN 
      GetVectorAttr(YEST, n, yest);
      GetVectorAttr(YZ, nyz, yz);
      GetVectorAttr(DY, ndy, dy);
      RzextrX[iest] := xest; (* Save current independent variable. *)
      IF iest = 1 THEN 
         FOR j := 1 TO n DO 
            yz^[j-1] := yest^[j-1]; 
            RzextrD[j, 1] := yest^[j-1]; 
            dy^[j-1] := yest^[j-1]
         END
      ELSE 
         IF iest < nuse THEN m1 := iest ELSE m1 := nuse END; 
                                               (* At most nuse previous estimates. *)
         FOR k := 1 TO m1-1 DO 
            fx[k+1] := RzextrX[iest-k]/xest
         END; 
         FOR j := 1 TO n DO (* Evaluate next diagonal in tableau. *)
            yy := yest^[j-1]; 
            v := RzextrD[j, 1]; 
            c := yy; 
            RzextrD[j, 1] := yy; 
            FOR k := 2 TO m1 DO 
               b1 := fx[k]*v; 
               b := b1-c; 
               IF b <> 0.0 THEN 
                  b := (c-v)/b; 
                  ddy := c*b; 
                  c := b1*b
               ELSE (* Care needed to avoid division by 0. *)
                  ddy := v
               END; 
               IF k <> m1 THEN 
                  v := RzextrD[j, k]
               END; 
               RzextrD[j, k] := ddy; 
               yy := yy+ddy
            END; 
            dy^[j-1] := ddy; 
            yz^[j-1] := yy
         END
      END
   END RZExtr; 

   PROCEDURE PZExtr(iest: INTEGER; 
                    xest: REAL; 
                    YEST, YZ, DY: Vector; 
                    nuse: INTEGER); 
      VAR 
         m1, k1, j, n, nyz, ndy: INTEGER; 
         q, f2, f1, delta: REAL; 
         D: Vector;
         yest, yz, dy, d: PtrToReals;
   BEGIN 
      GetVectorAttr(YEST, n, yest);
      GetVectorAttr(YZ, nyz, yz);
      GetVectorAttr(DY, ndy, dy);
      CreateVector(n, D, d);
      IF D # NilVector THEN
	      PzextrX[iest] := xest; (* Store current dependent value. *)
	      FOR j := 0 TO n-1 DO 
	         dy^[j] := yest^[j]; 
	         yz^[j] := yest^[j]
	      END; 
	      IF iest = 1 THEN (* Store first estimate in first column. *)
	         FOR j := 1 TO n DO 
	            PzextrQcol[j, 1] := yest^[j-1]
	         END
	      ELSE 
	         IF iest < nuse THEN m1 := iest ELSE m1 := nuse END; 
	                                                (* Use at most nuse previous estimates. *)
	         FOR j := 0 TO n-1 DO 
	            d^[j] := yest^[j]
	         END; 
	         FOR k1 := 1 TO m1-1 DO 
	            delta := 1.0/(PzextrX[iest-k1]-xest); 
	            f1 := xest*delta; 
	            f2 := PzextrX[iest-k1]*delta; 
	            FOR j := 1 TO n DO (* Propagate tableau 1 diagonal more. *)
	               q := PzextrQcol[j, k1]; 
	               PzextrQcol[j, k1] := dy^[j-1]; 
	               delta := d^[j-1]-q; 
	               dy^[j-1] := f1*delta; 
	               d^[j-1] := f2*delta; 
	               yz^[j-1] := yz^[j-1]+dy^[j-1]
	            END
	         END; 
	         FOR j := 1 TO n DO 
	            PzextrQcol[j, m1] := dy^[j-1]
	         END
	      END; 
	      DisposeVector(D);
	   ELSE
	      Error('PZExtr', 'Not enough memory.');
	   END;
   END PZExtr; 

   PROCEDURE BSStep(    Y, DYDX: Vector; 
                    VAR x: REAL; 
                        htry, eps: REAL; 
                        YSCAL: Vector; 
                        derivs: DerivFunction;
                    VAR hdid, hnext: REAL); 
      CONST 
         imax = 11; 
         nuse = 7; 
         shrink = 0.95E0; 
         grow = 1.2E0; 
      VAR 
         j, i, n, ndydx, nyscal: INTEGER; 
         xsav, xest, h, errmax: REAL; 
         YSAV, DYSAV, YSEQ, YERR: Vector;
         y, dydx, yscal, ysav, dysav, yseq, yerr: PtrToReals; 
         nseq: ARRAY [1..imax] OF INTEGER; 
   BEGIN 
      GetVectorAttr(Y, n, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      GetVectorAttr(YSCAL, nyscal, yscal);
      CreateVector(n, YSAV, ysav);
      CreateVector(n, DYSAV, dysav);
      CreateVector(n, YSEQ, yseq);
      CreateVector(n, YERR, yerr);
      IF (YSAV # NilVector) AND (DYSAV # NilVector) AND (YSEQ # NilVector) AND
          (YERR # NilVector) THEN
	      nseq[1] := 2;    nseq[2] := 4;    nseq[3] := 6;   nseq[4] := 8; 
	      nseq[5] := 12;   nseq[6] := 16;   nseq[7] := 24;  nseq[8] := 32; 
	      nseq[9] := 48;   nseq[10] := 64;  nseq[11] := 96; 
	      h := htry; 
	      xsav := x; 
	      FOR i := 0 TO n-1 DO (* Save the starting values. *)
	         ysav^[i] := y^[i]; 
	         dysav^[i] := dydx^[i]
	      END; 
	      LOOP 
	         FOR i := 1 TO imax DO (* Evaluate the sequence of modified midpoint 
                                     integrations. *)
	            MMid(YSAV, DYSAV, xsav, h, nseq[i], derivs, YSEQ); 
	            xest := (h/Float(nseq[i]))*(h/Float(nseq[i])); (* Squared, since error series is
                                                               even. *)
	            RZExtr(i, xest, YSEQ, Y, YERR, nuse); 
                                            (* Rational function extrapolation. *)
	            IF i > 3 THEN (* Guard against spurious early convergence. *)
	               errmax := 0.0; (* Check local truncation error. *)
	               FOR j := 0 TO n-1 DO 
	                  IF errmax < ABS(yerr^[j]/yscal^[j]) THEN 
	                     errmax := ABS(yerr^[j]/yscal^[j])
	                  END
	               END; 
	               errmax := errmax/eps; (* Scale accuracy relative to tolerance. *)
	               IF errmax < 1.0 THEN (* Step converged. *)
	                  x := x+h; 
	                  hdid := h; 
	                  IF i = nuse THEN 
	                     hnext := h*shrink
	                  ELSIF i = nuse-1 THEN 
	                     hnext := h*grow
	                  ELSE 
	                     hnext := (h*Float(nseq[nuse-1]))/Float(nseq[i])
	                  END; 
	                  EXIT; (* Normal return. *)
	               END
	            END
	         END; 
			   (*
			     If here, then step failed, quite unusual for this method.
			     We reduce the stepsize and try again.
			   *)
	         h := 0.25*h; 
	         FOR i := 1 TO (imax-nuse) DIV 2 DO 
	            h := h/Float(2)
	         END; 
	         IF x+h = x THEN 
	            Error('BSStep', 'step size underflow'); 
	         END
	      END; 
	   ELSE
	      Error('BSStep', 'Not enough memory.');
	   END;
      IF YERR # NilVector THEN DisposeVector(YERR); END;
      IF YSEQ # NilVector THEN DisposeVector(YSEQ); END;
      IF DYSAV # NilVector THEN DisposeVector(DYSAV); END;
      IF YSAV # NilVector THEN DisposeVector(YSAV); END;
   END BSStep; 

END BSStepM.
