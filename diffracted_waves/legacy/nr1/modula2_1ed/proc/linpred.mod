IMPLEMENTATION MODULE LinPred;

   FROM LaguQ    IMPORT Zroots;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRComp   IMPORT CVector, CreateCVector, DisposeCVector, NilCVector, 
                        PtrToComplexes;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE FixRts(DD: Vector); 
      VAR 
         j, i, npoles: INTEGER; 
         size, dum: REAL; 
         polish: BOOLEAN; 
         d: PtrToReals;
         A, ROOTS: CVector;
         a, roots: PtrToComplexes; 
   BEGIN 
      GetVectorAttr(DD, npoles, d);
      CreateCVector(npoles+1, A, a);
      CreateCVector(npoles+1, ROOTS, roots);
      IF (A # NilCVector) AND (ROOTS # NilCVector) THEN
	      a^[npoles].r := 1.0; 
	      a^[npoles].i := 0.0; 
	      FOR j := npoles TO 1 BY -1 DO (* Set up complex coefficients for
                                          polynomial root finder. *)
	         a^[j-1].r := -d^[npoles-j]; 
	         a^[j-1].i := 0.0
	      END; 
	      polish := TRUE; 
	      Zroots(A, npoles, ROOTS, polish); 
		   (*
		     Find all the roots.
		   *)
	      FOR j := 1 TO npoles DO (* Look for a... *)
	         size := roots^[j-1].r*roots^[j-1].r+roots^[j-1].i*roots^[j-1].i; 
	         IF size > 1.0 THEN (* ...root outside the unit circle, *)
	            roots^[j-1].r := roots^[j-1].r/size; (* and reflect it back inside. *)
	            roots^[j-1].i := roots^[j-1].i/size
	         END
	      END; 
	      a^[0].r := -roots^[0].r; (* Now reconstruct the polynomial coefficients, *)
	      a^[0].i := -roots^[1].i; 
	      a^[1].r := 1.0; 
	      a^[1].i := 0.0; 
	      FOR j := 2 TO npoles DO (* by looping over the roots *)
	         a^[j].r := 1.0; 
	         a^[j].i := 0.0; 
	         FOR i := j TO 2 BY -1 DO 
			   (*
			     and synthetically multiplying.
			   *)
	            dum := a^[i-1].r; 
	            a^[i-1].r := a^[i-2].r-a^[i-1].r*roots^[j-1].r+a^[i-1].i*roots^[j-1].i; 
	            a^[i-1].i := a^[i-2].i-dum*roots^[j-1].i-a^[i-1].i*roots^[j-1].r
	         END; 
	         dum := a^[0].r; 
	         a^[0].r := -a^[0].r*roots^[j-1].r+a^[0].i*roots^[j-1].i; 
	         a^[0].i := -dum*roots^[j-1].i-a^[0].i*roots^[j-1].r
	      END; 
	      FOR j := 1 TO npoles DO 
	         d^[npoles-j] := -a^[j-1].r
	      END;
		   (*
		     The polynomial coefficients are guaranteed to be real,
		     so we need only return the real part as new LP coefficients.
		   *)
	   ELSE
	      Error('FixRts', 'Not enough memory.');
	   END;
	   IF A # NilCVector THEN DisposeCVector(A) END;
	   IF ROOTS # NilCVector THEN DisposeCVector(ROOTS) END;
   END FixRts; 

   PROCEDURE Predic(DATA, DD, FUTURE: Vector); 
      VAR 
         k, j, ndata, npoles, nfut: INTEGER; 
         sum, discrp: REAL; 
         REG: Vector; 
         data, d, future, reg: PtrToReals;

   BEGIN 
      GetVectorAttr(DATA, ndata, data);
      GetVectorAttr(DD, npoles, d);
      GetVectorAttr(FUTURE, nfut, future);
      CreateVector(npoles, REG, reg);
      IF (REG # NilVector)  THEN
	      FOR j := 1 TO npoles DO 
	         reg^[j-1] := data^[ndata-j]
	      END; 
	      FOR j := 1 TO nfut DO 
	         discrp := 0.0; (* This is where you would put in a known discrepancy 
	                           if you were reconstructing a function by linear predictive
                              coding rather than extrapolating a function by linear prediction.  See
                              text below. *)
	         sum := discrp; 
	         FOR k := 1 TO npoles DO 
	            sum := sum+d^[k-1]*reg^[k-1]
	         END; 
	         FOR k := npoles TO 2 BY -1 DO (* [If you know how to implement
                                             circular arrays, you can avoid this 
                                             shifting of coefficients!] *)
	            reg^[k-1] := reg^[k-2]
	         END; 
	         reg^[0] := sum; 
	         future^[j-1] := sum
	      END; 
	      DisposeVector(REG);
	   ELSE
	      Error('Predic', 'Not enough memory.');
	   END;
   END Predic; 

END LinPred.
