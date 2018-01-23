MODULE XChebFt; (* driver for routine ChebFt *)

   FROM ChebAppr IMPORT ChebFt;
   FROM NRMath   IMPORT Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn,  ReadInt, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector;

   CONST 
      nValue = 40; 
      pio2 = 1.5707963; 
      eqs = 1.0E-6; 
   VAR 
      a, b, dum, f: REAL; 
      t0, t1, term, x, y: REAL; 
      i, j, mval: INTEGER; 
      C: Vector; 
      c: PtrToReals; 

   PROCEDURE func(x: REAL): REAL;
   BEGIN
      RETURN (x*x)*(x*x-2.0)*Sin(x);
   END func;

BEGIN
   CreateVector(nValue, C, c);
   IF (C # NilVector) THEN
	   a := -pio2;
	   b := pio2;
	   ChebFt(func, a, b, C); (* test result *)
	   LOOP
	      WriteLn;
	      WriteString('How many terms in Chebyshev evaluation');
	      WriteLn;
	      WriteString('Enter n between 6 and ');
	      WriteInt(nValue, 2);
	      ReadInt('. (n := 0 to END): ', mval);
	      IF (mval <= 0) OR (mval > nValue) THEN 
	         EXIT 
	      END; 
	      WriteLn; 
	      WriteString('        x'); 
	      WriteString('        actual'); 
	      WriteString('   chebyshev fit'); 
	      WriteLn; 
	      FOR i := -8 TO 8 DO 
	         x := Float(i)*pio2/10.0; 
	         y := (x-0.5*(b+a))/(0.5*(b-a)); 
	                  (* evaluate chebyshev polynomial without uSing routine ChebEv *) 
	         t0 := 1.0; 
	         t1 := y; 
	         f := c^[1]*t1+c^[0]*0.5; 
	         FOR j := 2 TO mval DO 
	            dum := t1; 
	            t1 := 2.0*y*t1-t0; 
	            t0 := dum; 
	            term := c^[j]*t1; 
	            f := f+term
	         END; 
	         WriteReal(x, 12, 6); 
	         WriteReal(func(x), 12, 6); 
	         WriteReal(f, 12, 6); 
	         WriteLn
	      END
	   END; 
	   DisposeVector(C);
	ELSE
	   Error('XChebFt', 'Not enough memory.');
	END;
END XChebFt.
