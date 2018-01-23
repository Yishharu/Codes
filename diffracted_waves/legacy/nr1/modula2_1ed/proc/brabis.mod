IMPLEMENTATION MODULE BraBis;

   FROM NRMath   IMPORT RealFunction;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;

   FROM NRVect IMPORT
           Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr, 
           NilVector, VectorPtr;

   PROCEDURE RtBis(fx: RealFunction; x1, x2, xacc: REAL): REAL; 
      CONST 
         jmax = 40; (* Maximum allowed number of bisections. *)
      VAR 
         dx, f, fmid, xmid, rtb: REAL; 
         j: INTEGER; 
   BEGIN 
      fmid := fx(x2); 
      f := fx(x1); 
      IF f*fmid >= 0.0 THEN 
         Error('RtBis', 'Root must be bracketed for bisection.'); 
      END; 
      IF f < 0.0 THEN (* Orient the search so that f>0 lies
                         at x+dx. *)
         rtb := x1; 
         dx := x2-x1
      ELSE 
         rtb := x2; 
         dx := x1-x2
      END; 
      FOR j := 1 TO jmax DO (* Bisection loop *)
         dx := dx*0.5; 
         xmid := rtb+dx; 
         fmid := fx(xmid); 
         IF fmid <= 0.0 THEN 
            rtb := xmid
         END; 
         IF (ABS(dx) < xacc) OR (fmid = 0.0) THEN 
            RETURN rtb; 
         END
      END; 
      Error('RtBis', 'Too many bisections.'); 
   END RtBis; 

   PROCEDURE ZBrac(    fx: RealFunction;
                   VAR x1, x2: REAL; 
                   VAR succes: BOOLEAN); 
        CONST 
         factor = 1.6; 
         ntry = 50; 
      VAR 
         j: INTEGER; 
         f2, f1: REAL; 
   BEGIN 
      IF x1 = x2 THEN 
         Error('ZBrac', 'you have to guess an initial range'); 
      END; 
      f1 := fx(x1); 
      f2 := fx(x2); 
      succes := TRUE; 
      FOR j := 1 TO ntry DO 
         IF f1*f2 < 0.0 THEN 
            RETURN;
         END; 
         IF ABS(f1) < ABS(f2) THEN 
            x1 := x1+factor*(x1-x2); 
            f1 := fx(x1)
         ELSE 
            x2 := x2+factor*(x2-x1); 
            f2 := fx(x2)
         END
      END; 
      succes := FALSE; 
   END ZBrac; 

   PROCEDURE ZBrak(    fx: RealFunction;
                       x1, x2: REAL; 
                       n: INTEGER; 
                       XB1, XB2: Vector; 
                   VAR nb: INTEGER); 
      VAR 
         nbb, i, nxb1, nxb2: INTEGER; 
         xb1, xb2: PtrToReals;
         x, fp, fc, dx: REAL; 
   BEGIN 
      GetVectorAttr(XB1, nxb1, xb1);
      GetVectorAttr(XB2, nxb2, xb2);
      IF (nxb1 = nb) AND (nxb2 = nb) THEN
	      nbb := nb; 
	      nb := -1; 
	      x := x1; 
	      dx := (x2-x1)/Float(n); (* Determine the spacing appropriate to the mesh. *)
	      fp := fx(x); 
	      FOR i := 1 TO n DO (* Loop over all intervals *)
	         x := x+dx; 
	         fc := fx(x); 
	         IF fc*fp < 0.0 THEN (* If a sign change occurs then
                                   record values for the bounds. *)
	            INC(nb, 1); 
	            xb1^[nb] := x-dx; 
	            xb2^[nb] := x
	         END; 
	         fp := fc; 
	         IF nbb = nb THEN RETURN END; 
	      END; 
	   ELSE
	      Error('ZBrak', 'Inproper input data.');
	   END;
   END ZBrak; 

END BraBis.
