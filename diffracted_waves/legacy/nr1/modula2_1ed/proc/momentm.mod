IMPLEMENTATION MODULE MomentM;

   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      i = 5;

   PROCEDURE Moment(    DATA: Vector; 
                        n:    INTEGER;
                    VAR ave, adev, sdev: REAL; 
                    VAR svar, skew, curt: REAL); 
      VAR 
         j, nDATA: INTEGER; 
         s, p: REAL; 
         data: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA, nDATA, data);
      IF n <= 1 THEN 
         Error('Moment', 'n must be at least 2'); 
      END; 
      s := 0.0; (* First pass to get the mean. *)
      FOR j := 0 TO n-1 DO 
         s := s+data^[j]
      END; 
      ave := s/Float(n); 
      adev := 0.0; (* Second pass to get the first (absolute), second,
                      third, and fourth moments of the deviation from the mean. *)
      svar := 0.0; 
      skew := 0.0; 
      curt := 0.0; 
      FOR j := 0 TO n-1 DO 
         s := data^[j]-ave; 
         adev := adev+ABS(s); 
         p := s*s; 
         svar := svar+p; 
         p := p*s; 
         skew := skew+p; 
         p := p*s; 
         curt := curt+p
      END; 
      adev := adev/Float(n); (* Put the pieces together according to
                                the conventional definitions. *)
      svar := svar/Float((n-1)); 
      sdev := Sqrt(svar); 
      IF svar <> 0.0 THEN 
         skew := skew/(Float(n)*sdev*sdev*sdev); 
         curt := curt/(Float(n)*(svar*svar))-3.0
      ELSE 
         Error('Moment', 'No skew/kurtosis when variance = 0'); 
      END
   END Moment; 

END MomentM.
