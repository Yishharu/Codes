IMPLEMENTATION MODULE IntImpr;

   FROM PolIntM  IMPORT PolInt;
   FROM NRMath   IMPORT RealFunction, Ln, Exp, Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;

   FROM NRVect IMPORT
           Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr;

   VAR
      MidpntIt, MidinfIt, MidsqlIt, MidsquIt, MidexpIt: INTEGER;
      (* Iteration counters. *)

   PROCEDURE MidPnt(   func: RealFunction;
                       a, b: REAL; 
                   VAR s:    REAL; 
                       n:    INTEGER); 
      VAR 
         j: INTEGER; 
         x, tnm, sum, del, ddel: REAL; 
   BEGIN 
      IF n = 1 THEN 
         s := (b-a)*func(0.5*(a+b)); 
         MidpntIt := 1 (* 2imes midpntIt points will be added on the
                          rm next refinement. *)
      ELSE 
         tnm := Float(MidpntIt); 
         del := (b-a)/(3.0*tnm); 
         ddel := del+del; (* The added points alternate in spacing
                             between del and ddel. *)
         x := a+0.5*del; 
         sum := 0.0; 
         FOR j := 1 TO MidpntIt DO 
            sum := sum+func(x); 
            x := x+ddel; 
            sum := sum+func(x); 
            x := x+del
         END; 
         s := (s+(b-a)*sum/tnm)/3.0; (* The new sum is combined
                                        with the old integral to give a refined integral. *)
         MidpntIt := 3*MidpntIt
      END
   END MidPnt; 

   PROCEDURE QRomo(    func: RealFunction;
                       a, b: REAL; 
                   VAR ss:   REAL); 
      CONST 
         eps = 1.0E-6; (* The parameters have the same meaning as in QRomb. *)
         jMax = 14; 
         k = 5; 
      VAR 
         i, j: INTEGER; 
         dss: REAL; 
         H, S, C, D: Vector; 
         h, s, c, d: PtrToReals; 
   BEGIN 
      CreateVector(jMax, H, h); 
      CreateVector(jMax, S, s);
      CreateVector(k, C, c);
      CreateVector(k, D, d);
      h^[0] := 1.0; 
      FOR j := 0 TO jMax-1 DO 
         MidSql(func, a, b, s^[j], j); (* Choose appropriate integration method. *)
         IF j >= k THEN 
            FOR i := 0 TO k-1 DO 
               c^[i] := h^[j-k+i]; 
               d^[i] := s^[j-k+i]
            END; 
            PolInt(C, D, 0.0, ss, dss); 
            IF ABS(dss) < eps*ABS(ss) THEN 
               DisposeVector(D); 
               DisposeVector(C); 
               DisposeVector(S); 
               DisposeVector(H);
               RETURN;
            END
         END; 
         s^[j+1] := s^[j]; 
         h^[j+1] := h^[j]/9.0 (* This is where the assumption of
                                 step tripling and an even error series is used. *)
      END; 
      DisposeVector(D); 
      DisposeVector(C); 
      DisposeVector(S); 
      DisposeVector(H);
      Error('QRomo', 'Too many steps.'); 
   END QRomo; 

   PROCEDURE MidInf(    func:   RealFunction;
                        aa, bb: REAL; 
                    VAR s:      REAL; 
                        n:      INTEGER); 
      VAR 
         j: INTEGER; 
         x, tnm, sum, del, ddel, b, a: REAL; 

      PROCEDURE funk(x: REAL): REAL; (* This function effects the change of variable. *)
      BEGIN 
         RETURN func(1.0/x)/(x*x); 
      END funk; 

   BEGIN 
      b := 1.0/aa; (* These two statements change the limits of integration. *)
      a := 1.0/bb; 
      IF n = 1 THEN (* From this point on, the routine is
                       rm exactly identical to MidPnt. *)
         s := (b-a)*funk(0.5*(a+b)); 
         MidinfIt := 1
      ELSE 
         tnm := Float(MidinfIt); 
         del := (b-a)/(3.0*tnm); 
         ddel := del+del; 
         x := a+0.5*del; 
         sum := 0.0; 
         FOR j := 1 TO MidinfIt DO 
            sum := sum+funk(x); 
            x := x+ddel; 
            sum := sum+funk(x); 
            x := x+del
         END; 
         s := (s+(b-a)*sum/tnm)/3.0; 
         MidinfIt := 3*MidinfIt
      END
   END MidInf; 

   PROCEDURE MidSql(    func:   RealFunction;
                        aa, bb: REAL; 
                    VAR s:      REAL; 
                        n:      INTEGER); 
      VAR 
         j: INTEGER; 
         x, tnm, sum, del, ddel, b, a: REAL; 

      PROCEDURE funk(x: REAL): REAL; 
      BEGIN 
         RETURN 2.0*x*func(aa+(x*x)); 
      END funk; 

   BEGIN 
      b := Sqrt(bb-aa); 
      a := 0.0; 
      IF n = 0 THEN 
         s := (b-a)*funk(0.5*(a+b)); 
         MidsqlIt := 1
      ELSE 
         tnm := Float(MidsqlIt); 
         del := (b-a)/(3.0*tnm); 
         ddel := del+del; 
         x := a+0.5*del; 
         sum := 0.0; 
         FOR j := 1 TO MidsqlIt DO 
            sum := sum+funk(x); 
            x := x+ddel; 
            sum := sum+funk(x); 
            x := x+del
         END; 
         s := (s+(b-a)*sum/tnm)/3.0; 
         MidsqlIt := 3*MidsqlIt
      END
   END MidSql; 

   PROCEDURE MidSqu(    func:   RealFunction;
                        aa, bb: REAL; 
                    VAR s:      REAL; 
                        n:      INTEGER); 
      VAR 
         j: INTEGER; 
         x, tnm, sum, del, ddel, b, a: REAL; 

      PROCEDURE funk(x: REAL): REAL; 
      BEGIN 
         RETURN 2.0*x*func(bb-(x*x)); 
      END funk; 

   BEGIN 
      b := Sqrt(bb-aa); 
      a := 0.0; 
      IF n = 1 THEN 
         s := (b-a)*funk(0.5*(a+b)); 
         MidsquIt := 1
      ELSE 
         tnm := Float(MidsquIt); 
         del := (b-a)/(3.0*tnm); 
         ddel := del+del; 
         x := a+0.5*del; 
         sum := 0.0; 
         FOR j := 1 TO MidsquIt DO 
            sum := sum+funk(x); 
            x := x+ddel; 
            sum := sum+funk(x); 
            x := x+del
         END; 
         s := (s+(b-a)*sum/tnm)/3.0; 
         MidsquIt := 3*MidsquIt
      END
   END MidSqu; 

   PROCEDURE MidExp(    func:   RealFunction;
                        aa, bb: REAL; 
                    VAR s:      REAL; 
                        n:      INTEGER); 
      VAR 
         j: INTEGER; 
         x, tnm, sum, del, ddel, b, a: REAL; 

      PROCEDURE funk(x: REAL): REAL; 
      BEGIN 
         RETURN func(-Ln(x))/x; 
      END funk; 

   BEGIN 
      b := Exp(-aa); 
      a := 0.0;
      IF n = 1 THEN
         s := (b-a)*func(0.5*(a+b)); 
         MidexpIt := 1
      ELSE 
         tnm := Float(MidexpIt); 
         del := (b-a)/(3.0*tnm); 
         ddel := del+del; 
         x := a+0.5*del; 
         sum := 0.0; 
         FOR j := 1 TO MidexpIt DO 
            sum := sum+func(x); 
            x := x+ddel; 
            sum := sum+func(x); 
            x := x+del
         END; 
         s := (s+(b-a)*sum/tnm)/3.0; 
         MidexpIt := 3*MidexpIt
      END;
   END MidExp;

END IntImpr.
