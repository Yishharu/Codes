IMPLEMENTATION MODULE Jacobis;

   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr,
                        NilVector;

   CONST
      Eps = 1.0E-9;

   PROCEDURE EqualZero(number: REAL): BOOLEAN;
   BEGIN
      IF (number >= -Eps) AND (number <= Eps) THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END;
   END EqualZero;

   PROCEDURE EigSrt(D: Vector;
                    V: Matrix);
      VAR
         k, j, i, n, nV, mV: INTEGER;
         p: REAL;
         d: PtrToReals;
         v: PtrToLines;
   BEGIN 
      GetVectorAttr(D, n, d);
      GetMatrixAttr(V, nV, mV, v);
      FOR i := 0 TO n-2 DO
         k := i;
         p := d^[i];
         FOR j := i+1 TO n-1 DO 
            IF d^[j] >= p THEN 
               k := j; 
               p := d^[j]
            END
         END; 
         IF k <> i THEN 
            d^[k] := d^[i];
            d^[i] := p;
            FOR j := 0 TO n-1 DO
               p := v^[j]^[i];
               v^[j]^[i] := v^[j]^[k];
               v^[j]^[k] := p
            END
         END
      END
   END EigSrt;

   PROCEDURE Jacobi(    A:    Matrix;
                        D:    Vector;
                        V:    Matrix;
                    VAR nrot: INTEGER);
      VAR
         j, iq, ip, i, n, mA, nD, nV, mV: INTEGER;
         tresh, theta, tau, t, sm, s, h, g, c: REAL;
         B, Z: Vector;
         b, z, d: PtrToReals;
         a, v: PtrToLines;
   BEGIN
      GetMatrixAttr(A, n, mA, a);
      GetVectorAttr(D, nD, d);
      GetMatrixAttr(V, nV, mV, v);
      CreateVector(n, B, b);
      CreateVector(n, Z, z);
      IF (B # NilVector) AND (Z # NilVector) THEN
	      FOR ip := 0 TO n-1 DO (* Initialize to the identity matrix. *)
	         FOR iq := 0 TO n-1 DO
	            v^[ip]^[iq] := 0.0
	         END;
	         v^[ip]^[ip] := 1.0
	      END;
	      FOR ip := 0 TO n-1 DO (* Initialize B and D to
                                the diagonal of A. *)
	         b^[ip] := a^[ip]^[ip];
	         d^[ip] := b^[ip];
	         z^[ip] := 0.0 (* This vector will accumulate terms
                             of the form tapq as in equation (11.1.14). *)
	      END; 
	      nrot := 0;
	      FOR i := 1 TO 50 DO 
	         sm := 0.0; (* Sum off-diagonal elements. *)
	         FOR ip := 0 TO n-2 DO 
	            FOR iq := ip+1 TO n-1 DO 
	               sm := sm+ABS(a^[ip]^[iq])(* The normal return, which relies on
	                                           quadratic convergence to machine
	                                           underflow. *)
	            END
	         END;
	         IF EqualZero(sm) THEN
	            IF (Z # NilVector) THEN DisposeVector(Z); END;
	            IF (B # NilVector) THEN DisposeVector(B); END;
	            RETURN;
	         END;
	         IF i < 4 THEN (* ...on the first three sweeps. *)
	            tresh := 0.2*sm/Float(n*n)
	         ELSE
	            tresh := 0.0(* ...thereafter. *)
	         END;
	         FOR ip := 0 TO n-2 DO
	            FOR iq := ip+1 TO n-1 DO
	               g := 100.0*ABS(a^[ip]^[iq]);
					   (*
					     After four sweeps, skip the rotation if the off-diagonal
					     element is small.
					   *)
	               IF (i > 4) AND EqualZero(g) THEN
	                  a^[ip]^[iq] := 0.0
	               ELSIF ABS(a^[ip]^[iq]) > tresh THEN
	                  h := d^[iq]-d^[ip];
	                  IF EqualZero(g) THEN
	                     t := a^[ip]^[iq]/h(* t=1/(2heta) *)
	                  ELSE
			               theta := 0.5*h/a^[ip]^[iq]; (* Equation (11.1.10). *)
			               t := 1.0/(ABS(theta)+Sqrt(1.0+theta*theta)); 
			               IF theta < 0.0 THEN t := -t END
	                  END; 
	                  c := 1.0/Sqrt(Float(1)+t*t); 
	                  s := t*c; 
	                  tau := s/(1.0+c); 
	                  h := t*a^[ip]^[iq]; 
	                  z^[ip] := z^[ip]-h; 
	                  z^[iq] := z^[iq]+h; 
	                  d^[ip] := d^[ip]-h; 
	                  d^[iq] := d^[iq]+h; 
	                  a^[ip]^[iq] := 0.0; 
	                  FOR j := 0 TO ip-1 DO (* Case of rotations 1<= j < p. *)
			               g := a^[j]^[ip]; 
			               h := a^[j]^[iq]; 
			               a^[j]^[ip] := g-s*(h+g*tau); 
			               a^[j]^[iq] := h+s*(g-h*tau)
	                  END;
	                  FOR j := ip+1 TO iq-1 DO 
						   (*
						     Case of rotations p<j<q.
						   *)
			               g := a^[ip]^[j]; 
			               h := a^[j]^[iq]; 
			               a^[ip]^[j] := g-s*(h+g*tau); 
			               a^[j]^[iq] := h+s*(g-h*tau)
	                  END; 
	                  FOR j := iq+1 TO n-1 DO (* Case of rotations q<j<= n. *)
			               g := a^[ip]^[j]; 
			               h := a^[iq]^[j]; 
			               a^[ip]^[j] := g-s*(h+g*tau); 
			               a^[iq]^[j] := h+s*(g-h*tau)
	                  END; 
	                  FOR j := 0 TO n-1 DO 
			               g := v^[j]^[ip]; 
			               h := v^[j]^[iq]; 
			               v^[j]^[ip] := g-s*(h+g*tau); 
			               v^[j]^[iq] := h+s*(g-h*tau)
	                  END;
	                  INC(nrot)
	               END
	            END
	         END; 
	         FOR ip := 0 TO n-1 DO 
	            b^[ip] := b^[ip]+z^[ip]; 
	            d^[ip] := b^[ip]; (* Update D with the sum of tapq, *)
	            z^[ip] := 0.0
	         END
	      END; 
	      Error('Jacobi', '50 iterations should not happen.'); 
	   ELSE
	      Error('Jacobi', 'Not enough memory.'); 
	   END;
      IF (Z # NilVector) THEN DisposeVector(Z); END; 
      IF (B # NilVector) THEN DisposeVector(B); END; 
   END Jacobi; 

END Jacobis.
