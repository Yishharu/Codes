IMPLEMENTATION MODULE SpherHar;

   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;

   PROCEDURE PLgndr(l, m: INTEGER; x: REAL): REAL; 
      VAR 
         fact, pll, pmm, pmmp1, somx2, pLgndr: REAL; 
         i, ll: INTEGER; 
   BEGIN 
      IF (m < 0) OR (m > l) OR (ABS(x) > 1.0) THEN 
         Error('PLgndr', 'bad arguments'); 
      END; 
      pmm := 1.0; (* Compute Pm^m. *)
      IF m > 0 THEN 
         somx2 := Sqrt((1.0-x)*(1.0+x)); 
         fact := 1.0; 
         FOR i := 1 TO m DO 
            pmm := ((-pmm))*fact*somx2; 
            fact := fact+2.0
         END
      END; 
      IF l = m THEN 
         pLgndr := pmm
      ELSE (* Compute Pm+1^m. *)
         pmmp1 := x*Float((2*m+1))*pmm; 
         IF l = m+1 THEN 
            pLgndr := pmmp1
         ELSE (* Compute Pl^m, l>m+1. *)
            FOR ll := m+2 TO l DO 
               pll := (x*Float(2*ll-1)*pmmp1-Float(ll+m-1)*pmm)/Float(ll-m); 
               pmm := pmmp1; 
               pmmp1 := pll
            END; 
            pLgndr := pll
         END
      END; 
      RETURN pLgndr
   END PLgndr;


END SpherHar.
