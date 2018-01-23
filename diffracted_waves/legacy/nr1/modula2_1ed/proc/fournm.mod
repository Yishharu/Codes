IMPLEMENTATION MODULE FourNM;

   FROM NRMath   IMPORT Sin, SinDD;
   FROM NRSystem IMPORT LongReal, D, S, Float;
   FROM NRIO     IMPORT Error;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, GetIVectorAttr,
                        NilIVector, IVectorPtr;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE FourN(DATA:  Vector; 
                   NN:    IVector; 
                   isign: INTEGER); 
      VAR 
         i1, i2, i3, i2rev, i3rev, ibit, idim: INTEGER; 
         ip1, ip2, ip3, ifp1, ifp2, k1, k2, n: INTEGER; 
         ii1, ii2, ii3: INTEGER; 
         nprev, nrem, ntot, ndat2, ndim: INTEGER; 
         tempi, tempr, wrs, wis: REAL; 
         theta, wi, wpi, wpr, wr, wtemp: LongReal; 
                             (* Double precision for trigonometric recurrences. *)
         data: PtrToReals;
         nn: PtrToIntegers;
   BEGIN
      GetVectorAttr(DATA, ndat2, data);
      GetIVectorAttr(NN, ndim, nn);
      ntot := 1; (* Compute total number of complex values. *)
      FOR idim := 1 TO ndim DO (* Main loop over the dimensions. *)
         ntot := ntot*nn^[idim-1]
      END; 
      nprev := 1; 
      FOR idim := ndim TO 1 BY -1 DO 
         n := nn^[idim-1]; 
         nrem := ntot DIV (n*nprev); 
         ip1 := 2*nprev; 
         ip2 := ip1*n; 
         ip3 := ip2*nrem; 
         i2rev := 1; 
		   (*
		     This is the bit reversal section
		     of the routine.
		   *)
         FOR ii2 := 0 TO (ip2-1) DIV ip1 DO 
            i2 := 1+ii2*ip1; 
            IF i2 < i2rev THEN
               FOR ii1 := 0 TO (ip1-2) DIV 2 DO 
                  i1 := i2+ii1*2; 
                  FOR ii3 := 0 TO (ip3-i1) DIV ip2 DO 
              i3 := i1+ii3*ip2; 
              i3rev := i2rev+i3-i2; 
              tempr := data^[i3-1]; 
              tempi := data^[i3]; 
              data^[i3-1] := data^[i3rev-1]; 
              data^[i3] := data^[i3rev]; 
              data^[i3rev-1] := tempr; 
              data^[i3rev] := tempi
                  END
               END
            END; 
            ibit := ip2 DIV 2; 
            WHILE (ibit >= ip1) AND (i2rev > ibit) DO 
               DEC(i2rev, ibit); 
               ibit := ibit DIV 2
            END; 
            INC(i2rev, ibit)
         END;
		   (*
		     Here begins the Danielson-Lanczos section
		     of the routine.
		   *)
         ifp1 := ip1; 
         WHILE ifp1 < ip2 DO 
            ifp2 := 2*ifp1; (* Initialize for the trig.recurrence. *)
            theta := D(Float(isign)*6.28318530717959/Float((ifp2 DIV ip1)));
            wpr := D(-2.0)*SinDD(D(0.5)*theta)*SinDD(D(0.5)*theta);
            wpi := SinDD(theta);
            wr := 1.0;
            wi := 0.0;
            FOR ii3 := 0 TO (ifp1-1) DIV ip1 DO
               i3 := 1+ii3*ip1;
               wrs := S(wr);
               wis := S(wi);
               FOR ii1 := 0 TO (ip1-2) DIV 2 DO
                  i1 := i3+ii1*2;
                  FOR ii2 := 0 TO (ip3-i1) DIV ifp2 DO
		               i2 := i1+ii2*ifp2;
		               k1 := i2; (* Danielson-Lanczos formula: *)
		               k2 := k1+ifp1; 
		               tempr := wrs*data^[k2-1]-wis*data^[k2]; 
		               tempi := wrs*data^[k2]+wis*data^[k2-1]; 
		               data^[k2-1] := data^[k1-1]-tempr; 
		               data^[k2] := data^[k1]-tempi; 
		               data^[k1-1] := data^[k1-1]+tempr; 
		               data^[k1] := data^[k1]+tempi
                  END
               END; 
               wtemp := wr; (* Trigonometric recurrence. *)
               wr := wr*wpr-wi*wpi+wr; 
               wi := wi*wpr+wtemp*wpi+wi
            END; 
            ifp1 := ifp2
         END; 
         nprev := n*nprev
      END
   END FourN; 
END FourNM.
