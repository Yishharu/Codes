MODULE XFourN; (* driver for routine FourN *) 

   FROM FourNM   IMPORT FourN;
   FROM NRSystem IMPORT Float;   
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                        GetVectorAttr, NilVector;

   CONST 
      ndim = 3; 
      ndat2 = 1024; 
   VAR 
      i, isign, j, k, l, ll, ndum: INTEGER; 
      DATA: Vector; 
      data: PtrToReals;
      NN: IVector;
      nn: PtrToIntegers; 
       
BEGIN 
   CreateVector(ndat2, DATA, data);
   CreateIVector(ndim, NN, nn);
   IF (DATA # NilVector) AND (NN # NilIVector) THEN
	   ndum := 2; 
	   FOR i := 1 TO ndim DO 
	      ndum := ndum*2; 
	      nn^[i-1] := ndum
	   END; 
	   FOR k := 1 TO nn^[0] DO 
	      FOR j := 1 TO nn^[1] DO 
	         FOR i := 1 TO nn^[2] DO 
	            l := k+(j-1)*nn^[0]+(i-1)*nn^[1]*nn^[0]; 
	            ll := 2*l-1; 
	            data^[ll-1] := Float(ll); 
	            data^[ll] := Float(ll+1);
	         END
	      END
	   END; 
	   isign := +1; 
	   FourN(DATA, NN, isign); 
	   isign := -1; 
	   WriteString('Double 3-dimensional transform'); WriteLn; WriteLn; 
	   WriteString('        Double transf.           Original data'); 
	   WriteString('               Ratio'); WriteLn; 
	   WriteString('      REAL        imag.        REAL        imag.'); 
	   WriteString('       REAL        imag.'); WriteLn; WriteLn; 
	   FourN(DATA, NN, isign); 
	   FOR i := 1 TO 4 DO 
	      j := 2*i; 
	      k := 2*j; 
	      l := k+(j-1)*nn^[0]+(i-1)*nn^[1]*nn^[0]; 
	      ll := 2*l-1; 
	      WriteReal(data^[ll-1], 12, 2); 
	      WriteReal(data^[ll], 12, 2); 
	      WriteInt(ll, 10); 
	      WriteInt(ll+1, 12); 
	      WriteReal(data^[ll-1]/Float(ll), 14, 2); 
	      WriteReal(data^[ll]/Float(ll+1), 12, 2); 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('The product of transform lengths is:'); 
	   WriteInt(nn^[0]*nn^[1]*nn^[2], 4); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XFourN', 'Not enough memory.');
	END;
 IF (DATA # NilVector) THEN DisposeVector(DATA); END; 
 IF (NN # NilIVector) THEN DisposeIVector(NN); END; 
END XFourN.
