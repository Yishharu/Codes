IMPLEMENTATION MODULE FlspSc;

   FROM NRMath IMPORT RealFunction;
   FROM NRIO   IMPORT Error;

   PROCEDURE RtFlsp(fx: RealFunction; x1, x2, xacc: REAL): REAL; 
     CONST 
         maxit = 30; (* Maximum allowed number of iterations. *)
      VAR 
         xl, xh, swap, fl: REAL; 
         dx, del, f, fh, rtf: REAL; 
         j: INTEGER; 
   BEGIN 
      fl := fx(x1); 
      fh := fx(x2); (* Be sure the interval brackets a root. *)
      IF fl*fh > 0.0 THEN 
         Error('RTFLSP', 'Root must be bracketed for FALSE position'); 
      END; 
      IF fl < 0.0 THEN (* Identify the limits so that xl 
                          corresponds to the low side. *)
         xl := x1; 
         xh := x2
      ELSE 
         xl := x2; 
         xh := x1; 
         swap := fl; 
         fl := fh; 
         fh := swap
      END; 
      dx := xh-xl; 
      FOR j := 1 TO maxit DO (* False position loop. *)
         rtf := xl+dx*fl/(fl-fh); (* Increment with respect to
                                     latest value. *)
         f := fx(rtf); (* Replace appropriate limit. *)
         IF f < 0.0 THEN 
            del := xl-rtf; 
            xl := rtf; 
            fl := f
         ELSE 
            del := xh-rtf; 
            xh := rtf; 
            fh := f
         END; 
         dx := xh-xl; 
         IF (ABS(del) < xacc) OR (f = 0.0) THEN (* Convergence. *)
            RETURN rtf;
         END
      END; 
      Error('RTFLSP', 'maximum number of iterations exceeded'); 
      RETURN rtf;
   END RtFlsp; 

   PROCEDURE RtSec(fx: RealFunction; x1, x2, xacc: REAL): REAL; 
        CONST 
         maxit = 30; (* Maximum allowed number of iterations. *)
      VAR 
         dx, f, fl, swap, xl, rts: REAL; 
         j: INTEGER; 
   BEGIN 
      fl := fx(x1); 
      f := fx(x2); 
      IF ABS(fl) < ABS(f) THEN (* Pick the bound with the smaller 
                                  function value as the most recent guess. *)
         rts := x1; 
         xl := x2; 
         swap := fl; 
         fl := f; 
         f := swap
      ELSE 
         xl := x1; 
         rts := x2
      END; 
      FOR j := 1 TO maxit DO (* Secant loop. *)
         dx := (xl-rts)*f/(f-fl); 
		   (*
		     Increment with respect to
		     latest value.
		   *)
         xl := rts; 
         fl := f; 
         rts := rts+dx; 
         f := fx(rts); 
         IF (ABS(dx) < xacc) OR (f = 0.0) THEN (* Convergence. *)
            RETURN rts;
         END
      END; 
      Error('RtSec', 'maximum number of iterations exceeded'); 
      RETURN rts;
   END RtSec; 
END FlspSc.
