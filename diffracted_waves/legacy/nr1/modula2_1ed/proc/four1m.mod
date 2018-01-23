IMPLEMENTATION MODULE Four1M;

   FROM NRMath   IMPORT Sin, SinDD;
   FROM NRSystem IMPORT LongReal, D, S, Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr,
                        NilVector;

   PROCEDURE Four1(DATA:  Vector;
                   nn, isign: INTEGER);
      VAR
         ii, jj, n, mmax, m, j, istep, i,length: INTEGER; 
         wtemp, wr, wpr, wpi, wi, theta: LongReal; (* Double precision
                                                      for the trigonometric recurrences. *)
         tempr, tempi, wrs, wis: REAL; 
         data:PtrToReals;
   BEGIN 
      GetVectorAttr(DATA, length, data);
      n := 2*nn; 
      j := 1; (* This is the bit-reversal section of the routine. *)
      FOR ii := 1 TO nn DO 
         i := 2*ii-1; 
         IF j > i THEN 
            tempr := data^[j-1]; (* Exchange the two complex numbers. *)
            tempi := data^[j]; 
            data^[j-1] := data^[i-1]; 
            data^[j] := data^[i]; 
            data^[i-1] := tempr; 
            data^[i] := tempi
         END; 
         m := n DIV 2; 
         WHILE (m >= 2) AND (j > m) DO
            DEC(j, m); 
            m := m DIV 2
         END; 
         INC(j, m)
      END; 
      mmax := 2; 
	   (*
	     Here begins the Danielson-Lanczos section of the
	     routine.
	   *)
      WHILE n > mmax DO (* Outer loop executed log2 nn times. *)
         istep := 2*mmax; 
         theta := D(6.28318530717959/Float(isign*mmax));
                               (* Initialize for the trigonometric recurrence. *)
         wpr := D(-2.0)*SinDD(D(0.5)*theta)*SinDD(D(0.5)*theta);
         wpi := SinDD(theta);
         wr := 1.0;
         wi := 0.0;
         FOR ii := 1 TO mmax DIV 2 DO (* Here are the two nested inner loops. *)
            m := 2*ii-1;
            wrs := S(wr);
            wis := S(wi);
            FOR jj := 0 TO (n-m) DIV istep DO (* This is the
                                                 Danielson-Lanczos formula: *)
               i := m+jj*istep;
               j := i+mmax;
               tempr := wrs*data^[j-1]-wis*data^[j];
               tempi := wrs*data^[j]+wis*data^[j-1];
               data^[j-1] := data^[i-1]-tempr;
               data^[j] := data^[i]-tempi;
               data^[i-1] := data^[i-1]+tempr;
               data^[i] := data^[i]+tempi
            END;
            wtemp := wr; (* Trigonometric recurrence. *)
            wr := wr*wpr-wi*wpi+wr;
            wi := wi*wpr+wtemp*wpi+wi
         END;
         mmax := istep
      END
   END Four1;

END Four1M.
