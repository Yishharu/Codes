MODULE XFour1; (* driver for routine Four1 *) 
 
   FROM Four1M   IMPORT Four1;
   FROM NRMath   IMPORT Exp;
   FROM NRSystem IMPORT Float;   
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                        GetVectorAttr, NilVector;

   CONST 
      nn = 32; 
      nn2 = 64; (* 2*nn *) 
   VAR 
      ii, i, isign: INTEGER; 
      DATA, DCMP: Vector; 
      data, dcmp: PtrToReals; 

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
   CreateVector(nn2, DATA, data);
   IF DATA # NilVector THEN
	   WriteString('h(t) := REAL-valued even-function'); WriteLn; 
	   WriteString('h(n) := h(N-n) and REAL?'); WriteLn; 
	   FOR ii := 0 TO nn-1 DO 
	      i := 2*ii; 
	      data^[i] := 1.0/((((Float(i+1-nn)-1.0)/Float(nn))*((Float(i+1-nn)-1.0)/Float(nn)))+1.0); 
	      data^[i+1] := 0.0
	   END; 
	   isign := 1; 
	   Four1(DATA, nn, isign); 
	   PrntFT(DATA); 
	   WriteString('h(t) := imaginary-valued even-function'); WriteLn; 
	   WriteString('h(n) := h(N-n) and imaginary'); WriteLn; 
	   FOR ii := 0 TO nn-1 DO 
	      i := 2*ii; 
	      data^[i+1] := 1.0/((((Float(i+1-nn)-1.0)/Float(nn))*((Float(i+1-nn)-1.0)/Float(nn)))+1.0); 
	      data^[i] := 0.0
	   END; 
	   isign := 1; 
	   Four1(DATA, nn, isign); 
	   PrntFT(DATA); 
	   WriteString('h(t) := REAL-valued odd-function'); WriteLn; 
	   WriteString('h(n) := -h(N-n) and imaginary'); WriteLn; 
	   FOR ii := 0 TO nn-1 DO 
	      i := 2*ii; 
	      data^[i] := ((Float(i+1-nn)-1.0)/Float(nn))/((((Float(i+1-nn)-1.0)/Float(nn))*((Float(i+1-nn)-1.0)/Float(nn)))+1.0); 
	      data^[i+1] := 0.0
	   END; 
	   data^[0] := 0.0; 
	   isign := 1; 
	   Four1(DATA, nn, isign); 
	   PrntFT(DATA); 
	   WriteString('h(t) := imaginary-valued odd-function'); WriteLn; 
	   WriteString('h(n) := -h(N-n) and REAL'); WriteLn; 
	   FOR ii := 0 TO nn-1 DO 
	      i := 2*ii; 
	      data^[i+1] := ((Float(i+1-nn)-1.0)/Float(nn))/((((Float(i+1-nn)-1.0)/Float(nn))*((Float(i+1-nn)-1.0)/Float(nn)))+1.0); 
	      data^[i] := 0.0
	   END; 
	   data^[1] := 0.0; 
	   isign := 1; 
	   Four1(DATA, nn, isign); 
	   PrntFT(DATA); (* transform, inverse-transform test *) 
	   FOR ii := 0 TO nn-1 DO 
	      i := 2*ii; 
	      data^[i] := 1.0/(((0.5*(Float(i+1-nn)-1.0)/Float(nn))
	                  *(0.5*(Float(i+1-nn)-1.0)/Float(nn)))+1.0); 
	      dcmp^[i] := data^[i]; 
	      data^[i+1] := (0.25*(Float(i+1-nn)-1.0)
	                   /Float(nn))*Exp((-(((0.5*(Float(i+1-nn)-1.0)/Float(nn))
	                   *(0.5*(Float(i+1-nn)-1.0)/Float(nn)))))); 
	      dcmp^[i+1] := data^[i+1]
	   END; 
	   isign := 1; 
	   Four1(DATA, nn, isign); 
	   isign := -1; 
	   Four1(DATA, nn, isign); 
	   WriteLn; 
	   WriteString('        double fourier transform:'); 
	   WriteString('         original data:'); WriteLn; WriteLn; 
	   WriteString('   k'); 
	   WriteString('     REAL h(k)'); 
	   WriteString('    imag h(k)'); 
	   WriteString('        REAL h(k)'); 
	   WriteString('   imag h(k)'); 
	   WriteLn; 
	   FOR ii := 0 TO (nn-1) DIV 2 DO 
	      i := 2*ii; 
	      WriteInt((i+1) DIV 2, 4); 
	      WriteReal(dcmp^[i], 14, 6); 
	      WriteReal(dcmp^[i+1], 12, 6); 
	      WriteReal(data^[i]/Float(nn), 17, 6); 
	      WriteReal(data^[i+1]/Float(nn), 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	   IF (DATA # NilVector) THEN DisposeVector(DATA); END; 
	ELSE
	   Error('XFour1', 'Not enough memory.');
	END;
END XFour1.
