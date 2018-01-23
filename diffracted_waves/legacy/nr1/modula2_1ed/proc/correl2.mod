IMPLEMENTATION MODULE Correl2;

   FROM IncBeta  IMPORT BetaI;
   FROM IncGamma IMPORT ErFCC;
   FROM SortM    IMPORT Sort2;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE Kendl1(    DATA1, DATA2: Vector; 
                    VAR tau, z, prob: REAL); 
      VAR 
         n, n2, n1, nData2, k, j, is: INTEGER; 
         svar, aa, a2, a1: REAL; 
         data1, data2: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, n, data1);
      GetVectorAttr(DATA2, nData2, data2);
      n1 := 0; (* This will be the argument of one square root in (13.8.8) *)
      n2 := 0; (* and this the other. *)
      is := 0; (* This will be the numerator in (13.8.8). *)
      FOR j := 1 TO n-1 DO (* Loop over first member of pair, *)
         FOR k := j+1 TO n DO (* and second member. *)
            a1 := data1^[j-1]-data1^[k-1]; 
            a2 := data2^[j-1]-data2^[k-1]; 
            aa := a1*a2; 
            IF aa <> 0.0 THEN (* Neither array has a tie. *)
               INC(n1, 1); 
               INC(n2, 1); 
               IF aa > 0.0 THEN INC(is) ELSE DEC(is) END
            ELSE (* One or both arrays have ties. *)
               IF a1 <> 0.0 THEN INC(n1, 1) END; (* An "extra x" event. *)
               IF a2 <> 0.0 THEN INC(n2, 1) END(* An "extra y" event. *)
            END
         END
      END; 
      tau := Float(is)/(Sqrt(Float(n1))*Sqrt(Float(n2))); (* Equation (13.8.8). *)
      svar := (4.0*Float(n)+10.0)/(9.0*Float(n)*(Float(n)-1.0)); (* Equation (13.8.9). *)
      z := tau/Sqrt(svar); 
      prob := ErFCC(ABS(z)/1.4142136) (* Significance. *)
   END Kendl1; 

   PROCEDURE Kendl2(    TAB: Matrix; 
                    VAR tau, z, prob: REAL); 
      VAR 
         nn, mm, m2, m1, lj, li, l, kj, ki, k, i, j: INTEGER; 
         svar, s, points, pairs, en2, en1: REAL; 
         tab: PtrToLines;
   BEGIN 
      GetMatrixAttr(TAB, i, j, tab);
      en1 := 0.0; (* See Kendl1 above. *)
      en2 := 0.0; 
      s := 0.0; 
      nn := i*j; (* Total number of entries in contingency table. *)
      points := tab^[i-1]^[j-1]; 
      FOR k := 0 TO nn-2 DO (* Loop over entries in table, *)
         ki := k DIV j; (* decoding a row *)
         kj := k-j*ki; (* and a column. *)
         points := points+tab^[ki]^[kj]; (* Increment the total count of events. *)
         FOR l := k+1 TO nn-1 DO (* Loop over other member of the pair, *)
            li := l DIV j; (* decoding its row *)
            lj := l-j*li; (* and column. *)
            m1 := li-ki; 
            m2 := lj-kj; 
            mm := m1*m2; 
            pairs := tab^[ki]^[kj]*tab^[li]^[lj]; 
            IF mm <> 0 THEN (* Not a tie. *)
               en1 := en1+pairs; 
               en2 := en2+pairs; 
               IF mm > 0 THEN s := s+pairs ELSE s := s-pairs END
                                                  (* Concordant or discordant. *)
            ELSE 
               IF m1 <> 0 THEN en1 := en1+pairs END; 
               IF m2 <> 0 THEN en2 := en2+pairs END
            END
         END
      END; 
      tau := s/Sqrt(en1*en2); 
      svar := (4.0*points+10.0)/(9.0*points*(points-1.0)); 
      z := tau/Sqrt(svar); 
      prob := ErFCC(ABS(z)/1.4142136)
   END Kendl2; 

   PROCEDURE CRank(    W: Vector; 
                   VAR s: REAL); 
   (*
     Given a sorted array W[0, n-1], replaces the
     elements by their rank, including midranking of ties, and returns
     as s the sum of f^3-f, where f is the number of elements
     in each tie.
   *)
      VAR 
         j, ji, jt, lbl1, lbl2, n: INTEGER; 
         t, rank: REAL; 
         w: PtrToReals;
   BEGIN 
      GetVectorAttr(W, n, w);
      s := 0.0; 
      j := 1; (* The next rank to be assigned. *)
      WHILE j < n DO 
         IF w^[j] <> w^[j-1] THEN (* Not a tie. *)
            w^[j-1] := Float(j); 
            INC(j)
         ELSE (* a tie.  How far does it go? *)
            LOOP
	            FOR jt := j+1 TO n DO 
	               IF w^[jt-1] <> w^[j-1] THEN EXIT END
	            END; 
	            jt := n+1; (* If here, it goes to the last element. *)
	            EXIT;
	         END;
            rank := 0.5*Float(j+jt-1); (* This is the mean rank of the tie. *)
            FOR ji := j TO jt-1 DO (* Enter it into all the tied entries, *)
               w^[ji-1] := rank
            END; 
            t := Float(jt-j); 
            s := s+t*t*t-t; (* and update s. *)
            j := jt
         END
      END; 
      IF j = n THEN w^[n-1] := Float(n); END(* If the last element was not tied,
                                               this is its rank. *)
   END CRank; 

   PROCEDURE Spear(    DATA1, DATA2: Vector; 
                   VAR d, zd, probd, rs, probrs: REAL); 
      VAR 
         j, n, n2: INTEGER; 
         vard, t, sg, sf, fac, en3n, en, df, aved: REAL; 
         WKSP1, WKSP2: Vector; 
         wksp1, wksp2, data1, data2: PtrToReals; 
   BEGIN 
      GetVectorAttr(DATA1, n, data1);
      GetVectorAttr(DATA2, n2, data2);
      CreateVector(n, WKSP1, wksp1);
      CreateVector(n, WKSP2, wksp2);
      IF (WKSP1 # NilVector) AND (WKSP2 # NilVector) THEN
	      FOR j := 0 TO n-1 DO 
	         wksp1^[j] := data1^[j]; 
	         wksp2^[j] := data2^[j]
	      END; 
	      Sort2(WKSP1, WKSP2); (* Sort each of the data arrays,
                               and convert the entries to ranks.  
                               The values sf and sg return
                               the sums (sum (fk^3-fk)) and (sum (gm^3-gm))
                               respectively. *)
	      CRank(WKSP1, sf); 
	      Sort2(WKSP2, WKSP1); 
	      CRank(WKSP2, sg); 
	      d := 0.0; 
	      FOR j := 0 TO n-1 DO (* Sum the squared difference of ranks. *)
	         d := d+(wksp1^[j]-wksp2^[j])*(wksp1^[j]-wksp2^[j])
	      END; 
	      en := Float(n); 
	      en3n := en*en*en-en; 
	      aved := en3n/6.0-(sf+sg)/12.0; (* Expectation value of d, *)
	      fac := (1.0-sf/en3n)*(1.0-sg/en3n); 
	      vard := ((en-1.0)*en*en*((en+1.0)*(en+1.0))/36.0)*fac;
	                                                  (* and variance of d give *)
	      zd := (d-aved)/Sqrt(vard); (* number of standard *)
	      probd := ErFCC(ABS(zd)/1.4142136); (* deviations and significance. *)
	      rs := (1.0-(6.0/en3n)*(d+(sf+sg)/12.0))/Sqrt(fac); (* Rank correlation coefficient, *)
	      fac := (1.0+rs)*(1.0-rs);
	      IF fac <> 0.0 THEN
	         t := rs*Sqrt((en-2.0)/fac); (* and its t value, *)
	         df := en-2.0;
	         probrs := BetaI(0.5*df, 0.5, df/(df+(t*t)))(* give its significance. *)
	      ELSE 
	         probrs := 0.0
	      END; 
	   ELSE
	      Error('Spear', 'Not enough memory.');
	   END;
      IF WKSP1 # NilVector THEN DisposeVector(WKSP1); END;
      IF WKSP2 # NilVector THEN DisposeVector(WKSP2); END;
   END Spear; 

END Correl2.
