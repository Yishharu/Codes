MODULE XShoot; (* driver for routine Shoot *) 
(* Solves for eigenvalues of spheroidal harmonics. Both
prolate and oblate case are handled simultaneously, leading
to six first-order equations. Unknown to shoot, it is
actually two independent sets of three coupled equations,
one set with c^2 positive and the other with c^2 negative.  *)

   FROM ShootM   IMPORT Shoot;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn,    ReadInt,   ReadReal, WriteLn,   WriteInt,  
                        WriteReal, WriteString, Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, NilMatrix, PtrToLines;

   CONST 
      nvar = 6; 
      n2 = 2; 
      delta = 1.0E-3; 
      eps = 1.0E-6; 
      dx = 1.0E-4; 
   VAR 
      ShootC2, ShootFactr, h1, hmin, q1, x1, x2: REAL; 
      i, ShootM, ShootN: INTEGER; 
      DELV, V, DV, F, OdeIntXp: Vector; 
      delv, v, dv, f, odeIntXp: PtrToReals;
      OdeintKmax, OdeintKount: INTEGER; 
      OdeintDxsav: REAL; 
      odeIntYp: PtrToLines;
      OdeIntYp: Matrix; 

   (* Programs using routine load must declare the global variables
   VAR
      ShootC2,ShootFactr: REAL;
      ShootM: INTEGER;
   in the main routine. *) 

   PROCEDURE load(x1: REAL; 
                  V, Y: Vector); 
      VAR 
         nvar, n2: INTEGER;
         y, v: PtrToReals;
   BEGIN 
      GetVectorAttr(V, n2, v);
      GetVectorAttr(Y, nvar, y);
      y^[2] := v^[0]; 
      y^[1] := -(y^[2]-ShootC2)*ShootFactr/2.0/(Float(ShootM)+1.0); 
      y^[0] := ShootFactr+y^[1]*dx; 
      y^[5] := v^[1]; 
      y^[4] := -(y^[5]+ShootC2)*ShootFactr/2.0/(Float(ShootM)+1.0); 
      y^[3] := ShootFactr+y^[4]*dx
   END load; 

   (* Programs using routine score must declare the global variables
   VAR
      ShootM,ShootN: INTEGER;
   in the main routine. *) 

   PROCEDURE score(x2: REAL; 
                   Y, F: Vector); 
      VAR 
         nvar, n2: INTEGER;
         y, f: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, nvar, y);
      GetVectorAttr(F, n2, f);
      IF ODD(ShootN-ShootM) THEN 
         f^[0] := y^[0]; 
         f^[1] := y^[3]
      ELSE 
         f^[0] := y^[1]; 
         f^[1] := y^[4]
      END
   END score; 

   (* Programs using routine derivs must declare the global variables
   VAR
      ShootC2: REAL;
      ShootM: INTEGER;
   in the main routine. *) 

   PROCEDURE derivs(x: REAL; 
                    Y, DYDX: Vector); 
      VAR 
         nvar, ndydx: INTEGER;
         y, dydx: PtrToReals;
   BEGIN 
      GetVectorAttr(Y, nvar, y);
      GetVectorAttr(DYDX, ndydx, dydx);
      dydx^[0] := y^[1]; 
      dydx^[2] := 0.0; 
      dydx^[1] := (2.0*x*(Float(ShootM)+1.0)*y^[1]-(y^[2]-ShootC2*x*x)*y^[0])/(1.0-x*x); 
      dydx^[3] := y^[4]; 
      dydx^[5] := 0.0; 
      dydx^[4] := (2.0*x*(Float(ShootM)+1.0)*y^[4]-(y^[5]+ShootC2*x*x)*y^[3])/(1.0-x*x)
   END derivs; 
    
BEGIN 
   CreateVector(n2, DELV, delv);
   CreateVector(n2, V, v);
   CreateVector(n2, DV, dv);
   CreateVector(n2, F, f);
   CreateVector(200, OdeIntXp, odeIntXp);
   CreateMatrix(nvar, 200, OdeIntYp, odeIntYp);
   IF (DELV # NilVector) AND (V # NilVector) AND (DV # NilVector) AND
      (F # NilVector) AND (OdeIntXp # NilVector) AND (OdeIntYp # NilMatrix) THEN
	   REPEAT 
	      WriteString('Input M,N,C-Squared:  '); 
	      ReadInt('ShootM:', ShootM); 
	      ReadInt('ShootN:', ShootN); 
	      ReadReal('ShootC2', ShootC2); 
	   UNTIL (ShootN >= ShootM) AND (ShootM >= 0); 
	   ShootFactr := 1.0; 
	   IF ShootM <> 0 THEN 
	      q1 := Float(ShootN); 
	      FOR i := 1 TO ShootM DO 
	         ShootFactr := -0.5*ShootFactr*Float(ShootN+i)*(q1/Float(i)); 
	         q1 := q1-1.0
	      END
	   END; 
	   v^[0] := Float(ShootN*(ShootN+1)-ShootM*(ShootM+1))+ShootC2/2.0; 
	   v^[1] := Float(ShootN*(ShootN+1)-ShootM*(ShootM+1))-ShootC2/2.0; 
	   delv^[0] := delta*v^[0]; 
	   delv^[1] := delv^[0]; 
	   h1 := 0.1; 
	   hmin := 0.0; 
	   x1 := -1.0+dx; 
	   x2 := 0.0; 
	   WriteLn; 
	   WriteString('          Prolate                Oblate:'); WriteLn;
	   WriteString('    Mu(m,n)    Error Est.');
	   WriteString('   Mu(m,n)    Error Est.'); WriteLn;
	   REPEAT
	      Shoot(nvar, V, DELV, x1, x2, eps, h1, hmin, load, score, derivs, 
	            ShootM, ShootN, ShootC2, ShootFactr, OdeintDxsav, OdeintKmax,
	            OdeIntXp, OdeIntYp, OdeintKount, F, DV);
	      WriteReal(v^[0], 12, 6);
	      WriteReal(dv^[0], 12, 6);
	      WriteReal(v^[1], 12, 6);
	      WriteReal(dv^[1], 12, 6);
	      WriteLn;
	   UNTIL (ABS(dv^[0]) <= ABS(eps*v^[0])) AND (ABS(dv^[1]) <= ABS(eps*v^[1]));
	   ReadLn;
	ELSE
	   Error('XShoot', 'Not enough memory.');
	END;
   IF DELV # NilVector THEN DisposeVector(DELV) END;
   IF V # NilVector THEN DisposeVector(V) END;
   IF DV # NilVector THEN DisposeVector(DV) END;
   IF F # NilVector THEN DisposeVector(F) END;
   IF OdeIntXp # NilVector THEN DisposeVector(OdeIntXp) END;
   IF OdeIntYp # NilMatrix THEN DisposeMatrix(OdeIntYp) END;
END XShoot.
