IMPLEMENTATION MODULE Elliptic;

   FROM NRMath   IMPORT Sqrt, Exp, LnSD,  Sin, Cos, ArcTan;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;

   PROCEDURE CEl(qqc, pp, aa, bb: REAL): REAL; 
      CONST 
         ca = 0.0003; 
		   (*
		     The desired accuracy is the square of ca.
		   *)
         pio2 = 1.5707963268; 
      VAR 
         a, b, e, f, g, em, p, q, qc, cEl: REAL; 
   BEGIN 
      IF qqc = 0.0 THEN 
         Error('CEL', ''); 
      END; 
      qc := ABS(qqc); 
      a := aa; 
      b := bb; 
      p := pp; 
      e := qc; 
      em := 1.0; 
      IF p > 0.0 THEN 
         p := Sqrt(p); 
         b := b/p
      ELSE 
         f := qc*qc; 
         q := 1.0-f; 
         g := 1.0-p; 
         f := f-p; 
         q := q*(b-a*p); 
         p := Sqrt(f/g); 
         a := (a-b)/g; 
         b := ((-q))/(g*g*p)+a*p
      END; 
      LOOP 
         f := a; 
         a := a+b/p; 
         g := e/p; 
         b := b+f*g; 
         b := b+b; 
         p := g+p; 
         g := em; 
         em := qc+em; 
         IF ABS(g-qc) <= g*ca THEN 
            EXIT 
         END; 
         qc := Sqrt(e); 
         qc := qc+qc; 
         e := qc*em
      END; 
      cEl := pio2*(b+a*em)/(em*(em+p)); 
      RETURN cEl
   END CEl;

   PROCEDURE El2(x, qqc, aa, bb: REAL): REAL; 
      CONST 
         pi = 3.14159265; 
         ca = 0.0003; (* The desired accuracy is the square of ca, while cb should
                         be set to 0.01 times the desired accuracy. *)
         cb = 1.0E-9; 
      VAR 
         a, b, c, d, e, f, g, em, eye, p, qc, y, z, el2: REAL; 
         l: INTEGER; 
   BEGIN 
      IF x = 0.0 THEN 
         el2 := 0.0
      ELSIF qqc <> 0.0 THEN 
         qc := qqc; 
         a := aa; 
         b := bb; 
         c := (x*x); 
         d := 1.0+c; 
         p := Sqrt((1.0+c*(qc*qc))/d); 
         d := x/d; 
         c := d/(2.0*p); 
         z := a-b; 
         eye := a; 
         a := 0.5*(b+a); 
         y := ABS(1.0/x); 
         f := 0.0; 
         l := 0; 
         em := 1.0; 
         qc := ABS(qc); 
         LOOP 
            b := eye*qc+b; 
            e := em*qc; 
            g := e/p; 
            d := f*g+d; 
            f := c; 
            eye := a; 
            p := g+p; 
            c := 0.5*(d/p+c); 
            g := em; 
            em := qc+em; 
            a := 0.5*(b/em+a); 
            y := ((-e))/y+y; 
            IF y = 0.0 THEN 
               y := Sqrt(e)*cb
            END; 
            IF ABS(g-qc) <= ca*g THEN 
               EXIT
            ELSE
               qc := Sqrt(e)*2.0; 
               INC(l, l); 
               IF y < 0.0 THEN 
            INC(l, 1)
               END; 
            END; 
         END;
         IF y < 0.0 THEN 
            INC(l, 1)
         END; 
         e := (ArcTan(em/y)+pi*Float(l))*a/em; 
         IF x < 0.0 THEN 
            e := (-e)
         END; 
         el2 := e+c*z
      ELSE 
         Error('EL2', ''); 
		   (*
		     Argument qqc was zero.
		   *)
      END; 
      RETURN el2
   END El2;

   PROCEDURE SnCnDn(    uu, emmc: REAL; 
                    VAR sn, cn, dn: REAL); 
      CONST 
         ca = 0.0003; 
		   (*
		     The accuracy is the square of ca.
		   *)
      VAR 
         a, b, c, d, emc, u, u2, epu, emu: REAL; 
         i, ii, l: INTEGER; 
         bo, exit: BOOLEAN; 
         em, en: ARRAY [1..13] OF REAL; 
   BEGIN 
      emc := emmc; 
      u := uu; 
      IF emc <> 0.0 THEN 
         bo := (emc < 0.0); 
         IF bo THEN 
            d := 1.0-emc; 
            emc := ((-emc))/d; 
            d := Sqrt(d); 
            u := d*u
         END; 
         a := 1.0; 
         dn := 1.0; 
         exit := FALSE;
         i := 1;
         REPEAT 
            l := i; 
            em[i] := a; 
            emc := Sqrt(emc); 
            en[i] := emc; 
            c := 0.5*(a+emc); 
            IF ABS(a-emc) <= ca*a THEN 
               exit := TRUE;
            END;
            IF NOT exit THEN
               emc := a*emc; 
               a := c;
            END;
            INC(i);
         UNTIL ( (i > 13) OR exit); 
         u := c*u; 
         sn := Sin(u); 
         cn := Cos(u); 
         IF sn <> 0.0 THEN 
            a := cn/sn; 
            c := a*c; 
            FOR ii := l TO 1 BY -1 DO 
               b := em[ii]; 
               a := c*a; 
               c := dn*c; 
               dn := (en[ii]+a)/(b+a); 
               a := c/b
            END; 
            a := 1.0/Sqrt((c*c)+1.0); 
            IF sn < 0.0 THEN 
               sn := (-a)
            ELSE 
               sn := a
            END; 
            cn := c*sn
         END; 
         IF bo THEN 
            a := dn; 
            dn := cn; 
            cn := a; 
            sn := sn/d
         END; 
      ELSE 
	   (*
	     The functions are simply hyperbolic functions when kc^2=0.
	   *)
         epu := Exp(u); 
         emu := 1.0/epu; 
         cn := 2.0/(epu+emu); 
         dn := cn; 
         IF ABS(u) < 0.3 THEN 
            u2 := u*u; 
            sn := cn*u*(Float(1)+u2/Float(6)*(Float(1)+u2/Float(20)
                 *(Float(1)+u2/Float(42)*(Float(1)+u2/Float(72)))))
         ELSE 
            sn := (epu-emu)/(epu+emu)
         END
      END
   END SnCnDn; 

END Elliptic.
