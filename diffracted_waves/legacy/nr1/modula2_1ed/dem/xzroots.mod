MODULE XZRoots; (* driver for routine Zroots *) 
 
   FROM LaguQ  IMPORT Zroots;
   FROM NRIO   IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRBase IMPORT Equal;
   FROM NRComp IMPORT CVector, NilCVector, PtrToComplexes, CreateCVector, 
                      DisposeCVector;

   CONST 
      mp1 = 5;  
   VAR 
      i: INTEGER; 
      polish: BOOLEAN; 
      A, ROOTS: CVector; 
      a, roots: PtrToComplexes; 
       
BEGIN 
   CreateCVector(mp1, A, a);
   CreateCVector(mp1, ROOTS, roots);
   IF (A # NilCVector) AND (ROOTS # NilCVector) THEN
	   a^[0].r := 0.0;    a^[0].i := 2.0; 
	   a^[1].r := 0.0;    a^[1].i := 0.0; 
	   a^[2].r := -1.0;   a^[2].i := -2.0; 
	   a^[3].r := 0.0;    a^[3].i := 0.0; 
	   a^[4].r := 1.0;    a^[4].i := 0.0; 
	   WriteString('Roots of the polynomial x^4-(1+2i)*x^2+2i'); 
	   WriteLn; 
	   polish := TRUE; 
	   Zroots(A, mp1-1, ROOTS, polish); 
	   WriteLn; 
	   WriteString('        root #'); 
	   WriteString('         real'); 
	   WriteString('         imag.'); 
	   WriteLn; 
	   FOR i := 0 TO mp1-2 DO 
	      WriteInt(i+1, 11); 
	      WriteString('     '); 
	      WriteReal(roots^[i].r, 12, 6); 
	      WriteReal(roots^[i].i, 12, 6); 
	      WriteLn
	   END; 
	   ReadLn;
	ELSE
	   Error('XZRoots', 'Not enough memory.');
	END;
   IF (A # NilCVector) THEN DisposeCVector(A) END;
   IF (ROOTS # NilCVector) THEN DisposeCVector(ROOTS) END;
END XZRoots.
