IMPLEMENTATION MODULE FitM;

   FROM IncGamma IMPORT GammQ;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE Fit(    X, Y, SIG: Vector; 
                     mwt: INTEGER; 
                 VAR a, b, siga: REAL; 
                 VAR sigb, chi2, q: REAL); 
      VAR 
         i, ndata, ny, nsig: INTEGER; 
         wt, t, sy, sxoss, sx, st2, ss, sigdat: REAL; 
         x, y, sig: PtrToReals;
   BEGIN 
      GetVectorAttr(X, ndata, x);
      GetVectorAttr(Y, ny, y);
      GetVectorAttr(SIG, nsig, sig);
      sx := 0.0; (* Initialize sums to zero. *)
      sy := 0.0; 
      st2 := 0.0; 
      b := 0.0; 
      IF mwt <> 0 THEN (* Accumulate sums ... *)
         ss := 0.0; 
         FOR i := 0 TO ndata-1 DO (* ...with weights *)
            wt := 1.0/(sig^[i]*sig^[i]); 
            ss := ss+wt; 
            sx := sx+x^[i]*wt; 
            sy := sy+y^[i]*wt
         END
      ELSE 
         FOR i := 0 TO ndata-1 DO (* ...or without weights. *)
            sx := sx+x^[i]; 
            sy := sy+y^[i]
         END; 
         ss := Float(ndata)
      END; 
      sxoss := sx/ss; 
      IF mwt <> 0 THEN 
         FOR i := 0 TO ndata-1 DO 
            t := (x^[i]-sxoss)/sig^[i]; 
            st2 := st2+t*t; 
            b := b+t*y^[i]/sig^[i]
         END
      ELSE 
         FOR i := 0 TO ndata-1 DO 
            t := x^[i]-sxoss; 
            st2 := st2+t*t; 
            b := b+t*y^[i]
         END
      END; 
      b := b/st2; (* Solve for a, b, sigmaa and sigmab. *)
      a := (sy-sx*b)/ss; 
      siga := Sqrt((1.0+sx*sx/(ss*st2))/ss); 
      sigb := Sqrt(1.0/st2); 
      chi2 := 0.0; (* Calculate chi ^2. *)
      IF mwt = 0 THEN 
         FOR i := 0 TO ndata-1 DO 
            chi2 := chi2+(y^[i]-a-b*x^[i])*(y^[i]-a-b*x^[i])
         END; 
         q := 1.0; 
         sigdat := Sqrt(chi2/Float((ndata-2))); (* For unweighted data evaluate typical sig
                                                   using chi2, and adjust the standard deviations. *)
         siga := siga*sigdat; 
         sigb := sigb*sigdat
      ELSE 
         FOR i := 0 TO ndata-1 DO 
            chi2 := chi2+((y^[i]-a-b*x^[i])/sig^[i])*((y^[i]-a-b*x^[i])/sig^[i])
         END; 
         q := GammQ(0.5*Float(ndata-2), 0.5*chi2) (* section 6.2 *)
      END; 
   END Fit; 

END FitM.
