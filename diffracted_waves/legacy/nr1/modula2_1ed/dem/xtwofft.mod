MODULE XTwoFFT; (* driver for routine TwoFFT *) 

   FROM FFTs     IMPORT TwoFFT;
   FROM Four1M   IMPORT Four1;
   FROM NRMath   IMPORT Round, Sin, Cos;
   FROM NRSystem IMPORT Float;   
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                        GetVectorAttr, NilVector;

   CONST 
      n = 32; 
      n2 = 64; (* n2=2*n *) 
      per = 8; 
      pi = 3.1415926; 
   VAR 
      i, isign: INTEGER; 
      DATA1, DATA2, FFT1, FFT2: Vector;
      data1, data2, fft1, fft2: PtrToReals; 
      work: REAL;

   PROCEDURE PrntFT(DATA: Vector); 
      VAR 
         ii, mm, n, nn, nn2: INTEGER; 
         data: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA, nn2, data);
      nn := nn2 DIV 2;
      WriteString('   n'); 
      WriteString('      REAL(n)'); 
      WriteString('     imag.(n)'); 
      WriteString('   REAL(N-n)'); 
      WriteString('   imag.(N-n)'); 
      WriteLn; 
      WriteInt(0, 4); 
      WriteReal(data^[0], 14, 6); 
      WriteReal(data^[1], 12, 6); 
      WriteReal(data^[0], 12, 6); 
      WriteReal(data^[1], 12, 6); 
      WriteLn; 
      mm := nn DIV 2; 
      FOR ii := 0 TO mm-1 DO 
         n := 2*ii+2; 
         WriteInt((n) DIV 2, 4); 
         WriteReal(data^[n], 14, 6); 
         WriteReal(data^[n+1], 12, 6); 
         WriteReal(data^[2*nn-n], 12, 6); 
         WriteReal(data^[2*nn+1-n], 12, 6); 
         WriteLn
      END; 
      WriteString(' press RETURN to continue ...'); WriteLn; 
      ReadLn;
   END PrntFT; 
    
BEGIN 
   CreateVector(n, DATA1, data1);
   CreateVector(n, DATA2, data2);
   CreateVector(n2, FFT1, fft1);
   CreateVector(n2, FFT2, fft2);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) AND
      (FFT1 # NilVector) AND (FFT2 # NilVector) THEN
	   FOR i := 1 TO n DO 
	      work := 2.0*pi/Float(per);
	      data1^[i-1] := Float(Round(Cos(Float(i)*work))); 
	      data2^[i-1] := Float(Round(Sin(Float(i)*work))); 
	   END; 
	   TwoFFT(DATA1, DATA2, FFT1, FFT2, n); 
	   WriteString('fourier transform of first function:'); WriteLn; 
	   PrntFT(FFT1); 
	   WriteString('fourier transform of second function:'); WriteLn; 
	   PrntFT(FFT2); (* invert transform *) 
	   isign := -1; 
	   Four1(FFT1, n, isign); 
	   WriteString('inverted transform  =  first function:'); WriteLn; 
	   PrntFT(FFT1); 
	   Four1(FFT2, n, isign); 
	   WriteString('inverted transform  =  second function:'); WriteLn; 
	   PrntFT(FFT2);
	   ReadLn;
	ELSE
	   Error('XTwoFFT', 'Not enough memory.');
	END;
	IF (DATA1 # NilVector) THEN DisposeVector(DATA1) END;
	IF (DATA2 # NilVector) THEN DisposeVector(DATA2) END;
	IF (FFT1 # NilVector) THEN DisposeVector(FFT1) END;
	IF (FFT2 # NilVector) THEN DisposeVector(FFT2) END;
END XTwoFFT.
