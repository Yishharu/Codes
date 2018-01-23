IMPLEMENTATION MODULE MaxEntr;

   FROM NRMath   IMPORT Sin, Cos, SinDD, CosDD;
   FROM NRSystem IMPORT LongReal, D, S, Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE EvlMEM(fdt: REAL; 
                    COF: Vector; 
                    pm:  REAL): REAL; 
      VAR 
         wr, wi, wpr, wpi, wtemp, theta: LongReal; 
         sumi, sumr, wrs, wis: REAL;
         i, m: INTEGER; 
         cof: PtrToReals;
   BEGIN 
      GetVectorAttr(COF, m, cof);
      theta := D(6.28318530717959*fdt);
      wpr := CosDD(theta); (* Set up for recurrence relations. *)
      wpi := SinDD(theta);
      wr := 1.0;
      wi := 0.0;
      sumr := 1.0; (* Used to accumulate the denominator of (12.8.4). *)
      sumi := 0.0;
      FOR i := 1 TO m DO (* Loop over the terms in the sum. *)
         wtemp := wr;
         wr := wr*wpr-wi*wpi;
         wi := wi*wpr+wtemp*wpi;
         wrs := S(wr);
         wis := S(wi);
         sumr := sumr-cof^[i-1]*wrs;
         sumi := sumi-cof^[i-1]*wis
      END;
      RETURN pm/((sumr*sumr)+(sumi*sumi));
	   (*
	     Equation (12.8.4).
	   *)
   END EvlMEM; 

   PROCEDURE MEMCof(    DATA: Vector; 
                    VAR pm:   REAL; 
                        COF:  Vector); 
      VAR 
         k, j, i, n, m: INTEGER; 
         num, p, denom: REAL;
         WK1, WK2, WKM: Vector;
         wk1, wk2, wkm, data, cof: PtrToReals; 
   BEGIN 
      GetVectorAttr(DATA, n, data);
      GetVectorAttr(COF, m, cof);
      CreateVector(n, WK1, wk1);
      CreateVector(n, WK2, wk2);
      CreateVector(m, WKM, wkm);
      IF (WK1 # NilVector) AND (WK2 # NilVector) AND (WKM # NilVector) THEN
         LOOP
		      p := 0.0; 
		      FOR j := 1 TO n DO 
		         p := p+data^[j-1]*data^[j-1]
		      END; 
		      pm := p/Float(n); 
		      wk1^[0] := data^[0]; 
		      wk2^[n-2] := data^[n-1]; 
		      FOR j := 2 TO n-1 DO 
		         wk1^[j-1] := data^[j-1]; 
		         wk2^[j-2] := data^[j-1]
		      END; 
		      FOR k := 1 TO m DO 
		         num := 0.0; 
		         denom := 0.0; 
		         FOR j := 1 TO n-k DO 
		            num := num+wk1^[j-1]*wk2^[j-1]; 
		            denom := denom+wk1^[j-1]*wk1^[j-1]+wk2^[j-1]*wk2^[j-1]
		         END; 
		         cof^[k-1] := 2.0*num/denom; 
		         pm := pm*(1.0-cof^[k-1]*cof^[k-1]); 
		         FOR i := 1 TO k-1 DO 
		            cof^[i-1] := wkm^[i-1]-cof^[k-1]*wkm^[k-i-1]
					   (*
					     The algorithm is recursive, building up the answer for larger
					     and larger values of m until the desired value is reached.
					     At this point in the algorithm, one could return the vector COF
					     and scalar pm for an MEM spectral estimate of K (rather than m)
					     terms.
					   *)
		         END; 
		         IF k = m THEN EXIT END; 
		         FOR i := 1 TO k DO 
		            wkm^[i-1] := cof^[i-1]
		         END; 
		         FOR j := 1 TO n-k-1 DO 
		            wk1^[j-1] := wk1^[j-1]-wkm^[k-1]*wk2^[j-1]; 
		            wk2^[j-1] := wk2^[j]-wkm^[k-1]*wk1^[j]
		         END
		      END; 
		      EXIT;
		   END;
	   ELSE
	      Error('MEMCof', 'Not enough memory.');
	   END;
      IF WKM # NilVector THEN DisposeVector(WKM); END;
      IF WK1 # NilVector THEN DisposeVector(WK1); END;
      IF WK2 # NilVector THEN DisposeVector(WK2); END;
   END MEMCof; 
END MaxEntr.
