IMPLEMENTATION MODULE ChebAppr;

   FROM NRMath   IMPORT RealFunction, Cos, CosSD;
   FROM NRSystem IMPORT LongReal, D, S, Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,
                        GetVectorAttr;

   PROCEDURE ChebFt(func: RealFunction;
                    a, b: REAL;
                    C:    Vector);
      CONST
         pi = 3.141592653589793;
      VAR
         k, j, n: INTEGER;
         y, bpa, bma: REAL;
         sum, fac: LongReal;
         F: Vector;
         c, f: PtrToReals;
   BEGIN
      GetVectorAttr(C, n, c);
      CreateVector(n, F, f);
      bma := 0.5*(b-a);
      bpa := 0.5*(b+a);
      FOR k := 0 TO n-1 DO (* We evaluate the function at the n points
                              required by (5.6.7). *)
         y := Cos(pi*(Float(k+1)-0.5)/Float(n));
         f^[k] := func(y*bma+bpa)
      END;
      fac := D(2.0/Float(n));
      FOR j := 0 TO n-1 DO (* We will accumulate the sum in double
                              precision, a nicety which you can ignore. *)
         sum := 0.0;
         FOR k := 0 TO n-1 DO
            sum := sum+D(f^[k])*CosSD(pi*Float(j)*(Float(k+1)-0.5)/Float(n))
         END;
         c^[j] := S(fac*sum)
      END; 
      DisposeVector(F)
   END ChebFt; 

   PROCEDURE ChebEv(a, b: REAL; 
                    C:   Vector; 
                    x:    REAL): REAL; 
      VAR 
         d, dd, sv, y, y2: REAL; 
         j, m: INTEGER; 
         c: PtrToReals;
   BEGIN 
      GetVectorAttr(C, m, c);
      IF (x-a)*(x-b) > 0.0 THEN 
         Error('ChebEv', 'x not in range.'); 
      ELSE 
	      d := 0.0; 
	      dd := 0.0; 
	      y := (2.0*x-a-b)/(b-a); (* Change of variable. *)
	      y2 := 2.0*y; 
	      FOR j := m-1 TO 1 BY -1 DO (* Clenshaw's recurrence. *)
	         sv := d; 
	         d := y2*d-dd+c^[j]; 
	         dd := sv
	      END; 
	      RETURN y*d-dd+0.5*c^[0]; (* Last step is different. *)
      END;
   END ChebEv; 

END ChebAppr.
