IMPLEMENTATION MODULE Splines;

   FROM NRIO   IMPORT Error;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr;

   PROCEDURE Spline(X, Y:     Vector; 
                    yp1, ypn: REAL; 
                    Y2:       Vector); 
      VAR 
         i, k, n, ny, ny2: INTEGER; 
         p, qn, sig, un: REAL; 
         U: Vector;
         u, x, y, y2: PtrToReals; 
   BEGIN 
      GetVectorAttr(X, n, x);
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(Y2, ny2, y2);
      IF (n = ny) AND (ny = ny2) THEN
	      CreateVector(n, U, u);
	      IF yp1 > 0.99E30 THEN (* The lower boundary condition
                                  is set either to be ``natural" *)
	         y2^[0] := 0.0; 
	         u^[0] := 0.0
	      ELSE (* or else to have a specified first derivative. *)
	         y2^[0] := -0.5; 
	         u^[0] := (3.0/(x^[1]-x^[0]))*((y^[1]-y^[0])/(x^[1]-x^[0])-yp1)
	      END; 
	      FOR i := 1 TO n-2 DO (* This is the decomposition loop of the
                                 tridiagonal algorithm. y2 and U are used for temporary
                                 storage of the decomposed factors. *)
	         sig := (x^[i]-x^[i-1])/(x^[i+1]-x^[i-1]); 
	         p := sig*y2^[i-1]+2.0; 
	         y2^[i] := (sig-1.0)/p; 
	         u^[i] := (y^[i+1]-y^[i])/(x^[i+1]-x^[i])-(y^[i]-y^[i-1])/(x^[i]-x^[i-1]); 
	         u^[i] := (6.0*u^[i]/(x^[i+1]-x^[i-1])-sig*u^[i-1])/p
	      END; 
	      IF ypn > 0.99E30 THEN (* The upper boundary condition is
                                  set either to be "natural" *)
	         qn := 0.0; 
	         un := 0.0
	      ELSE (* or else to have a specified first derivative. *)
	         qn := 0.5; 
	         un := (3.0/(x^[n-1]-x^[n-2]))*(ypn-(y^[n-1]-y^[n-2])/(x^[n-1]-x^[n-2]))
	      END; 
	      y2^[n-1] := (un-qn*u^[n-2])/(qn*y2^[n-2]+1.0); 
	      FOR k := n-2 TO 0 BY -1 DO (* This is the backsubstitution loop of the
                                       tridiagonal algorithm. *)
	         y2^[k] := y2^[k]*y2^[k+1]+u^[k]
	      END; 
	      DisposeVector(U)
	   ELSE
	      Error('Spline', 'Length of input vectors are different.');
	   END;
   END Spline; 

   PROCEDURE Splint(    XA, YA, Y2A: Vector; 
                        x:           REAL; 
                    VAR y:           REAL); 
      VAR 
         klo, khi, k, n, nya, ny2a: INTEGER; 
         h, b, a: REAL; 
         xa, ya, y2a: PtrToReals;
   BEGIN 
      GetVectorAttr(XA, n, xa);
      GetVectorAttr(YA, nya, ya);
      GetVectorAttr(Y2A, ny2a, y2a);
      IF (n = nya) AND (nya = ny2a) THEN
	   (*
	     We will find the right place in the table by means
	     of bisection.  This is optimal if sequential calls to this routine are at
	     random values of x.  If sequential calls are in order, and closely
	     spaced, one would do better to store previous values of klo and khi
	     and test if they remain appropriate on the next call.
	   *)
	      klo := 0; 
	      khi := n-1; 
	      WHILE (khi-klo > 1) DO 
	         k := (khi+klo) DIV 2; 
	         IF xa^[k] > x THEN 
	            khi := k
	         ELSE 
	            klo := k
	         END
	      END; 
		   (*
		     klo and khi now bracket the input value of x.
		   *)
	      h := xa^[khi]-xa^[klo]; 
	      IF h = 0.0 THEN (* The XA's must be distinct. *)
	         Error('Splint', 'Bad xa input'); 
	      END; 
	      a := (xa^[khi]-x)/h; 
		   (*
		     Cubic spline polynomial is now evaluated.
		   *)
	      b := (x-xa^[klo])/h; 
	      y := a*ya^[klo]+b*ya^[khi]+((a*a*a-a)*y2a^[klo]+(b*b*b-b)*y2a^[khi])*(h*h)/6.0
	   ELSE
	      Error('Splint', 'Length of input vectors are different.');
	   END;
   END Splint; 

END Splines.
