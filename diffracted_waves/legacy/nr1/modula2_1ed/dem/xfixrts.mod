MODULE XFixRts; (* driver for routine FixRts *) 

   FROM LinPred IMPORT FixRts;
   FROM LaguQ   IMPORT Zroots;
   FROM NRIO    IMPORT ReadLn, ReadReal, WriteLn, WriteInt, WriteReal, WriteString, 
                       Error;
   FROM NRComp  IMPORT Complex, CVector, CreateCVector, DisposeCVector,  
                       NilCVector, PtrToComplexes;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                       GetVectorAttr, NilVector;

   CONST 
      npoles = 6; 
      npolp1 = 7; (* npolp1 = npoles+1 *) 
   VAR 
      i, j: INTEGER; 
      dum: REAL; 
      polish: BOOLEAN; 
      DD: Vector;
      d: PtrToReals; 
      sixth: Complex; 
      ZCOEF, ZEROS: CVector;
      zcoef, zeros: PtrToComplexes; 
       
BEGIN 
   CreateVector(npoles, DD, d);
   CreateCVector(npolp1, ZCOEF, zcoef);
   CreateCVector(npolp1, ZEROS, zeros);
   IF (DD # NilVector) AND (ZCOEF # NilCVector) AND (ZEROS # NilCVector) THEN
	   d^[0] := 6.0;       d^[1] := -15.0;    d^[2] := 20.0; 
	   d^[3] := -15.0;     d^[4] := 6.0;      d^[5] := 0.0; 
	   polish := TRUE; (* finding roots of (z-1.0)^6 := 1.0 *) 
	   (* first write roots *) 
	   zcoef^[npoles].r := 1.0; 
	   zcoef^[npoles].i := 0.0; 
	   FOR i := npoles TO 1 BY -1 DO 
	      zcoef^[i-1].r := -d^[npoles-i]; 
	      zcoef^[i-1].i := 0.0
	   END; 
	   Zroots(ZCOEF, npoles, ZEROS, polish); 
	   WriteString('Roots of (z-1.0)^6 = 1.0'); 
	   WriteLn; 
	   WriteString('                  Root'); 
	   WriteString('                  (z-1.0)^6'); 
	   WriteLn; 
	   FOR i := 1 TO npoles DO 
	      sixth.r := 1.0; 
	      sixth.i := 0.0; 
	      FOR j := 1 TO 6 DO 
	         dum := sixth.r; 
	         sixth.r := sixth.r*(zeros^[i-1].r-1.0)-sixth.i*zeros^[i-1].i; 
	         sixth.i := dum*zeros^[i-1].i+sixth.i*(zeros^[i-1].r-1.0)
	      END; 
	      WriteInt(i, 6); 
	      WriteReal(zeros^[i-1].r, 12, 6); 
	      WriteReal(zeros^[i-1].i, 12, 6); 
	      WriteReal(sixth.r, 12, 6); 
	      WriteReal(sixth.i, 12, 6); 
	      WriteLn
	   END; (* now fix them to lie within unit circle *) 
	   FixRts(DD); (* check results *) 
	   zcoef^[npoles].r := 1.0; 
	   zcoef^[npoles].i := 0.0; 
	   FOR i := npoles TO 1 BY -1 DO 
	      zcoef^[i-1].r := -d^[npoles-i]; 
	      zcoef^[i-1].i := 0.0
	   END; 
	   Zroots(ZCOEF, npoles, ZEROS, polish); 
	   WriteLn; 
	   WriteString('Roots reflected in unit circle'); 
	   WriteLn; 
	   WriteString('                  Root'); 
	   WriteString('                  (z-1.0)^6'); 
	   WriteLn; 
	   FOR i := 1 TO npoles DO 
	      sixth.r := 1.0; 
	      sixth.i := 0.0; 
	      FOR j := 1 TO 6 DO 
	         dum := sixth.r; 
	         sixth.r := sixth.r*(zeros^[i-1].r-1.0)-sixth.i*zeros^[i-1].i; 
	         sixth.i := dum*zeros^[i-1].i+sixth.i*(zeros^[i-1].r-1.0)
	      END; 
	      WriteInt(i, 6); 
	      WriteReal(zeros^[i-1].r, 12, 6); 
	      WriteReal(zeros^[i-1].i, 12, 6); 
	      WriteReal(sixth.r, 12, 6); 
	      WriteReal(sixth.i, 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XFixRts', 'Not enough memory.');
	END;
	IF DD # NilVector THEN DisposeVector(DD) END;
	IF ZCOEF # NilCVector THEN DisposeCVector(ZCOEF) END;
	IF ZEROS # NilCVector THEN DisposeCVector(ZEROS) END;
END XFixRts.
