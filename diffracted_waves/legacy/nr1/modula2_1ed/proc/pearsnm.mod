IMPLEMENTATION MODULE PearsnM;

   FROM IncBeta  IMPORT BetaI;
   FROM NRMath   IMPORT Sqrt, Ln;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE Pearsn(    X, Y: Vector; 
                    VAR r, prob, z: REAL); 
      CONST 
         tiny = 1.0E-20; 
	   (*
	     Will regularize the
	     unusual case of complete correlation.
	   *)
      VAR 
         j, n, ny: INTEGER; 
         yt, xt, t, syy, sxy, sxx, df, ay, ax: REAL; 
         x, y: PtrToReals;
   BEGIN
      GetVectorAttr(X, n, x);
      GetVectorAttr(Y, ny, y);
      ax := 0.0; 
      ay := 0.0; 
      FOR j := 0 TO n-1 DO (* Find the means. *)
         ax := ax+x^[j]; 
         ay := ay+y^[j]
      END; 
      ax := ax/Float(n); 
      ay := ay/Float(n); 
      sxx := 0.0; 
      syy := 0.0; 
      sxy := 0.0; 
      FOR j := 0 TO n-1 DO (* Compute the correlation coefficient. *)
         xt := x^[j]-ax; 
         yt := y^[j]-ay; 
         sxx := sxx+(xt*xt); 
         syy := syy+(yt*yt); 
         sxy := sxy+xt*yt; 
      END; 
      r := sxy/Sqrt(sxx*syy);
      z := 0.5*Ln(((1.0+r)+tiny)/((1.0-r)+tiny)); (* Fisher's z transformation. *)
      df := Float(n-2); 
      t := r*Sqrt(df/((1.0-r+tiny)*(1.0+r+tiny))); 
	   (*
	     Equation (13.7.5).
	   *)
      prob := BetaI(0.5*df, 0.5, df/(df+t*t)); (* Student's t probability. *)
      (* prob := ErfCC(ABS(z*Sqrt(n-1.0))/1.4142136) *)
	   (*
	     For large n, the commented computation of PROB, using the
	     short routine ErfCC, is easier and 
	     would give approximately the same value.
	   *)
   END Pearsn; 

END PearsnM.
