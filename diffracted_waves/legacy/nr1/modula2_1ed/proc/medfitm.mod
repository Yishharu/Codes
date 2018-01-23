IMPLEMENTATION MODULE MedFitM;

   FROM SortM    IMPORT Sort;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE MedFit(    X, Y: Vector; 
                    VAR a, b, abdev: REAL); 
      VAR 
         j, ndata, ny: INTEGER; 
         sy, sxy, sxx, sx, sigb, f2, f1, f: REAL; 
         del, chisq, bb, b2, b1, abdevt: REAL; 
         x, y: PtrToReals;

	   PROCEDURE rofunc(b: REAL): REAL; 
	   (*
	     Evaluates the right-hand side of equation (14.6.16)
	     for a given value of b. Also sets the values of a and
	     abdevt=abdev*ndata.
	   *)
	      VAR 
	         d, sum: REAL; 
	         j, n1, nmh, nml: INTEGER; 
	         ARR: Vector; 
	         arr: PtrToReals; 
	   BEGIN 
	      CreateVector(ndata, ARR, arr);
	      n1 := ndata+1; 
	      nml := n1 DIV 2; 
	      nmh := n1-nml; 
	      FOR j := 0 TO ndata-1 DO 
	         arr^[j] := y^[j]-b*x^[j]
	      END; 
	      Sort(ARR); (* Find median by sorting. *)
	      a := 0.5*(arr^[nml-1]+arr^[nmh-1]); 
	      sum := 0.0; 
	      abdevt := 0.0; 
	      FOR j := 0 TO ndata-1 DO 
	         d := y^[j]-(b*x^[j]+a); 
	         abdevt := abdevt+ABS(d); 
	         IF d > 0.0 THEN 
	            sum := sum+x^[j] (* Right-hand side of equation 14.6.16. *)
	         ELSE 
	            sum := sum-x^[j]
	         END
	      END; 
	      RETURN sum; 
	   END rofunc; 

   BEGIN 
      GetVectorAttr(X, ndata, x);
      GetVectorAttr(Y, ny, y);
      sx := 0.0; 
      sy := 0.0; 
      sxy := 0.0; 
      sxx := 0.0; 
      FOR j := 0 TO ndata-1 DO (* As a first guess for a and b,
                                  we will find the least-squares fitting line. *)
         sx := sx+x^[j]; 
         sy := sy+y^[j]; 
         sxy := sxy+x^[j]*y^[j]; 
         sxx := sxx+x^[j]*x^[j];
      END; 
      del := Float(ndata)*sxx-sx*sx; 
      a := (sxx*sy-sx*sxy)/del; (* Least-squares solutions. *)
      bb := (Float(ndata)*sxy-sx*sy)/del; 
      chisq := 0.0; 
      FOR j := 0 TO ndata-1 DO 
         chisq := chisq+(y^[j]-(a+bb*x^[j]))*(y^[j]-(a+bb*x^[j]))
      END; 
      sigb := Sqrt(chisq/del); (* The standard deviation will give
                                  some idea of how big an iteration step to take. *)
      b1 := bb; 
      f1 := rofunc(b1); 
      IF f1 >= 0.0 THEN (* Guess bracket as 3-sigma away,
                           in the downhill direction known from f1. *)
         b2 := bb+ABS(3.0*sigb)
      ELSE 
         b2 := bb-ABS(3.0*sigb)
      END; 
      f2 := rofunc(b2); 
      WHILE f1*f2 > 0.0 DO (* Bracketing. *)
         bb := 2.0*b2-b1; 
         b1 := b2; 
         f1 := f2; 
         b2 := bb; 
         f2 := rofunc(b2)
      END; 
	   (*
	     Refine until the error is a negligible number
	     of standard deviations.
	   *)
      sigb := 0.01*sigb; 
      WHILE ABS(b2-b1) > sigb DO 
	   (*
	     Bisection.
	   *)
         bb := 0.5*(b1+b2); 
         IF (bb = b1) OR (bb = b2) THEN 
		      b := bb; 
		      abdev := abdevt/Float(ndata);
            RETURN 
         END; 
         f := rofunc(bb); 
         IF f*f1 >= 0.0 THEN 
            f1 := f; 
            b1 := bb
         ELSE 
            f2 := f; 
            b2 := bb
         END
      END; 
      b := bb; 
      abdev := abdevt/Float(ndata)
   END MedFit; 

END MedFitM.
