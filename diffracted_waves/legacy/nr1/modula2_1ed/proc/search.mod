IMPLEMENTATION MODULE Search;

   FROM NRVect IMPORT Vector, PtrToReals, GetVectorAttr;

   PROCEDURE Hunt(    XX:  Vector; 
                      x:    REAL; 
                  VAR jlo:  INTEGER); 
      VAR 
         jm, jhi, inc, n: INTEGER; 
         ascnd: BOOLEAN; 
         xx: PtrToReals;
   BEGIN 
      GetVectorAttr(XX, n, xx);
      ascnd := xx^[n-1] > xx^[0]; (* True if ascending order of table,
                                     false otherwise. *)
      LOOP
	      IF (jlo < 0) OR (jlo > n-1) THEN (* Input guess not useful. Go
                                             immediately to bisection. *)
	         jlo := -1; 
	         jhi := n
	      ELSE 
	         inc := 1; (* Set the hunting increment. *)
	         IF (x >= xx^[jlo]) = ascnd THEN (* Hunt up: *)
	            IF jlo = n-1 THEN RETURN END; 
	            jhi := jlo+1; 
	            WHILE (x >= xx^[jhi]) = ascnd DO (* Not done hunting, *)
	               jlo := jhi; 
	               INC(inc, inc); (* so double the increment. *)
	               jhi := jlo+inc; (* Try again. *)
	               IF jhi > n-1 THEN (* Done hunting, since off end of table. *)
	                  jhi := n; 
	                  EXIT 
	               END
	            END(* Done hunting, value bracketed. *)
	         ELSE (* Hunt down: *)
	            IF jlo = 0 THEN 
	               jlo := -1; 
	               RETURN 
	            END; 
	            jhi := jlo; 
	            jlo := jhi-1; 
	            WHILE (x < xx^[jlo]) = ascnd DO (* Not done hunting, *)
	               jhi := jlo; 
	               INC(inc, inc); (* so double the increment. *)
	               jlo := jhi-inc; (* Try again. *)
	               IF jlo < 0 THEN (* Done hunting, since off end of table. *)
	                  jlo := -1; 
	                  EXIT 
	               END
	            END
	         END
	      END; (* Done hunting, value bracketed. *)
	      EXIT;
	   END;(* Hunt is done. Begin the final bisection phase: *)
      WHILE jhi-jlo <> 1 DO 
         jm := (jhi+jlo) DIV 2; 
         IF (x > xx^[jm]) = ascnd THEN 
            jlo := jm
         ELSE 
            jhi := jm
         END
      END; 
   END Hunt; 

   PROCEDURE Locate(    XX: Vector; 
                        x:   REAL; 
                    VAR j:   INTEGER); 
      VAR 
         ju, jm, jl, n: INTEGER; 
         ascnd: BOOLEAN; 
         xx: PtrToReals;
   BEGIN 
      GetVectorAttr(XX, n, xx);
      ascnd := xx^[n-1] > xx^[0]; 
      jl := -1; (* Initialize lower limit, *)
      ju := n; (* and upper limit. *)
      WHILE ju-jl > 1 DO (* If we are not yet done, *)
         jm := (ju+jl) DIV 2; (* compute a midpoint. *)
         IF (x > xx^[jm]) = ascnd THEN 
            jl := jm (* Replace the lower limit *)
         ELSE 
            ju := jm (* or upper limit, as appropriate. *)
         END(* Repeat until the test condition is satisfied. *)
      END; 
      j := jl (* Then set the output *)
   END Locate; (* and return. *)

END Search.
