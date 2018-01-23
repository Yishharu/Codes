MODULE XMoment; (* driver for routine Moment *) 
 
   FROM MomentM  IMPORT Moment;
   FROM NRMath   IMPORT Round, Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      pi = 3.14159265; 
      npts = 1000; 
      nbin = 100; 
      nppnb = 1100; (* nppnb=npts+nbin *) 
   VAR 
      adev, ave, curt, sdev, skew: REAL; 
      vrnce, x: REAL; 
      i, j, k, nlim: INTEGER; 
      DATA: Vector;
      data: PtrToReals;
       
BEGIN 
   CreateVector(nppnb, DATA, data);
   IF DATA # NilVector THEN 
	   i := 0; 
	   FOR j := 1 TO nbin DO 
	      x := pi*Float(j)/Float(nbin); 
	      nlim := Round(Sin(x)*pi/2.0*Float(npts)/Float(nbin)); 
	      FOR k := 1 TO nlim DO 
	         data^[i] := x; 
	         INC(i, 1)
	      END
	   END; 
	   WriteString('moments of a sinusoidal distribution'); 
	   WriteLn; 
	   WriteLn; 
	   Moment(DATA, npts, ave, adev, sdev, vrnce, skew, curt); 
	   WriteString('                   calculated'); 
	   WriteString('   expected'); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('Mean :'); 
	   WriteString('                   '); 
	   WriteReal(ave, 12, 4); 
	   WriteReal(pi/2.0, 12, 4); 
	   WriteLn; 
	   WriteString('Average Deviation :'); 
	   WriteString('      '); 
	   WriteReal(adev, 12, 4); 
	   WriteReal((pi/2.0)-1.0, 12, 4); 
	   WriteLn; 
	   WriteString('Standard Deviation :'); 
	   WriteString('     '); 
	   WriteReal(sdev, 12, 4); 
	   WriteReal(0.683667, 12, 4); 
	   WriteLn; 
	   WriteString('Variance :'); 
	   WriteString('               '); 
	   WriteReal(vrnce, 12, 4); 
	   WriteReal(0.467401, 12, 4); 
	   WriteLn; 
	   WriteString('Skewness :'); 
	   WriteString('               '); 
	   WriteReal(skew, 12, 4); 
	   WriteReal(0.0, 12, 4); 
	   WriteLn; 
	   WriteString('Kurtosis :'); 
	   WriteString('               '); 
	   WriteReal(curt, 12, 4); 
	   WriteReal(-0.806249, 12, 4); 
	   WriteLn;
	   ReadLn;
	   DisposeVector(DATA);
	ELSE
	   Error('XMoment', 'Not enough memory.');
	END;
END XMoment.
