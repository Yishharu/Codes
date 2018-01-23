IMPLEMENTATION MODULE DirSet;

   FROM GoldenM IMPORT MnBrak;
   FROM BrentM  IMPORT Brent;
   FROM NRMath  IMPORT VectorFunction;
   FROM NRIO    IMPORT Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                       NilMatrix, PtrToLines;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                       NilVector;

   VAR
      LinMinPCom, LinMinXCom: Vector;
      linMinPCom, linMinXCom: PtrToReals;
      VFunc: VectorFunction;

   PROCEDURE Powell(    P:    Vector; 
                        XI:   Matrix; 
                        ftol: REAL; 
                    VAR iter: INTEGER; 
                    VAR fret: REAL;
                        fncP: VectorFunction); 
      CONST 
         itmax = 200; (* Maximum allowed iterations. *)
      VAR 
         j, ibig, i, n, nxi, mxi: INTEGER; 
         t, fptt, fp, del: REAL; 
         PT, PTT, XIT: Vector;
         p, pt, ptt, xit: PtrToReals; 
         xi: PtrToLines;
   BEGIN 
      GetVectorAttr(P, n, p);
      GetMatrixAttr(XI, nxi, mxi, xi);
      CreateVector(n, PT, pt);
      CreateVector(n, PTT, ptt);
      CreateVector(n, XIT, xit);
      fret := fncP(P); 
      FOR j := 0 TO n-1 DO pt^[j] := p^[j] END; (* Save the initial point. *)
      iter := 0; 
      LOOP 
         INC(iter, 1); 
         fp := fret; 
         ibig := 0; 
         del := 0.0; (* Will be the biggest function decrease. *)
         FOR i := 0 TO n-1 DO (* In each iteration, loop over all directions in the
                                 set. *)
            FOR j := 0 TO n-1 DO xit^[j] := xi^[j]^[i] END; (* Copy the direction, *)
            fptt := fret; 
            LinMin(P, XIT, fret, fncP); (* minimize along it, *)
            IF ABS(fptt-fret) > del THEN (* and record it
                                            if it is the largest decrease so far. *)
               del := ABS(fptt-fret); 
               ibig := i
            END
         END; 
         IF 2.0*ABS(fp-fret) <= ftol*(ABS(fp)+ABS(fret)) THEN (* Termination criterion. *)
		      IF XIT # NilVector THEN DisposeVector(XIT); END;
		      IF PTT # NilVector THEN DisposeVector(PTT); END;
		      IF PT # NilVector THEN DisposeVector(PT); END;
		      RETURN;
         END; 
         IF iter = itmax THEN Error('Powell', 'Too many interation'); END; 
         FOR j := 0 TO n-1 DO (* Construct the extrapolated point and the
                                 average direction moved.  Then save the old starting point. *)
            ptt^[j] := 2.0*p^[j]-pt^[j]; 
            xit^[j] := p^[j]-pt^[j]; 
            pt^[j] := p^[j]
         END; 
         fptt := fncP(PTT); (* Function value at extrapolated point. *)
         IF fptt < fp THEN 
            t := 2.0*(fp-2.0*fret+fptt)*((fp-fret-del)*(fp-fret-del))-del*((fp-fptt)*(fp-fptt)); 
            IF t < 0.0 THEN 
               LinMin(P, XIT, fret, fncP); (* Move to the minimum of the 
                                              new direction, *)
               FOR j := 0 TO n-1 DO 
                  xi^[j]^[ibig] := xit^[j](* and save the new direction. *)
               END
            END
         END(* Back for another iteration. *)
      END; 
      IF XIT # NilVector THEN DisposeVector(XIT); END;
      IF PTT # NilVector THEN DisposeVector(PTT); END;
      IF PT # NilVector THEN DisposeVector(PT); END;
   END Powell; 

   PROCEDURE F1Dim(x: REAL; LinMinPCom, 
                   LinMinXCom: Vector; fnc: VectorFunction): REAL; 
      VAR 
         j, linMinNCom, n: INTEGER; 
         (* Define the global variables. *)
         XT: Vector;
         linMinPCom, linMinXCom, xt: PtrToReals;
         f1dim: REAL; 
   BEGIN 
      GetVectorAttr(LinMinPCom, linMinNCom, linMinPCom);
      GetVectorAttr(LinMinXCom, n, linMinXCom);
      CreateVector(linMinNCom, XT, xt);
      IF XT # NilVector THEN
	      FOR j := 0 TO linMinNCom-1 DO 
	         xt^[j] := linMinPCom^[j]+x*linMinXCom^[j]
	      END; 
	      f1dim := fnc(XT); 
	      IF XT # NilVector THEN DisposeVector(XT); END;
	      RETURN f1dim;
	   ELSE
	      Error('F1Dim', 'Not enough memory.');
	      RETURN 0.0;
	   END;
   END F1Dim; 

   PROCEDURE func(x: REAL): REAL; 
   BEGIN 
   (*
     Called by Brent and MnBrak.
   *)
       RETURN F1Dim(x, LinMinPCom, LinMinXCom, VFunc);
   END func; 
    
   PROCEDURE LinMin(P, XI: Vector; VAR fret: REAL; vf: VectorFunction); 
      CONST 
         tol = 1.0E-4; (* tol is passed to Brent. *)
      VAR 
         j, n, nXI: INTEGER; 
         xx, xmin, fx, fb, fa, bx, ax: REAL; 
         p, xi: PtrToReals;
   BEGIN 
      GetVectorAttr(P, n, p);
      GetVectorAttr(XI, nXI, xi);
      CreateVector(n, LinMinPCom, linMinPCom);
      CreateVector(n, LinMinXCom, linMinXCom);
      IF (LinMinPCom # NilVector) AND (LinMinXCom # NilVector) THEN
         VFunc := vf;
	      IF n = nXI THEN 
		      FOR j := 0 TO n-1 DO 
		         linMinPCom^[j] := p^[j]; 
		         linMinXCom^[j] := xi^[j]
		      END; 
		      ax := 0.0; (* Initial guess for brackets. *)
		      xx := 1.0; 
		      MnBrak(ax, xx, bx, fa, fx, fb, func); 
		      fret := Brent(ax, xx, bx, func, tol, xmin); 
		      FOR j := 0 TO n-1 DO (* Construct the vector results to return. *)
		         xi^[j] := xmin*xi^[j]; 
		         p^[j] := p^[j]+xi^[j]
		      END;
		   ELSE
		      Error('LinMin', 'Inproper input data.');
		   END; 
		ELSE
		   Error('LinMin', 'Not enough memory.');
		END;
      IF LinMinPCom # NilVector THEN DisposeVector(LinMinPCom) END;
      IF LinMinXCom # NilVector THEN DisposeVector(LinMinXCom) END;
   END LinMin; 

BEGIN
END DirSet.
