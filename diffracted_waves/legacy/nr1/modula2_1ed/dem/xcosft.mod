MODULE XCosFT; (* driver for routine CosFT *) 

   FROM FFTs     IMPORT CosFT;
   FROM NRMath   IMPORT Round, Cos;
   FROM NRSystem IMPORT Float;  
   FROM NRIO     IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                        GetVectorAttr, NilVector;

   CONST 
      eps = 1.0E-3; 
      np = 16; 
      width = 30.0; 
      pi = 3.1415926; 
   VAR 
      big, per, scal, small: REAL; 
      i, jj, j, nlim: INTEGER; 
      DATA: Vector; 
      data: PtrToReals;
       
BEGIN 
   CreateVector(np, DATA, data);
   IF DATA # NilVector THEN
	   LOOP 
	      WriteString('period of cosine in channels (2-'); 
	      WriteInt(np, 2); 
	      WriteString(')'); 
	      WriteLn; 
	      ReadReal('Period', per); 
	      IF per <= 0.0 THEN EXIT END; 
	      FOR i := 1 TO np DO 
	         data^[i-1] := Cos(2.0*pi*Float((i-1))/per)
	      END; 
	      CosFT(DATA, 1); 
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
	      END; 
	      WriteString('press RETURN to continue ...'); 
	      WriteLn; 
	      ReadLn; 
	      CosFT(DATA, -1); 
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
	   DisposeVector(DATA); 
	ELSE
	   Error('XSinFT', 'Not enough memory.');
	END;
END XCosFT.
