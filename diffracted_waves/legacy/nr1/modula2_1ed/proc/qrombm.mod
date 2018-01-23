IMPLEMENTATION MODULE QRombM;

   FROM PolIntM IMPORT PolInt;
   FROM IntElem IMPORT Trapzd;
   FROM NRMath  IMPORT RealFunction;
   FROM NRIO    IMPORT Error;
   FROM NRVect  IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr;

   PROCEDURE QRomb(    func: RealFunction;
                       a, b: REAL; 
                   VAR ss:   REAL); 
      CONST 
         eps = 1.0E-6; (* Here eps is the fractional accuracy desired, as determined
                          by the extrapolation error estimate; jMax limits the
                          total number of steps; k is the number
                          of points used in the extrapolation. *)
         jMax = 20; 
         k = 5; 
      VAR 
         i, j: INTEGER; 
         dss: REAL; 
         H, S, (* These store the successive
                  trapezoidal approximations and their relative step-sizes. *)
         C, D: Vector; 
         h, s, c, d: PtrToReals; 
   BEGIN 
      CreateVector(jMax, H, h); 
      CreateVector(jMax, S, s);
      CreateVector(k, C, c);
      CreateVector(k, D, d);
      h^[0] := 1.0; 
      FOR j := 0 TO jMax-1 DO 
         Trapzd(func, a, b, s^[j], j); 
         IF j >= k THEN 
            FOR i := 0 TO k-1 DO 
               c^[i] := h^[j-k+i]; 
               d^[i] := s^[j-k+i]
            END; 
            PolInt(C, D, 0.0, ss, dss); 
            IF ABS(dss) < eps*ABS(ss) THEN 
               DisposeVector(D); 
               DisposeVector(C); 
               DisposeVector(S); 
               DisposeVector(H);
               RETURN;
            END
         END; 
         s^[j+1] := s^[j]; 
         h^[j+1] := 0.25*h^[j]
		   (*
		     This is a key step: The factor is 0.25 even though the step-size 
		     s decreased by only 0.5. This makes the extrapolation a polynomial 
		     in h^2 as allowed by equation (4.2.1), not just a polynomial in h.
		   *)
      END; 
      DisposeVector(D); 
      DisposeVector(C); 
      DisposeVector(S); 
      DisposeVector(H);
      Error('QRomb', 'Too many steps.'); 
   END QRomb; 

END QRombM.
