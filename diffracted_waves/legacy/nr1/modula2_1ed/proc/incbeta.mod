IMPLEMENTATION MODULE IncBeta;

   FROM GammBeta IMPORT GammLn;
   FROM NRMath   IMPORT Exp, Ln;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;

   PROCEDURE BetaCF(a, b, x: REAL): REAL; 
      CONST 
         itMax = 100; 
         eps = 3.0E-7; 
      VAR 
         tem, qap, qam, qab, em, d, bz, bpp, 
         bp, bm, az, app, betaCF, am, aold, ap: REAL; 
         m: INTEGER; 
   BEGIN 
      am := 1.0; 
      bm := 1.0; 
      az := 1.0; 
      qab := a+b; (* These q's will be used in factors which occur
                     in the coefficients (6.3.6). *)
      qap := a+1.0; 
      qam := a-1.0; 
      bz := 1.0-qab*x/qap; 
      m := 1;
      REPEAT(* Continued fraction evaluation by the
               recurrence method (5.2.5). *)
         em := Float(m); 
         tem := em+em; 
         d := em*(b-Float(m))*x/((qam+tem)*(a+tem)); 
         ap := az+d*am; (* One step (the even one) of the recurrence. *)
         bp := bz+d*bm; 
         d := -(a+em)*(qab+em)*x/((a+tem)*(qap+tem)); 
         app := ap+d*az; (* Next step of the recurrence (the odd one). *)
         bpp := bp+d*bz; 
         aold := az; (* Save the old answer. *)
         am := ap/bpp; (* Renormalize to prevent overflows. *)
         bm := bp/bpp; 
         az := app/bpp; 
         bz := 1.0; 
         INC(m);
      UNTIL ( (m > itMax) OR (ABS(az-aold) < eps*ABS(az)) );
      IF ABS(az-aold) < eps*ABS(az) THEN (* Are we done? *)
         betaCF := az; 
      ELSE
         Error('BetaCF', 'a or b too big, or itMax too small');
         betaCF := -1.0;
      END;
      RETURN betaCF
   END BetaCF;

   PROCEDURE BetaI(a, b, x: REAL): REAL; 
      VAR 
         bt, betaI: REAL; 
   BEGIN 
      IF (x < 0.0) OR (x > 1.0) THEN 
         Error('BetaI', ''); 
      END; 
      IF (x = 0.0) OR (x = 1.0) THEN 
         bt := 0.0
      ELSE 
         bt := Exp(GammLn(a+b)-GammLn(a)-GammLn(b)
               +a*Ln(x)+b*Ln(1.0-x))(* Factors in front of the continued fraction. *)
      END; 
      IF x < (a+1.0)/(a+b+2.0) THEN (* Use continued fraction directly. *)
         RETURN bt*BetaCF(a, b, x)/a
      ELSE (* Use continued fraction after making the symmetry transformation. *)
         RETURN 1.0-bt*BetaCF(b, a, 1.0-x)/b
      END; 
   END BetaI;

END IncBeta.
