IMPLEMENTATION MODULE GaussQdr;

   FROM NRMath   IMPORT RealFunction, Cos;
   FROM NRSystem IMPORT LongReal, D, S, Float, FloatSD;
   FROM NRIO     IMPORT Error;
   FROM NRLVect  IMPORT LVector, PtrToLongReals, GetLVectorAttr;

   PROCEDURE QGaus(    func: RealFunction;
                       a, b: REAL; 
                   VAR ss:   REAL); 
      VAR 
         j: INTEGER; 
         xr, xm, dx: REAL; 
         w, x: ARRAY [1..5] OF REAL; (* The abscissas and weights. *)
   BEGIN 
      x[1] := 0.1488743389; 
      x[2] := 0.4333953941; 
      x[3] := 0.6794095682; 
      x[4] := 0.8650633666; 
      x[5] := 0.9739065285; 
      w[1] := 0.2955242247; 
      w[2] := 0.2692667193; 
      w[3] := 0.2190863625; 
      w[4] := 0.1494513491; 
      w[5] := 0.0666713443; 
      xm := 0.5*(b+a); 
      xr := 0.5*(b-a); 
      ss := 0.0; (* Will be twice the average value of the function,
                    since the ten weights (five numbers above each used twice) sum to two. *)
      FOR j := 1 TO 5 DO 
         dx := xr*x[j]; 
         ss := ss+w[j]*(func(xm+dx)+func(xm-dx))
      END; 
      ss := xr*ss(* Scale the answer to the range of integration. *)
   END QGaus; 

   PROCEDURE GauLeg(x1, x2: LongReal; 
                    X, W:   LVector); 
      CONST 
         eps = 3.0E-11; (* Increase if you don't have this floating precision. *)
      VAR
         m, j, i, nw, n: INTEGER;
         z1, z, xm, xl, pp, p3, p2, p1: LongReal;
         x, w: PtrToLongReals;
		   (*
		     High precision is a good idea for this routine.
		   *)
   BEGIN
      GetLVectorAttr(X, n, x);
      GetLVectorAttr(W, nw, w);
      IF n = nw THEN
	      m := (n+1) DIV 2; (* The roots are symmetric in the interval,
                              so we only have to find half of them. *)
	      xm := 0.5*(x2+x1);
	      xl := 0.5*(x2-x1);
	      FOR i := 1 TO m DO (* Loop over the desired roots. *)
	         z := D(Cos(3.141592654*(Float(i)-0.25)/(Float(n)+0.5)));
			   (*
			     Starting with the above approximation to the ith root,
			     we enter the main loop of refinement by Newton's method.
			   *)
	         REPEAT
	            p1 := 1.0;
	            p2 := 0.0;
	            FOR j := 1 TO n DO (* Loop up the recurrence relation
                                   to get the Legendre polynomial evaluated at Z. *)
	               p3 := p2;
	               p2 := p1;
	               p1 := ((2.0*FloatSD(j)-1.0)*z*p2-(FloatSD(j)-1.0)*p3)/FloatSD(j)
	            END;
				   (*
				     p1 is now the desired Legendre polynomial.  We next compute
				     pp, its derivative, by a standard relation involving also p2,
				     the polynomial of one lower order.
				   *)
	            pp := FloatSD(n)*(z*p1-p2)/(z*z-1.0);
	            z1 := z; 
	            z := z1-p1/pp; (* Newton's method. *)
	         UNTIL ABS(S(z-z1)) <= eps; 
	         x^[i-1] := xm-xl*z; (* Scale the root to the desired interval, *)
	         x^[n-i] := xm+xl*z; (* and put in its symmetric counterpart. *)
	         w^[i-1] := 2.0*xl/(((1.0)-z*z)*pp*pp); (* Compute the weight *)
	         w^[n-i] := w^[i-1](* and its symmetric counterpart. *)
	      END;
	   ELSE
	      Error('GauLeg', 'Lengths of vectors are different.');
	   END;
   END GauLeg; 

END GaussQdr.
