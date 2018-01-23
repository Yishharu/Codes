IMPLEMENTATION MODULE Tests2;

   FROM IncGamma IMPORT GammQ;
   FROM SortM    IMPORT Sort;
   FROM NRMath   IMPORT RealFunction, Sqrt, Exp;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE ChSOne(    BINS, EBINS: Vector; 
                        knstrn: INTEGER; 
                    VAR df, chsq, prob: REAL); 
      VAR 
         j, nbins, nebins: INTEGER;
         bins, ebins: PtrToReals;
   BEGIN 
      GetVectorAttr(BINS, nbins, bins);
      GetVectorAttr(EBINS, nebins, ebins);
      df := Float(nbins-1-knstrn); 
      chsq := 0.0; 
      FOR j := 0 TO nbins-1 DO 
         IF ebins^[j] <= 0.0 THEN 
            Error('ChSOne', 'Bad expected number.'); 
         END; 
         chsq := chsq+((bins^[j]-ebins^[j])*(bins^[j]-ebins^[j]))/ebins^[j]
      END; 
      prob := GammQ(0.5*df, 0.5*chsq); 
	   (*
	     Chi-square probability function. See section6.2.
	   *)
   END ChSOne; 

   PROCEDURE ChSTwo(    BINS1, BINS2: Vector; 
                        knstrn: INTEGER; 
                    VAR df, chsq, prob: REAL); 
      VAR 
         j, nbins, nbins2: INTEGER; 
         bins1, bins2: PtrToReals;
   BEGIN 
      GetVectorAttr(BINS1, nbins, bins1);
      GetVectorAttr(BINS2, nbins2, bins2);
      df := Float(nbins-1-knstrn); (* No data means one less degree
                                      of freedom. *)
      chsq := 0.0; 
      FOR j := 0 TO nbins-1 DO 
         IF (bins1^[j] = 0.0) AND (bins2^[j] = 0.0) THEN 
            df := df-1.0
         ELSE 
            chsq := chsq+((bins1^[j]-bins2^[j])*(bins1^[j]-bins2^[j]))
                   /(bins1^[j]+bins2^[j])
         END
      END; 
      prob := GammQ(0.5*df, 0.5*chsq)
	   (*
	     Chi-square probability function. See section 6.2.
	   *)
   END ChSTwo; 

   PROCEDURE ProbKS(alam: REAL): REAL; 
      CONST 
         eps1 = 0.001; 
         eps2 = 1.0E-8; 
      VAR 
         a2, fac, sum, term, termbf: REAL; 
         j: INTEGER; 
   BEGIN 
      a2 := -2.0*alam*alam; 
      fac := 2.0; 
      sum := 0.0; 
      termbf := 0.0; 
	   (*
	     Previous term in sum.
	   *)
      FOR j := 1 TO 100 DO 
         term := fac*Exp(a2*Float(j*j)); 
         sum := sum+term; 
         IF (ABS(term) <= eps1*termbf) OR (ABS(term) <= eps2*sum) THEN 
            RETURN sum; 
         ELSE 
            fac := -fac; 
			   (*
			     Alternating signs in sum.
			   *)
            termbf := ABS(term)
         END
      END; 
	   (*
	     Get here only by failing to converge.
	   *)
      RETURN 1.0; 
   END ProbKS; 

   PROCEDURE KSOne(    DATA: Vector;
                       func: RealFunction;
                   VAR d, prob: REAL); 
      VAR 
         j, n: INTEGER; 
         fo, fn, ff, en, dt: REAL; 
         data: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA, n, data);
      Sort(DATA); (* If the data are already sorted
                     into ascending order, then this call can be omitted. *)
      en := Float(n); 
      d := 0.0; 
      fo := 0.0; (* Data's c.d.f. before the next step. *)
      FOR j := 1 TO n DO 
	   (*
	     Loop over the sorted data points.
	   *)
         fn := Float(j)/en; (* Data's c.d.f. after this step. *)
         ff := func(data^[j-1]); 
		   (*
		     Compare to the user-supplied function.
		   *)
         IF ABS(fo-ff) > ABS(fn-ff) THEN (* Maximum distance. *)
            dt := ABS(fo-ff)
         ELSE 
            dt := ABS(fn-ff)
         END; 
         IF dt > d THEN 
            d := dt
         END; 
         fo := fn
      END; 
      prob := ProbKS(Sqrt(en)*d)(* Compute significance. *)
   END KSOne; 

   PROCEDURE KSTwo(    DATA1, DATA2: Vector; 
                   VAR d, prob: REAL); 
      VAR 
         i, j1, j2, n1, n2: INTEGER; 
         en1, en2, fn1, fn2, dt, d1, d2: REAL; 
         data1, data2: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, n1, data1);
      GetVectorAttr(DATA2, n2, data2);
      Sort(DATA1); 
      Sort(DATA2); 
      en1 := Float(n1); 
      en2 := Float(n2); 
      j1 := 1; (* Next value of DATA1 to be processed. *)
      j2 := 1; (* Ditto, DATA2. *)
      fn1 := 0.0; (* Value of c.d.f. before the next step. *)
      fn2 := 0.0; (* Ditto, for DATA2. *)
      d := 0.0; 
      WHILE (j1 <= n1) AND (j2 <= n2) DO (* If we are not done... *)
         d1 := data1^[j1-1]; 
         d2 := data2^[j2-1]; 
         IF d1 <= d2 THEN (* Next step is in DATA1. *)
            fn1 := Float(j1)/en1; 
            INC(j1, 1)
         END; 
         IF d2 <= d1 THEN (* Next step is in DATA2. *)
            fn2 := Float(j2)/en2; 
            INC(j2, 1)
         END; 
         dt := ABS(fn2-fn1); 
         IF dt > d THEN d := dt END
      END; 
      prob := ProbKS(Sqrt(en1*en2/(en1+en2))*d)(* Compute significance. *)
   END KSTwo; 

END Tests2.
