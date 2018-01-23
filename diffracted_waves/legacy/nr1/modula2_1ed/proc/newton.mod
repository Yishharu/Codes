IMPLEMENTATION MODULE Newton;

   FROM NRIO IMPORT  Error;

   PROCEDURE RtNewt(funcd: DerivFunction; x1, x2, xacc: REAL): REAL; 
        CONST 
         jmax = 20; (* Set to maximum number of iterations. *)
      VAR 
         df, dx, f, rtn: REAL; 
         j: INTEGER; 
   BEGIN 
      rtn := 0.5*(x1+x2); (* Initial guess. *)
      FOR j := 1 TO jmax DO 
         funcd(rtn, f, df); 
         dx := f/df; 
         rtn := rtn-dx; 
         IF (x1-rtn)*(rtn-x2) < 0.0 THEN 
            Error('RTNEWT', 'jumped out of brackets'); 
         END; 
         IF ABS(dx) < xacc THEN (* Convergence. *)
            RETURN rtn;
         END
      END; 
      Error('RtNewt', 'maximum number of iterations exceeded'); 
      RETURN rtn
   END RtNewt; 

   PROCEDURE RtSafe(funcd: DerivFunction; x1, x2, xacc: REAL): REAL; 
        CONST 
         maxit = 100; (* Maximum allowed number of iterations. *)
      VAR 
         df, dx, dxold, f, fh, fl: REAL; 
         temp, xh, xl, rts: REAL; 
         j: INTEGER; 
   BEGIN 
      funcd(x1, fl, df); 
      funcd(x2, fh, df); 
      IF fl*fh >= 0.0 THEN 
         Error('RTSAFE', 'root must be bracketed'); 
      END; 
      IF fl < 0.0 THEN (* Orient the search so that f(xl)<0. *)
         xl := x1; 
         xh := x2
      ELSE 
         xh := x1; 
         xl := x2
      END; 
      rts := 0.5*(x1+x2); (* Initialize the guess for root, *)
      dxold := ABS(x2-x1); (* the "step-size before last," *)
      dx := dxold; (* and the last step. *)
      funcd(rts, f, df); 
      FOR j := 1 TO maxit DO 
	   (*
	     Loop over allowed iterations.
	   *)
         IF (((rts-xh)*df-f)*((rts-xl)*df-f) >= 0.0) (* Bisect if Newton out of range, *)
            OR (ABS(2.0*f) > ABS(dxold*df)) THEN (* or not decreasing fast enough. *)
            dxold := dx; 
            dx := 0.5*(xh-xl); 
            rts := xl+dx; 
            IF xl = rts THEN (* Change in root is
                                negligible. *)
               RETURN rts;
            END
         ELSE (* Newton step acceptable.  Take it. *)
            dxold := dx; 
            dx := f/df; 
            temp := rts; 
            rts := rts-dx; 
            IF temp = rts THEN 
               RETURN rts;
            END
         END; 
         IF ABS(dx) < xacc THEN (* Convergence criterion. *)
            RETURN rts;
         END; 
         funcd(rts, f, df); (* The one new function
                               evaluation per iteration. *)
         IF f < 0.0 THEN (* Maintain the bracket on the root. *)
            xl := rts
         ELSE 
            xh := rts
         END
      END; 
      Error('pause in RTSAFE', 'maximum number of iterations exceeded'); 
      RETURN rts;
   END RtSafe; 
END Newton.
