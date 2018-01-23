MODULE XRealFT; (* driver for routine RealFT *) 

   FROM FFTs     IMPORT RealFT;
   FROM NRMath   IMPORT Sqrt, Round, Cos;
   FROM NRSystem IMPORT Float;   
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                        GetVectorAttr, NilVector;

   CONST 
      eps = 1.0E-3; 
      np = 32; 
      width = 50.0; 
      pi = 3.1415926; 
   VAR 
      big, per, scal, small: REAL; 
      i, j, n, nlim: INTEGER; 
      DATA, SIZE: Vector; 
      data, size: PtrToReals;
       
BEGIN 
   n := np DIV 2; 
   CreateVector(np, DATA, data);
   CreateVector(np, SIZE, size);
   IF (DATA # NilVector) AND (SIZE # NilVector) THEN
	   LOOP 
	      WriteString('Period of sinusoid in channels (2-'); 
	      WriteInt(np, 2); 
	      WriteString(')'); 
	      WriteLn; 
	      ReadReal('Period', per); 
	      IF per <= 0.0 THEN EXIT END; 
	      FOR i := 1 TO np DO 
	         data^[i-1] := Cos(2.0*pi*Float(i-1)/per)
	      END; 
	      RealFT(DATA, n, 1); 
	      size^[0] := data^[0]; 
	      big := size^[0]; 
	      FOR i := 2 TO n DO 
	         size^[i-1] := Sqrt((data^[2*i-2]*data^[2*i-2])+(data^[2*i-1]*data^[2*i-1])); 
	         IF size^[i-1] > big THEN 
	            big := size^[i-1]
	         END
	      END; 
	      scal := width/big; 
	      FOR i := 1 TO n DO 
	         nlim := Round(scal*size^[i-1]+eps); 
	         WriteInt(i, 4); 
	         WriteString(' '); 
	         FOR j := 1 TO nlim+1 DO 
	            WriteString('*')
	         END; 
	         WriteLn
	      END; 
	      WriteString('press RETURN to continue ...'); 
	      WriteLn; 
	      ReadLn; 
	      RealFT(DATA, n, -1); 
	      big := -1.0E10; 
	      small := 1.0E10; 
	      FOR i := 1 TO np DO 
	         IF data^[i-1] < small THEN 
	            small := data^[i-1]
	         END; 
	         IF data^[i-1] > big THEN 
	            big := data^[i-1]
	         END
	      END; 
	      scal := width/(big-small); 
	      FOR i := 1 TO np DO 
	         nlim := Round(scal*(data^[i-1]-small)+eps); 
	         WriteInt(i, 4); 
	         WriteString(' '); 
	         FOR j := 1 TO nlim+1 DO 
	            WriteString('*')
	         END; 
	         WriteLn
	      END
	   END; 
	ELSE
	   Error('XRealFT', 'Not enough memory.');
	END;
	IF DATA # NilVector THEN DisposeVector(DATA); END;
	IF SIZE # NilVector THEN DisposeVector(SIZE); END;
END XRealFT.
