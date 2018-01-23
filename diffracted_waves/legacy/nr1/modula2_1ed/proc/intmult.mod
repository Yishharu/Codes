IMPLEMENTATION MODULE IntMult;

   FROM NRMath IMPORT RealFunction,  RealFunction2D,   RealFunction3D;

   VAR Quad3dX, Quad3dY: REAL;

   PROCEDURE Quad3D(    x1, x2: REAL; 
                        func:   RealFunction3D;
                        y1, y2: RealFunction;
                        z1, z2: RealFunction2D;
                    VAR ss:     REAL); 

      PROCEDURE QGaus3(    a, b: REAL; 
                       VAR ss:   REAL; 
                           n:    INTEGER); 
         VAR 
            j: INTEGER; 
            xr, xm, dx: REAL; 
            w, x: ARRAY [1..5] OF REAL; 

         PROCEDURE f(x: REAL; 
                     n: INTEGER): REAL; 
            VAR 
               ss: REAL; 
         BEGIN 
            IF n = 1 THEN (* This is H of eq.(4.6.5). *)
               Quad3dX := x; 
               QGaus3(y1(Quad3dX), y2(Quad3dX), ss, 2); 
               RETURN ss
            ELSIF n = 2 THEN (* This is G of eq.(4.6.4). *)
               Quad3dY := x; 
               QGaus3(z1(Quad3dX, Quad3dY), z2(Quad3dX, Quad3dY), ss, 3); 
               RETURN ss
            ELSE 
               RETURN func(Quad3dX, Quad3dY, x) (* This is the integrand f(x,y,z) evaluated at fixed x and y. *)
            END; 
         END f; 
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
         ss := 0.0; 
         FOR j := 1 TO 5 DO 
            dx := xr*x[j]; 
            ss := ss+w[j]*(f(xm+dx, n)+f(xm-dx, n))
         END; 
         ss := xr*ss
      END QGaus3; 
   BEGIN (* Here is the main procedure. *)
      QGaus3(x1, x2, ss, 1)
   END Quad3D; 

END IntMult.
