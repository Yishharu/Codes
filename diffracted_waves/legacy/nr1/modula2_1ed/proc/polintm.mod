IMPLEMENTATION MODULE PolIntM;

   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        GetVectorAttr;

   PROCEDURE PolInt(    XA, YA: Vector; 
                        x:      REAL; 
                    VAR y, dy:  REAL); 
      VAR 
         ns, m, i, n, ny: INTEGER; 
         w, hp, ho, dift, dif, den: REAL; 
         C, D: Vector; 
         xa, ya, c, d: PtrToReals;
   BEGIN 
      GetVectorAttr(XA, n, xa);
      GetVectorAttr(YA, ny, ya);
      IF n = ny THEN
         CreateVector(n, C, c);
         CreateVector(n, D, d);
	      ns := 0; 
	      dif := ABS(x-xa^[0]); 
	      FOR i := 0 TO n-1 DO (* Here we find the index ns of the closest table
                               entry, *)
	         dift := ABS(x-xa^[i]); 
	         IF dift < dif THEN 
	            ns := i; 
	            dif := dift
	         END; 
	         c^[i] := ya^[i]; (* and initialize the tableau of C's and D's. *)
	         d^[i] := ya^[i]
	      END; 
	      y := ya^[ns]; (* This is the initial approximation to y. *)
	      DEC(ns); 
	      FOR m := 0 TO n-2 DO (* For each column of the tableau, *)
	         FOR i := 0 TO n-m-2 DO (* we loop over the current C's
                                    and D's and update them. *)
	            ho := xa^[i]-x; 
	            hp := xa^[i+m+1]-x; 
	            w := c^[i+1]-d^[i]; 
	            den := ho-hp; 
	            IF den = 0.0 THEN (* This error can occur only
                                  if two input XA's are (to within roundoff) identical. *)
	               Error('PolInt', ''); 
	            END; 
	            den := w/den; 
	            d^[i] := hp*den; (* Here the C's and D's are updated. *)
	            c^[i] := ho*den
	         END; 
	         IF 2*ns < n-m-2 THEN (* After each column in the tableau is
                                  completed, we decide which correction, C or D, we want to add
                                  to our accumulating value of y, i.e. which path to take through
                                  the tableau---forking up or down.  We do this in such a
                                  way as to take the most "straight line" route through the tableau
                                  to its apex, updating NS accordingly to keep track of where we
                                  are.  This route keeps the partial approximations centered (insofar
                                  as possible) on the target x.  The last dy added is thus
                                  the error indication. *)
	            dy := c^[ns+1]
	         ELSE 
	            dy := d^[ns]; 
	            DEC(ns)
	         END; 
	         y := y+dy
	      END; 
	      DisposeVector(D); 
	      DisposeVector(C)
	   ELSE
	      Error('PolInt', 'Length of input vectors are different.');
	   END;
   END PolInt; 

END PolIntM.
