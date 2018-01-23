IMPLEMENTATION MODULE SmooFTM;

   FROM FFTs     IMPORT RealFT;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Round;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE SmooFT(Y: Vector; 
                    n: INTEGER;
                    pts: REAL); 
      VAR 
         nmin, m, mo2, k, j, length: INTEGER; 
         yn, y1, rn1, fac, cnst: REAL; 
         y: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, length, y);
      m := 2; 
      nmin := n+Round(2.0*pts); (* Minimum size with buffer against
                                   wrap around. *)
      WHILE m < nmin DO m := 2*m END; 
	   (*
	     Find the next larger power of 2.
	   *)
      cnst := (pts/Float(m))*(pts/Float(m)); (* Useful constant below. *)
      y1 := y^[0]; 
      yn := y^[n-1]; 
      rn1 := 1.0/(Float(n)-1.0); 
      FOR j := 1 TO n DO (* Remove the linear trend and transfer data. *)
         y^[j-1] := y^[j-1]-rn1*(y1*Float(n-j)+yn*Float(j-1))
      END; 
      FOR j := n+1 TO m DO (* Zero pad. *)
         y^[j-1] := 0.0
      END; 
      mo2 := m DIV 2; 
      RealFT(Y, mo2, 1); (* Fourier transform. *)
      y^[0] := y^[0]/Float(mo2); 
      fac := 1.0; (* Window function. *)
      FOR j := 1 TO mo2-1 DO (* Multiply the data by the window function. *)
         k := 2*j+1; 
         IF fac <> 0.0 THEN
            fac := (1.0-cnst*Float(j)*Float(j))/Float(mo2); 
            IF fac < 0.0 THEN 
               fac := 0.0
            END; 
            y^[k-1] := fac*y^[k-1]; 
            y^[k] := fac*y^[k]
         ELSE (* Don't multiply unnecessarily after
                 window function is zero. *)
            y^[k-1] := 0.0; 
            y^[k] := 0.0
         END
      END; 
      fac := (1.0-0.25*pts*pts)/Float(mo2); (* Last point. *)
      IF fac < 0.0 THEN 
         fac := 0.0
      END; 
      y^[1] := fac*y^[1]; 
      RealFT(Y, mo2, -1); (* Inverse Fourier transform. *)
      FOR j := 1 TO n DO (* Restore the linear trend. *)
         y^[j-1] := rn1*(y1*Float(n-j)+yn*Float(j-1))+y^[j-1]
      END
   END SmooFT; 

END SmooFTM.
