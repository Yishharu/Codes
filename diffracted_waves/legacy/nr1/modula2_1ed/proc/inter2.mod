IMPLEMENTATION MODULE Inter2;

   FROM PolIntM  IMPORT PolInt;
   FROM Splines  IMPORT Spline, Splint;
   FROM NRIO     IMPORT File, Open, Close, GetInt, Error;
   FROM NRSystem IMPORT Float;
   FROM NRMatr   IMPORT Matrix, GetMatrixAttr, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr;

   VAR
      InFile: File;
      BcucofFlag: BOOLEAN;
      BcucofWt: ARRAY [0..15],[0..15] OF REAL;

   PROCEDURE BCuCof(    y, y1, y2, y12: RealArray4; 
                        d1, d2:         REAL; 
                    VAR c:          RealArray4by4); 
      VAR 
         l, k, j, i, work: INTEGER; 
         xx, d1d2: REAL; 
         cl, x: ARRAY [0..15] OF REAL; 
   BEGIN 
      IF BcucofFlag THEN 
         BcucofFlag := FALSE; 
         Open('BCUCOF.DAT', InFile); (* See below. *)
         FOR i := 0 TO 15 DO 
            FOR k := 0 TO 15 DO 
               GetInt(InFile, work); 
               BcucofWt[k, i] := Float(work); 
            END
         END; 
         Close(InFile)
      END; 
      d1d2 := d1*d2; 
      FOR i := 0 TO 3 DO (* Pack a temporary vector x. *)
         x[i] := y[i]; 
         x[i+4] := y1[i]*d1; 
         x[i+8] := y2[i]*d2; 
         x[i+12] := y12[i]*d1d2
      END; 
      FOR i := 0 TO 15 DO (* Matrix multiply by the stored table. *)
         xx := 0.0; 
         FOR k := 0 TO 15 DO 
            xx := xx+BcucofWt[i, k]*x[k]
         END; 
         cl[i] := xx
      END; 
      l := -1; 
      FOR i := 0 TO 3 DO (* Unpack the result into the output table. *)
         FOR j := 0 TO 3 DO 
            INC(l); 
            c[i, j] := cl[l]
         END
      END; 
   END BCuCof; 

   PROCEDURE BCuInt(    y, y1, y2, y12:             RealArray4; 
                        x1l, x1u, x2l, x2u, x1, x2: REAL; 
                    VAR ansy, ansy1, ansy2:         REAL); 
      VAR 
         i, nc, mc: INTEGER; 
         t, u, d1, d2: REAL; 
         c: RealArray4by4;
   BEGIN 
      d1 := x1u-x1l; 
      d2 := x2u-x2l; 
      BCuCof(y, y1, y2, y12, d1, d2, c); 
	   (*
	     Get the c's.
	   *)
      IF (x1u = x1l) OR (x2u = x2l) THEN 
         Error('BCuInt', 'Bad input.'); 
      ELSE
	      t := (x1-x1l)/d1; (* Equation 3.6.4. *)
	      u := (x2-x2l)/d2; 
	      ansy := 0.0; 
	      ansy2 := 0.0; 
	      ansy1 := 0.0; 
	      FOR i := 3 TO 0 BY -1 DO 
		   (*
		     Equation 3.6.6.
		   *)
	         ansy := t*ansy+((c[i, 3]*u+c[i, 2])*u+c[i, 1])*u+c[i, 0]; 
	         ansy2 := t*ansy2+(3.0*c[i, 3]*u+2.0*c[i, 2])*u+c[i, 1]; 
	         ansy1 := u*ansy1+(3.0*c[3, i]*t+2.0*c[2, i])*t+c[1, i]
	      END; 
	      ansy1 := ansy1/d1; 
	      ansy2 := ansy2/d2; 
	   END;
   END BCuInt; 

   PROCEDURE PolIn2(    X1A, X2A: Vector; 
                        YA:        Matrix; 
                        x1, x2:     REAL; 
                    VAR y, dy:      REAL); 
      VAR 
         k, j, mp, np, n, m, nM, mM: INTEGER; 
         YMTMP, YNTMP: Vector; 
         ymtmp, yntmp, x1a, x2a: PtrToReals; 
         ya: PtrToLines;
   BEGIN 
      GetVectorAttr(X1A, m, x1a);
      GetVectorAttr(X2A, n, x2a);
      GetMatrixAttr(YA, mM, nM, ya);
      IF (n = nM) AND (m = mM) THEN
	      CreateVector(n, YNTMP, yntmp);
	      CreateVector(m, YMTMP, ymtmp);
	      FOR j := 0 TO m-1 DO (* Loop over rows. *)
	         FOR k := 0 TO n-1 DO (* Copy the row into temporary storage. *)
	            yntmp^[k] := ya^[j]^[k]
	         END; 
	         PolInt(X2A, YNTMP, x2, ymtmp^[j], dy)(* Interpolate answer, using temporary storage. *)
	      END; 
	      PolInt(X1A, YMTMP, x1, y, dy); (* Do the final interpolation. *)
	      DisposeVector(YNTMP); 
	      DisposeVector(YMTMP)
	   ELSE
	      Error('PolIn2', 'Inproper input.');
    END;
   END PolIn2; 

   PROCEDURE Splie2(X1A, X2A: Vector; 
                    YA, Y2A:  Matrix); 
      VAR 
         k, j, nx1a, nx2a, m, n, ny2a, my2a: INTEGER; 
         ytmpV, y2tmpV: Vector; 
         ya, y2a: PtrToLines;
         ytmp, y2tmp, x1a, x2a: PtrToReals; 
   BEGIN 
      GetVectorAttr(X1A, nx1a, x1a);
      GetVectorAttr(X2A, nx2a, x2a);
      GetMatrixAttr(YA, m, n, ya);
      GetMatrixAttr(Y2A, my2a, ny2a, y2a);
      IF ((nx1a = nx2a) AND (nx2a = n) AND (m = my2a)) THEN
	      CreateVector(n, ytmpV, ytmp);
	      CreateVector(n, y2tmpV, y2tmp);
	      FOR j := 0 TO m-1 DO 
	         FOR k := 0 TO n-1 DO 
	            ytmp^[k] := ya^[j]^[k]
	         END; 
	         Spline(X2A, ytmpV, 1.0E30, 1.0E30, y2tmpV); (* Values 1imes 10^30
                                                         signal a natural spline. *)
	         FOR k := 0 TO n-1 DO 
	            y2a^[j]^[k] := y2tmp^[k]
	         END
	      END; 
	      DisposeVector(y2tmpV); 
	      DisposeVector(ytmpV);
	   ELSE
	      Error('Splie2', 'Inproper input data.');
	   END;
   END Splie2; 

   PROCEDURE Splin2(    X1A, X2A: Vector; 
                        YA, Y2A:  Matrix; 
                        x1, x2:     REAL; 
                    VAR y:          REAL); 
      VAR   
         k, j, nx1a, nx2a, m, n, ny2a, my2a: INTEGER; 
         ytmpV, y2tmpV, yytmpV: Vector; 
         ya, y2a: PtrToLines;
         ytmp, y2tmp, yytmp, x1a, x2a: PtrToReals; 
   BEGIN 
      GetVectorAttr(X1A, nx1a, x1a);
      GetVectorAttr(X2A, nx2a, x2a);
      GetMatrixAttr(YA, m, n, ya);
      GetMatrixAttr(Y2A, my2a, ny2a, y2a);
      IF ((nx1a = nx2a) AND (nx2a = n) AND (m = my2a)) THEN
	      CreateVector(n, ytmpV, ytmp);
	      CreateVector(n, y2tmpV, y2tmp);
	      CreateVector(n, yytmpV, yytmp);
	      FOR j := 0 TO m-1 DO (* Using the 1-dimensional spline evaluator Splint,
                                 perform m evaluations of row splines
                                 constructed by Splie2. *)
	         FOR k := 0 TO n-1 DO 
	            ytmp^[k] := ya^[j]^[k]; 
	            y2tmp^[k] := y2a^[j]^[k]
	         END; 
	         Splint(X2A, ytmpV, y2tmpV, x2, yytmp^[j])
	      END; 
	      Spline(X1A, yytmpV, 1.0E30, 1.0E30, y2tmpV); (* Construct the 1-dimensional 
	                                                      column spline and evaluate it. *)
	      Splint(X1A, yytmpV, y2tmpV, x1, y); 
	      DisposeVector(yytmpV); 
	      DisposeVector(y2tmpV); 
	      DisposeVector(ytmpV)
	   ELSE
	      Error('Splin2', 'Inproper input data.');
	   END;
   END Splin2; 

BEGIN
   BcucofFlag := TRUE; (* Initialization. *)
END Inter2.
