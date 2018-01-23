IMPLEMENTATION MODULE ChDerInt;

   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, PtrToReals, GetVectorAttr;

   PROCEDURE ChInt(a, b:    REAL; 
                   C, CINT: Vector); 
      VAR 
         j, n, nInt: INTEGER; 
         sum, fac, con: REAL; 
         c, cInt: PtrToReals;
   BEGIN 
      GetVectorAttr(C, n, c);
      GetVectorAttr(CINT, nInt, cInt);
      IF (n = nInt) THEN
	      con := 0.25*(b-a); (* Factor which normalizes to the interval b-a. *)
	      sum := 0.0; (* Accumulates the constant of integration. *)
	      fac := 1.0; (* Will equal (+-)1. *)
	      FOR j := 1 TO n-2 DO 
	         cInt^[j] := con*(c^[j-1]-c^[j+1])/Float(j); (* Equation (5.7.1). *)
	         sum := sum+fac*cInt^[j]; 
	         fac := -fac
	      END; 
	      cInt^[n-1] := con*c^[n-2]/Float(n-2); 
	                              (* Special case of (5.7.1) for the last element. *)
	      sum := sum+fac*cInt^[n-1]; 
	      cInt^[0] := 2.0*sum(* Set the constant of integration. *)
	   ELSE
	      Error('ChInt', 'Length of input vectors are different.');
	   END;
   END ChInt; 

   PROCEDURE ChDer(a, b:      REAL; 
                   C, CDER: Vector); 
      VAR 
         j, n, nDer: INTEGER; 
         con: REAL; 
         c, cDer: PtrToReals;
   BEGIN 
      GetVectorAttr(C, n, c);
      GetVectorAttr(CDER, nDer, cDer);
      IF (n = nDer) THEN
	      cDer^[n-1] := 0.0; (* n-1 and n-2 are special cases. *)
	      cDer^[n-2] := 2.0*Float(n-1)*c^[n-1]; 
	      IF n >= 3 THEN (* Equation (5.7.2). *)
	         FOR j := n-3 TO 0 BY -1 DO 
	            cDer^[j] := cDer^[j+2]+2.0*Float(j+1)*c^[j+1]
	         END
	      END; 
	      con := 2.0/(b-a); 
	      FOR j := 0 TO n-1 DO 
	         cDer^[j] := cDer^[j]*con (* Normalize to the interval b-a. *)
	      END
	   ELSE
	      Error('ChDer', 'Length of input vectors are different');
	   END;
   END ChDer; 

END ChDerInt.
