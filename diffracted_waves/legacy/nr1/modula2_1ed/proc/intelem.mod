IMPLEMENTATION MODULE IntElem;

   FROM NRMath   IMPORT RealFunction;
   FROM NRSystem IMPORT Float, LongInt;
   FROM NRIO     IMPORT Error;

   VAR TrapzdIt: INTEGER;

   PROCEDURE Trapzd(    func: RealFunction;
                        a, b: REAL;
                    VAR s:    REAL;
                        n:    INTEGER);
      VAR
         j: INTEGER;
         x, tnm, sum, del: REAL;
   BEGIN
      IF n = 0 THEN
         s := 0.5*(b-a)*(func(a)+func(b));
         TrapzdIt := 1 (* TrapzdIt is the number of points to be added
                          on the it next call. *)
      ELSE
         tnm := Float(TrapzdIt);
         del := (b-a)/tnm; (* This is the spacing of the points
                              to be added. *)
         x := a+0.5*del;
         sum := 0.0;
         FOR j := 1 TO TrapzdIt DO
            sum := sum+func(x);
            x := x+del
         END;
         s := 0.5*(s+(b-a)*sum/tnm);
		   (*
		     This replaces s by
		     its refined value.
		   *)
         TrapzdIt := 2*TrapzdIt
      END
   END Trapzd;

   PROCEDURE QTrap(    func: RealFunction;
                       a, b: REAL;
                   VAR s:    REAL);
      CONST
         eps = 1.0E-6;
         jMax = 20;
      VAR
         j: INTEGER;
         olds: REAL;
   BEGIN
      olds := -1.0E30; (* Any number that is unlikely to be the average
                          of the function at its endpoints will do here. *)
      FOR j := 1 TO jMax DO
         Trapzd(func, a, b, s, j);
         IF ABS(s-olds) < eps*ABS(olds) THEN RETURN END;
         olds := s
      END;
      Error('QTrap', 'Too many steps.');
   END QTrap;

   PROCEDURE QSimp(    func: RealFunction;
                       a, b: REAL;
                   VAR s:    REAL);
      CONST
         eps = 1.0E-4;
         jMax = 20;
      VAR
         j: INTEGER;
         st, ost, os: REAL;
   BEGIN
      ost := -1.0E30;
      os := -1.0E30;
      FOR j := 0 TO jMax-1 DO
         Trapzd(func, a, b, st, j);
         s := (4.0*st-ost)/3.0;
		   (*
		     Compare equation (4.2.4), above.
		   *)
         IF ABS(s-os) < eps*ABS(os) THEN RETURN END;
         os := s; 
         ost := st
      END; 
      Error('QSimp', 'Too many steps'); 
   END QSimp; 

END IntElem.
