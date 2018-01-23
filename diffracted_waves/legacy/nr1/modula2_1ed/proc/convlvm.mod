IMPLEMENTATION MODULE ConvlvM;

   FROM FFTs     IMPORT RealFT, TwoFFT;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE Convlv(DATA:   Vector; 
                    RESPNS: Vector; 
                    m, 
                    isign:  INTEGER; 
                    ANS:    Vector); 
      VAR 
         no2, i, ii, n, nRespns, nAns: INTEGER; 
         dum, mag2: REAL; 
         FFT: Vector; 
         data, respns, ans, fft: PtrToReals;
   (*
     The data dimensions in FOUR1 and TWOFFT,
     which are called by  Convlv, must be the 2*n:
   *)
   BEGIN 
      GetVectorAttr(DATA, n, data);
      GetVectorAttr(RESPNS, nRespns, respns);
      GetVectorAttr(ANS, nAns, ans);
      CreateVector(2*n, FFT, fft); 
      IF FFT # NilVector THEN
	      FOR i := 1 TO (m-1) DIV 2 DO (* Put RESPNS in array of length n. *)
	         respns^[n-i] := respns^[m-i]
	      END; 
	      FOR i := (m+3) DIV 2 TO n-((m-1) DIV 2) DO (* Pad with zeros. *)
	         respns^[i-1] := 0.0
	      END; 
	      TwoFFT(DATA, RESPNS, FFT, ANS, n); (* FFT both at once. *)
	      no2 := n DIV 2; 
	      FOR i := 1 TO no2+1 DO 
	         ii := 2*i; 
	         IF isign = 1 THEN 
	            dum := ans^[ii-2]; (* Multiply FFTs to convolve. *)
	            ans^[ii-2] := (fft^[ii-2]*ans^[ii-2]-fft^[ii-1]*ans^[ii-1])/Float(no2); 
	            ans^[ii-1] := (fft^[ii-1]*dum+fft^[ii-2]*ans^[ii-1])/Float(no2);
	         ELSIF isign = -1 THEN 
	            IF ans^[ii-2]*ans^[ii-2]+ans^[ii-1]*ans^[ii-1] = 0.0 THEN 
	               Error('pause in routine Convlv', 'Deconvolving at response zero.'); 
	            END; 
	            dum := ans^[ii-2]; (* Divide FFTs to deconvolve. *)
	            mag2 := ans^[ii-2]*ans^[ii-2]+ans^[ii-1]*ans^[ii-1]; 
	            ans^[ii-2] := (fft^[ii-2]*ans^[ii-2]+fft^[ii-1]*ans^[ii-1])/(mag2*Float(no2)); 
	            ans^[ii-1] := (fft^[ii-1]*dum-fft^[ii-2]*ans^[ii-1])/(mag2*Float(no2))
	         ELSE 
	            Error('pause in routine Convlv', 'No meaning for isign'); 
	         END
	      END; 
	      ans^[1] := ans^[n]; (* Pack last element with first for RealFT. *)
	      RealFT(ANS, no2, -1); (* Inverse transform back to time domain. *)
	      DisposeVector(FFT);
	   ELSE
	      Error('Convlv', 'Not enough memory.');
    END;
   END Convlv; 

END ConvlvM.
