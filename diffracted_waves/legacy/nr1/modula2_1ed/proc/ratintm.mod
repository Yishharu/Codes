IMPLEMENTATION MODULE RatIntM;

   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        GetVectorAttr;

   PROCEDURE RatInt(    XA, YA: Vector; 
                        x:        REAL; 
                    VAR y, dy:    REAL); 
      CONST 
         tiny = 1.0E-25; (* a small number. *)
      VAR 
         ns, m, i, n, ny: INTEGER; 
         w, t, hh, h, dd: REAL; 
         cV, dV: Vector; 
         xa, ya, c, d: PtrToReals;
   BEGIN 
      GetVectorAttr(XA, n, xa);
      GetVectorAttr(YA, ny, ya);
      IF n = ny THEN
         CreateVector(n, cV, c);
         CreateVector(n, dV, d);
	      ns := 0; 
	      hh := ABS(x-xa^[0]); 
	      LOOP;
		      FOR i := 0 TO n-1 DO 
		         h := ABS(x-xa^[i]); 
		         IF h = 0.0 THEN 
		            y := ya^[i]; 
		            dy := 0.0; 
		            EXIT; 
		         ELSIF h < hh THEN 
		            ns := i; 
		            hh := h
		         END; 
		         c^[i] := ya^[i]; 
		         d^[i] := ya^[i]+tiny (* The tiny part is needed to
                                       prevent a rare zero-over-zero condition. *)
		      END; 
		      y := ya^[ns]; 
		      DEC(ns); 
		      FOR m := 0 TO n-2 DO 
		         FOR i := 0 TO n-m-2 DO 
		            w := c^[i+1]-d^[i]; 
		            h := xa^[i+m+1]-x; (* h will never be zero, since
                                        this was tested in the initializing loop. *)
		            t := (xa^[i]-x)*d^[i]/h; 
		            dd := t-c^[i+1]; 
		            IF dd = 0.0 THEN (* This error condition
                                      indicates that the interpolating function has a pole at the requested
                                      value of x. *)
		               Error('RATINT', ''); 
		            END; 
		            dd := w/dd; 
		            d^[i] := c^[i+1]*dd; 
		            c^[i] := t*dd
		         END; 
		         IF 2*ns < n-m-2 THEN 
		            dy := c^[ns+1]
		         ELSE 
		            dy := d^[ns]; 
		            DEC(ns)
		         END; 
		         y := y+dy
		      END; 
		      EXIT;
		   END;
	      DisposeVector(dV); 
	      DisposeVector(cV);
	   ELSE
	      Error('RatInt', 'Length of input vectors are different.');
	   END;
   END RatInt; 

END RatIntM.
