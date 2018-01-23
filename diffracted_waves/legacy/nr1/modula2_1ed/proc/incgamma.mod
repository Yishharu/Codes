IMPLEMENTATION MODULE IncGamma;

   FROM NRMath   IMPORT Exp, Ln;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM GammBeta IMPORT GammLn;

   PROCEDURE GSer(    a,      x:   REAL; 
                  VAR gamSer, gLn: REAL); 
      CONST 
         itMax = 100; 
         eps   = 3.0E-7; 
      VAR 
         n: INTEGER; 
         sum, del, ap: REAL; 
   BEGIN 
      gLn := GammLn(a); 
      IF x <= 0.0 THEN 
         IF x < 0.0 THEN 
            Error('GSer', 'x less than 0'); 
         END; 
         gamSer := 0.0
      ELSE 
         ap := a; 
         sum := 1.0/a; 
         del := sum; 
         n := 1;
         REPEAT 
            ap := ap+1.0; 
            del := del*x/ap; 
            sum := sum+del; 
            INC(n);
         UNTIL ( (n > itMax) OR (ABS(del) < ABS(sum)*eps) ); 
         IF ABS(del) < ABS(sum)*eps THEN 
            gamSer := sum*Exp((-x)+a*Ln(x)-gLn)
         ELSE
            Error('GSer' ,'a too large, itMax too small'); 
         END
      END
   END GSer;

   PROCEDURE GCF(    a,      x:   REAL; 
                VAR gammCF, gLn: REAL); 
      CONST 
         itMax = 100; 
         eps   = 3.0E-7; 
      VAR 
         n: INTEGER; 
         gold, g, fac, b1, b0, anf, ana, an, a1, a0: REAL;
         exit: BOOLEAN;
   BEGIN 
      gLn := GammLn(a); 
      gold := 0.0; (* This is the previous value, tested against
                      for convergence. *)
      a0 := 1.0; 
      a1 := x; (* We are here setting up the a's and a's of
                  equation (5.2.4) for evaluating the continued fraction. *)
      b0 := 0.0; 
      b1 := 1.0; 
      fac := 1.0;(* fac is the renormalization factor for
                    preventing overflow of the partial numerators and denominators. *)
      exit := FALSE;
      n := 1;
      REPEAT 
         an := 1.0*Float(n); 
         ana := an-a; 
         a0 := (a1+a0*ana)*fac; (* One step of the recurrence (5.2.5). *)
         b0 := (b1+b0*ana)*fac; 
         anf := an*fac; 
         a1 := x*a0+anf*a1; (* The next step of the recurrence (5.2.5). *)
         b1 := x*b0+anf*b1; 
         IF a1 <> 0.0 THEN (* Shall we renormalize? *)
            fac := 1.0/a1; (* Yes.  Set fac so it happens. *)
            g := b1*fac; (* New value of answer. *)
            IF ABS((g-gold)/g) < eps THEN 
				   (*
				     Converged? If so, exit.
				   *)
               exit := TRUE;
            END; 
            IF NOT exit THEN
               gold := g(* If not, save value. *)
            END;
         END;
         INC(n);
      UNTIL ( (n > itMax) OR exit); 
      IF exit THEN
         gammCF := Exp((-x)+a*Ln(x)-gLn)*g(* Put factors in front. *)
      ELSE
         Error('GCF', 'a too large, itMax too small'); 
      END;
   END GCF;

   PROCEDURE GammP(a, x: REAL): REAL; 
      VAR 
         gamSer, gammCF, gLn, gammP: REAL; 
   BEGIN 
      IF (x < 0.0) OR (a <= 0.0) THEN 
         Error('GammP', 'invalid arguments'); 
      END; 
      IF x < a+1.0 THEN (* Use the series representation. *)
         GSer(a, x, gamSer, gLn); 
         gammP := gamSer
      ELSE (* Use the continued fraction representation *)
         GCF(a, x, gammCF, gLn); 
         gammP := 1.0-gammCF (* and take its complement. *)
      END; 
      RETURN gammP
   END GammP; 

   PROCEDURE GammQ(a, x: REAL): REAL; 
      VAR 
         gamSer, gammCF, gLn, gammQ: REAL; 
   BEGIN 
      IF (x < 0.0) OR (a <= 0.0) THEN 
         Error('GammQ', 'invalid arguments'); 
      END; 
      IF x < a+1.0 THEN 
		   (*
		     Use the series representation
		   *)
         GSer(a, x, gamSer, gLn); 
         gammQ := 1.0-gamSer (* and take its complement. *)
      ELSE (* Use the continued fraction representation. *)
         GCF(a, x, gammCF, gLn); 
         gammQ := gammCF
      END; 
      RETURN gammQ
   END GammQ;

   PROCEDURE ErF(x: REAL): REAL;  
   BEGIN 
      IF x < 0.0 THEN 
         RETURN -GammP(0.5, x*x)
      ELSE 
         RETURN GammP(0.5, x*x)
      END; 
   END ErF; 

   PROCEDURE ErFC(x: REAL): REAL; 
   BEGIN 
      IF x < 0.0 THEN 
         RETURN 1.0+GammP(0.5, x*x)
      ELSE 
         RETURN GammQ(0.5, x*x)
      END; 
   END ErFC; 


   PROCEDURE ErFCC(x: REAL): REAL; 
      VAR 
         t, z, erFCC: REAL; 
   BEGIN 
      z := ABS(x); 
      t := 1.0/(1.0+0.5*z); 
      erFCC := t*Exp(((-z))*z-1.26551223+t*(1.00002368
              +t*(0.37409196+t*(0.09678418+t*((-0.18628806)
              +t*(0.27886807+t*((-1.13520398)+t*(1.48851587
              +t*((-0.82215223)+t*0.17087277))))))))); 
      IF x >= 0.0 THEN 
         RETURN erFCC
      ELSE 
         RETURN 2.0-erFCC
      END; 
   END ErFCC; 

END IncGamma.
