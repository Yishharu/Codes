IMPLEMENTATION MODULE CorrelM;

   FROM FFTs     IMPORT RealFT, TwoFFT;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                 NilVector;

   PROCEDURE Correl(DATA1, DATA2: Vector; 
                    n: INTEGER; 
                    ANS: Vector); 
      VAR 
         no2, i, ii, n2, nDATA1, nDATA2: INTEGER; 
         dum: REAL; 
         FFT: Vector;
         data1, data2, ans, fft: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, nDATA1, data1);
      GetVectorAttr(DATA2, nDATA2, data2);
      GetVectorAttr(ANS, n2, ans);
      CreateVector(n2, FFT, fft);
      IF FFT # NilVector THEN 
	      TwoFFT(DATA1, DATA2, FFT, ANS, n); 
		   (*
		     Transform both DATA vectors at once.
		   *)
	      no2 := n DIV 2; (* Normalization for inverse FFT. *)
	      FOR i := 1 TO no2+1 DO 
	         ii := 2*i; 
	         dum := ans^[ii-2]; (* Multiply to find FFT of their correlation. *)
	         ans^[ii-2] := (fft^[ii-2]*ans^[ii-2]+fft^[ii-1]*ans^[ii-1])/Float(no2); 
	         ans^[ii-1] := (fft^[ii-1]*dum-fft^[ii-2]*ans^[ii-1])/Float(no2);
	      END; 
	      ans^[1] := ans^[n]; (* Pack first and last into one element. *)
	      RealFT(ANS, no2, -1); (* Inverse transform gives correlation. *)
         DisposeVector(FFT)
	   ELSE
	      Error('Correl', 'Not enough memory.');
	   END;
   END Correl; 
END CorrelM.
