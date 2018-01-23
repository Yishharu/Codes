IMPLEMENTATION MODULE GoldenM;

   FROM NRMath IMPORT RealFunction;
   FROM NRIO   IMPORT Error;

   PROCEDURE Golden(    ax, bx, cx: REAL;
                        func:       RealFunction;
                        tol:        REAL; 
                    VAR xmin:       REAL): REAL; 
      CONST 
         r = 0.61803399; 
      VAR 
         f1, f2, c: REAL; 
         x0, x1, x2, x3, golden: REAL; 
   BEGIN 
      c := 1.0-r; 
      x0 := ax; (* At any given time we will keep track of
                   four points, x0, x1, x2, x3. *)
      x3 := cx; 
      IF ABS(cx-bx) > ABS(bx-ax) THEN 
	   (*
	     Make x0 to x1 the smaller segment,
	   *)
         x1 := bx; 
         x2 := bx+c*(cx-bx)
		   (*
		     and fill in the new point to be tried.
		   *)
      ELSE 
         x2 := bx; 
         x1 := bx-c*(bx-ax)
      END; 
      f1 := func(x1); (* The initial function evaluations.  Note that
                         we never need to evaluate the function at the original endpoints. *)
      f2 := func(x2); 
      WHILE ABS(x3-x0) > tol*(ABS(x1)+ABS(x2)) DO 
	   (*
	     Keep returning here.
	   *)
         IF f2 < f1 THEN (* One possible outcome, *)
            x0 := x1; 
			   (*
			     its housekeeping,
			   *)
            x1 := x2; 
            x2 := r*x1+c*x3; 
            f1 := f2; 
            f2 := func(x2)
			   (*
			     and a new function evaluation.
			   *)
         ELSE 
		   (*
		     The other outcome,
		   *)
            x3 := x2; 
            x2 := x1; 
            x1 := r*x2+c*x0; 
            f2 := f1; 
            f1 := func(x1)
			   (*
			     and its new function evaluation.
			   *)
         END
      END; 
	   (*
	     Back to see if we are done.
	   *)
      IF f1 < f2 THEN (* We are done.  Output the best of the
                         two current values. *)
         golden := f1; 
         xmin := x1
      ELSE 
         golden := f2; 
         xmin := x2
      END; 
      RETURN golden
   END Golden; 

   PROCEDURE MnBrak(VAR ax, bx, cx, fa, fb, fc: REAL;
                        func: RealFunction); 
      CONST 
         gold = 1.618034; 
		   (*
		     Default ratio for magnifying successive intervals.
		   *)
         glimit = 100.0; 
		   (*
		     Maximum magnification allowed for a parabolic-fit step.
		   *)
         tiny = 1.0E-20; 
      VAR 
         ulim, u, r, q, fu, dum: REAL; 
   BEGIN 
      fa := func(ax); 
      fb := func(bx); 
      IF fb > fa THEN (* Switch roles of ax and bx so that
                         we can go downhill in the direction from ax to bx. *)
         dum := ax; 
         ax := bx; 
         bx := dum; 
         dum := fb; 
         fb := fa; 
         fa := dum
      END; 
      cx := bx+gold*(bx-ax); 
	   (*
	     First guess for cx.
	   *)
      fc := func(cx); 
      WHILE fb >= fc DO (* Keep returning
                           here until we bracket. *)
         r := (bx-ax)*(fb-fc); (* Compute U by parabolic extrapolation from ax, 
                                  bx, cx. tiny is used to prevent any possible
                                  division by zero. *)
         q := (bx-cx)*(fb-fa); 
         IF ABS(q-r) > tiny THEN 
            dum := ABS(q-r)
         ELSE 
            dum := tiny
         END; 
         IF q-r < 0.0 THEN 
            dum := (-dum)
         END; 
         u := bx-((bx-cx)*q-(bx-ax)*r)/(2.0*dum); 
         ulim := bx+glimit*(cx-bx); 
		   (*
		     We won't go farther than this. Now to test various possibilities:
		   *)
         IF (bx-u)*(u-cx) > 0.0 THEN (* Parabolic U is
                                        between bx and cx: try it. *)
            fu := func(u); 
            IF fu < fc THEN (* Got a minimum between bx and cx. *)
               ax := bx; 
               fa := fb; 
               bx := u; 
               fb := fu; 
               RETURN (* (Exit). *)
            ELSIF fu > fb THEN (* Got a minimum between between ax and U. *)
               cx := u; 
               fc := fu; 
               RETURN (* (Exit). *)
            END; 
            u := cx+gold*(cx-bx); (* Parabolic fit was no use.
                                     Use default magnification. *)
            fu := func(u)
         ELSIF (cx-u)*(u-ulim) > 0.0 THEN (* Parabolic fit is between cx
                                             and its allowed limit. *)
            fu := func(u); 
            IF fu < fc THEN 
               bx := cx; 
               cx := u; 
               u := cx+gold*(cx-bx); 
               fb := fc; 
               fc := fu; 
               fu := func(u)
            END
         ELSIF (u-ulim)*(ulim-cx) >= 0.0 THEN 
            u := ulim; (* Limit parabolic U to maximum allowed value. *)
            fu := func(u)
         ELSE (* Reject parabolic U, use default magnification. *)
            u := cx+gold*(cx-bx); 
            fu := func(u)
         END; 
         ax := bx; (* Eliminate oldest point and continue. *)
         bx := cx; 
         cx := u; 
         fa := fb; 
         fb := fc; 
         fc := fu
      END; 
   END MnBrak; 

END GoldenM.
