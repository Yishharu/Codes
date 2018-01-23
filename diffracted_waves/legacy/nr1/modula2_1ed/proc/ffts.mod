IMPLEMENTATION MODULE FFTs;

   FROM Four1M   IMPORT Four1;
   FROM NRMath   IMPORT Sin, SinDD;
   FROM NRSystem IMPORT LongReal, D, S, Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr,
                        NilVector;

   PROCEDURE CosFT(Y:     Vector;
                   isign: INTEGER);
      VAR
         enf0, even, odd, sum, sume, sumo, y1, y2, wrs, wis: REAL;
         theta, wi, wr, wpi, wpr, wtemp: LongReal; (* Double precision for the
                                                      trigonometric recurrences. *)
         jj, j, m, n2, n: INTEGER;
         y: PtrToReals;
   BEGIN
      GetVectorAttr(Y, n, y);
      theta := D(3.14159265358979/Float(n));
	   (*
	     Initialize the recurrence.
	   *)
      wr := 1.0;
      wi := 0.0;
      wpr := D(-2.0)*(SinDD(D(0.5)*theta)*SinDD(D(0.5)*theta));
      wpi := SinDD(theta);
      sum := y^[0];
      m := n DIV 2;
      n2 := n+2;
      FOR j := 2 TO m DO (* J=m+1 is unnecessary since y[n/2+1]
                            is unchanged. *)
         wtemp := wr;
         wr := wr*wpr-wi*wpi+wr;
		   (*
		     Carry out the recurrence.
		   *)
         wi := wi*wpr+wtemp*wpi+wi;
         wrs := S(wr);
         wis := S(wi);
         y1 := 0.5*(y^[j-1]+y^[n2-j-1]);
		   (*
		     Calculates the auxiliary function.
		   *)
         y2 := y^[j-1]-y^[n2-j-1];
         y^[j-1] := y1-wis*y2; (* The values for j-1 and n-j-1 are
                                  related. *)
         y^[n2-j-1] := y1+wis*y2;
         sum := sum+wrs*y2(* Carry along this sum for later use
                             in unfolding the transform. *)
      END;
      RealFT(Y, m, 1); (* Calculate the transform of the
                          auxiliary function. *)
      y^[1] := sum; (* sum is the value in equation (12.3.19). *)
      FOR jj := 2 TO m DO
         j := 2*jj;
         sum := sum+y^[j-1]; (* Equation (12.3.18). *)
         y^[j-1] := sum
      END;
      IF isign = -1 THEN (* This code applies only to the inverse
                            transform. *)
         even := y^[0]; 
         odd := y^[1]; 
         FOR jj := 1 TO m-1 DO 
            j := 2*jj+1; 
            even := even+y^[j-1]; (* Sum up the even and odd
                                     transform values as in equation (12.3.22). *)
            odd := odd+y^[j]
         END; 
         enf0 := 2.0*(even-odd); 
         sumo := y^[0]-enf0; (* Next, implement equation (12.3.24). *)
         sume := (2.0*odd/Float(n))-sumo; 
         y^[0] := 0.5*enf0; 
         y^[1] := y^[1]-sume; 
         FOR jj := 1 TO m-1 DO 
            j := 2*jj+1; 
            y^[j-1] := y^[j-1]-sumo; (* Finally, equation (12.3.21) 
                                        gives the true inverse cosine transform (excepting the factor 2/n). *)
            y^[j] := y^[j]-sume
         END
      END;
   END CosFT; 

   PROCEDURE RealFT(DATA:  Vector; 
                       n:  INTEGER;
                    isign: INTEGER); 
      VAR 
         wr, wi, wpr, wpi, wtemp, theta: LongReal; (* Double precision for the trigonometric recurrences. *)
         i, i1, i2, i3, i4, np: INTEGER; 
         c1, c2, h1r, h1i, h2r, h2i, wrs, wis: REAL; 
         data: PtrToReals;
   BEGIN
      GetVectorAttr(DATA, np, data);
      theta := D(3.141592653589793/Float(n));
	   (*
	     Initialize the recurrence.
	   *)
      c1 := 0.5;
      IF isign = 1 THEN
         c2 := -0.5;
         Four1(DATA, n, 1); (* The forward transform is here. *)
      ELSE
         c2 := 0.5; (* Otherwise set up for an inverse transform. *)
         theta := -theta;
      END;
      wtemp := SinDD(D(0.5)*theta);
      wpr := D(-2.0)*wtemp*wtemp;
      wpi := SinDD(theta);
      wr := D(1.0)+wpr;
      wi := wpi;
      FOR i := 2 TO n DIV 2 DO (* Case I=1 done separately below. *)
         i1 := i+i-1;
         i2 := i1+1;
         i3 := n+n+3-i2;
         i4 := i3+1;
         wrs := S(wr);
         wis := S(wi);
         h1r := c1*(data^[i1-1]+data^[i3-1]); (* The two individual transforms are separated out of DATA. *)
         h1i := c1*(data^[i2-1]-data^[i4-1]);
         h2r := -c2*(data^[i2-1]+data^[i4-1]);
         h2i := c2*(data^[i1-1]-data^[i3-1]);
         data^[i1-1] := h1r+wrs*h2r-wis*h2i; (* Recombine them to form
                                                the true transform of the original real data. *)
         data^[i2-1] := h1i+wrs*h2i+wis*h2r;
         data^[i3-1] := h1r-wrs*h2r+wis*h2i;
         data^[i4-1] := -h1i+wrs*h2i+wis*h2r;
         wtemp := wr; (* The recurrence. *)
         wr := wr*wpr-wi*wpi+wr;
         wi := wi*wpr+wtemp*wpi+wi
      END;
      IF isign = 1 THEN
         h1r := data^[0];
         data^[0] := h1r+data^[1];
         data^[1] := h1r-data^[1](* Squeeze the first
                                    and last data together to get them all within the original array. *)
      ELSE
         h1r := data^[0];
         data^[0] := c1*(h1r+data^[1]);
         data^[1] := c1*(h1r-data^[1]);
         Four1(DATA, n, -1)(* Inverse transform for
                              the case isign=-1. *)
      END;
   END RealFT;

   PROCEDURE SinFT(Y: Vector);
      VAR
         jj, j, m, n2, n: INTEGER;
         sum, y1, y2, wis: REAL;
         theta, wi, wr, wpi, wpr, wtemp: LongReal; (* Double precision for trigonometric recurrences. *)
         y: PtrToReals;
   BEGIN
      GetVectorAttr(Y, n, y);
      theta := D(3.14159265358979/Float(n));
      wr := 1.0;
      wi := 0.0;
      wpr := D(-2.0)*(SinDD(D(0.5)*theta)*SinDD(D(0.5)*theta));
      wpi := SinDD(theta);
      y^[0] := 0.0;
      m := n DIV 2;
      n2 := n+2;
      FOR j := 2 TO m+1 DO
         wtemp := wr;
         wr := wr*wpr-wi*wpi+wr;
		   (*
		     Calculate the sine for the auxiliary array.
		   *)
         wi := wi*wpr+wtemp*wpi+wi;
		   (*
		     The cosine is needed to continue the recurrence.
		   *)
         wis := S(wi);
         y1 := wis*(y^[j-1]+y^[n2-j-1]); (* Construct the auxiliary
                                            array. *)
         y2 := 0.5*(y^[j-1]-y^[n2-j-1]);
         y^[j-1] := y1+y2; (* Terms j-1 and n-j-1 are related. *)
         y^[n2-j-1] := y1-y2
      END;
      RealFT(Y, m, +1); (* Transform the auxiliary array. *)
      sum := 0.0;
      y^[0] := 0.5*y^[0]; (* Initialize the sum used for odd terms below. *)
      y^[1] := 0.0;
      FOR jj := 0 TO m-1 DO
         j := 2*jj+1;
         sum := sum+y^[j-1];
         y^[j-1] := y^[j]; (* Even terms are
                              determined directly. *)
         y^[j] := sum(* Odd terms are determined by this
                        running sum. *)
      END 
   END SinFT; 

   PROCEDURE TwoFFT(DATA1, DATA2, FFT1, FFT2: Vector;
                    n: INTEGER); 
      VAR 
         nn3, nn2, nn, jj, j, nDATA1, nDATA2, nFFT1, nFFT2: INTEGER; 
         rep, rem, aip, aim: REAL; 
         data1, data2, fft1, fft2: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, nDATA1, data1);
      GetVectorAttr(DATA2, nDATA2, data2);
      GetVectorAttr(FFT1, nFFT1, fft1);
      GetVectorAttr(FFT2, nFFT2, fft2);
      nn := n+n; 
      nn2 := nn+2; 
      nn3 := nn+3; 
      FOR j := 1 TO n DO 
         jj := j+j; 
         fft1^[jj-2] := data1^[j-1]; (* Pack the two real arrays into one complex array. *)
         fft1^[jj-1] := data2^[j-1]
      END; 
      Four1(FFT1, n, 1); (* Transform the complex array. *)
      fft2^[0] := fft1^[1]; 
      fft1^[1] := 0.0; 
      fft2^[1] := 0.0; 
      FOR jj := 1 TO n DIV 2 DO 
         j := 2*jj+1; 
         rep := 0.5*(fft1^[j-1]+fft1^[nn2-j-1]); (* Use symmetries to separate the two transforms. *)
         rem := 0.5*(fft1^[j-1]-fft1^[nn2-j-1]); 
         aip := 0.5*(fft1^[j]+fft1^[nn3-j-1]); 
         aim := 0.5*(fft1^[j]-fft1^[nn3-j-1]); 
         fft1^[j-1] := rep; (* Ship them out in two complex arrays. *)
         fft1^[j] := aim; 
         fft1^[nn2-j-1] := rep; 
         fft1^[nn3-j-1] := -aim; 
         fft2^[j-1] := aip; 
         fft2^[j] := -rem; 
         fft2^[nn2-j-1] := aip; 
         fft2^[nn3-j-1] := rem
      END
   END TwoFFT; 
END FFTs.
