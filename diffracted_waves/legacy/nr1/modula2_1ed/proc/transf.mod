IMPLEMENTATION MODULE Transf;

   FROM Uniform IMPORT Ran3;
   FROM NRMath IMPORT Sqrt, Ln;

   VAR 
      GasDevIset: INTEGER;
      GasDevGset: REAL;

   PROCEDURE ExpDev(VAR idum: INTEGER): REAL; 
      VAR dum: REAL; 
   BEGIN 
      REPEAT 
         dum := Ran3(idum); 
      UNTIL dum <> 0.0; 
	   (*
	     Guard against the (unlikely) event of a zero returned by Ran3.
	   *)
      RETURN -Ln(dum); 
   END ExpDev; 

   PROCEDURE GasDev(VAR idum: INTEGER): REAL; 
      VAR 
         fac, r, v1, v2, result: REAL; 
   BEGIN 
      IF GasDevIset = 0 THEN (* We don't have an extra deviate handy, so *)
         REPEAT 
            v1 := 2.0*Ran3(idum)-1.0; (* pick two uniform numbers in the
                                         square extending from -1 to +1 in each direction, *)
            v2 := 2.0*Ran3(idum)-1.0; 
            r := (v1*v1)+(v2*v2); (* see if they are in the unit circle, *)
         UNTIL (r < 1.0) AND (r > 0.0); (* and if they are not, try again. *)
         fac := Sqrt(-2.0*Ln(r)/r); (* Now make the Box-Muller transformation
                                       to get two normal deviates. Return one
                                       and save the other for next time. *)
         GasDevGset := v1*fac; 
         result := v2*fac; 
         GasDevIset := 1(* Set flag. *)
      ELSE (* We have an extra deviate handy, *)
         result := GasDevGset; 
         GasDevIset := 0; (* so unset the flag, *)
      END;
      RETURN result(* and return it. *)
   END GasDev; 

BEGIN
   GasDevIset := 0;(* Initialization. *)
END Transf.
