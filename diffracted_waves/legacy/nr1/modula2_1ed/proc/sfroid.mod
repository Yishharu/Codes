MODULE SFROID;

   FROM SpherHar IMPORT PLgndr;
   FROM SolvDEM  IMPORT RealArray3Dim, SolvDE;
   FROM NRMath   IMPORT Exp, Ln;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT Error, ReadInt, ReadReal, ReadLn, WriteInt, WriteReal,
                        WriteLn, WriteString;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      ne = 3; 
      m = 41; 
      nb = 1; 
      nyj = ne; 
      nyk = m; 
      nci = ne; 
      ncj = 3; 
      nck = 42; 
      nsi = ne; 
      nsj = 7; 
   VAR 
      mm, n, i, itmax, k: INTEGER; 
      h, c2, norm, conv, deriv, fac1, fac2, q1, slowc: REAL; 
      c: RealArray3Dim; 
      SCALV, X: Vector;
      INDEXV: IVector;
      indexv: PtrToIntegers;
      scalv, x: PtrToReals;
      Y, S: Matrix;
      y, s: PtrToLines;

   PROCEDURE difeq(k, k1, k2, jsf, is1, isf: INTEGER; 
                   INDEXV: IVector;                   (*IntegerArrayNYJ; *)
                   S: Matrix;                         (*RealArrayNSIbyNSJ; *)
                   Y: Matrix);                        (* RealArrayNYJbyNYK *)
   (*
     Returns matrix s for SOLVDE for the sample program SFROID.
     The variables h, mm, n, c2, NORM, and x[1..m] are
     globally defined in SFROID.
   *)
      VAR 
         ne, ns, ny, ms, my: INTEGER;
         temp2, temp: REAL; 
         indexv: PtrToIntegers;
         s, y: PtrToLines;
   BEGIN 
      GetIVectorAttr(INDEXV, ne, indexv);
      GetMatrixAttr(S, ns, ms, s);
      GetMatrixAttr(Y, ny, my, y);
      IF k = k1 THEN (* Boundary condition at first point. *)
         IF ODD(n+mm) THEN 
            s^[2]^[2+indexv^[0]] := 1.0; (* Equation (16.4.32). *)
            s^[2]^[2+indexv^[1]] := 0.0; 
            s^[2]^[2+indexv^[2]] := 0.0; 
            s^[2]^[jsf-1] := y^[0]^[0] (* Equation (16.4.31). *)
         ELSE 
            s^[2]^[2+indexv^[0]] := 0.0; (* Equation (16.4.32). *)
            s^[2]^[2+indexv^[1]] := 1.0; 
            s^[2]^[2+indexv^[2]] := 0.0; 
            s^[2]^[jsf-1] := y^[1]^[0] (* Equation (16.4.31). *)
         END
      ELSIF k > k2 THEN (* Boundary conditions at last point. *)
         s^[0]^[2+indexv^[0]] := -(y^[2]^[m-1]-c2)/(2.0*(Float(mm)+1.0)); 
                                                         (* Equation (16.4.35). *)
         s^[0]^[2+indexv^[1]] := 1.0; 
         s^[0]^[2+indexv^[2]] := -y^[0]^[m-1]/(2.0*(Float(mm)+1.0)); 
         s^[0]^[jsf-1] := y^[1]^[m-1]-(y^[2]^[m-1]-c2)*y^[0]^[m-1]/(2.0*(Float(mm)+1.0)); (* Equation (16.4.33). *)
         s^[1]^[2+indexv^[0]] := 1.0; (* Equation (16.4.36). *)
         s^[1]^[2+indexv^[1]] := 0.0; 
         s^[1]^[2+indexv^[2]] := 0.0; 
         s^[1]^[jsf-1] := y^[0]^[m-1]-norm (* Equation (16.4.34). *)
      ELSE (* Interior point. *)
         s^[0]^[indexv^[0]-1] := -1.0; (* Equation (16.4.28). *)
         s^[0]^[indexv^[1]-1] := -0.5*h; 
         s^[0]^[indexv^[2]-1] := 0.0; 
         s^[0]^[2+indexv^[0]] := 1.0; 
         s^[0]^[2+indexv^[1]] := -0.5*h; 
         s^[0]^[2+indexv^[2]] := 0.0; 
         temp := h/(1.0-((x^[k-1]+x^[k-2])*(x^[k-1]+x^[k-2]))*0.25); 
         temp2 := 0.5*(y^[2]^[k-1]+y^[2]^[k-2])-c2*0.25*((x^[k-1]+x^[k-2])*(x^[k-1]+x^[k-2])); 
         s^[1]^[indexv^[0]-1] := temp*temp2*0.5; (* Equation (16.4.29). *)
         s^[1]^[indexv^[1]-1] := -1.0-0.5*temp*(Float(mm)+1.0)*(x^[k-1]+x^[k-2]); 
         s^[1]^[indexv^[2]-1] := 0.25*temp*(y^[0]^[k-1]+y^[0]^[k-2]); 
         s^[1]^[2+indexv^[0]] := s^[1]^[indexv^[0]-1]; 
         s^[1]^[2+indexv^[1]] := 2.0+s^[1]^[indexv^[1]-1]; 
         s^[1]^[2+indexv^[2]] := s^[1]^[indexv^[2]-1]; 
         s^[2]^[indexv^[0]-1] := 0.0; (* Equation (16.4.30). *)
         s^[2]^[indexv^[1]-1] := 0.0; 
         s^[2]^[indexv^[2]-1] := -1.0; 
         s^[2]^[2+indexv^[0]] := 0.0; 
         s^[2]^[2+indexv^[1]] := 0.0; 
         s^[2]^[2+indexv^[2]] := 1.0; 
         s^[0]^[jsf-1] := y^[0]^[k-1]-y^[0]^[k-2]-0.5*h*(y^[1]^[k-1]+y^[1]^[k-2]); (* Equation (16.4.23). *)
         s^[1]^[jsf-1] := y^[1]^[k-1]-y^[1]^[k-2]-     (* Equation (16.4.24). *)
                        temp*((x^[k-1]+x^[k-2])*0.5*(Float(mm)+1.0)*
                              (y^[1]^[k-1]+y^[1]^[k-2])-temp2*0.5*(y^[0]^[k-1]+y^[0]^[k-2]));
         s^[2]^[jsf-1] := y^[2]^[k-1]-y^[2]^[k-2]      (* Equation (16.4.27). *)
      END
   END difeq; 

BEGIN 
   CreateMatrix(nyj, nyk, Y, y);
   CreateMatrix(nsi, nsj, S, s);
   CreateVector(nyj, SCALV, scalv);
   CreateVector(m, X, x);
   CreateIVector(nyj, INDEXV, indexv);
   IF (Y # NilMatrix) AND (S # NilMatrix) AND (SCALV # NilVector) AND 
      (X # NilVector) AND (INDEXV # NilIVector) THEN
	   itmax := 100; 
	   c2 := 0.0; 
	   conv := 5.0E-6; 
	   slowc := 1.0; 
	   h := 1.0/Float(m-1); 
	   WriteString('Enter m n'); 
	   WriteLn; 
	   ReadInt('mm:', mm); 
	   ReadInt('n:', n); 
	   IF ODD(n+mm) THEN (* No interchanges necessary. *)
	      indexv^[0] := 1; 
	      indexv^[1] := 2; 
	      indexv^[2] := 3
	   ELSE (* Interchange y1 and y2. *)
	      indexv^[0] := 2; 
	      indexv^[1] := 1; 
	      indexv^[2] := 3
	   END; 
	   norm := 1.0; (* Compute mma. *)
	   IF mm <> 0 THEN 
	      q1 := Float(n); 
	      FOR i := 1 TO mm DO 
	         norm := -0.5*norm*Float(n+i)*(q1/Float(i)); 
	         q1 := q1-1.0
	      END
	   END; 
	   FOR k := 1 TO m-1 DO (* Initial guess. *)
	      x^[k-1] := Float(k-1)*h; 
	      fac1 := 1.0-(x^[k-1]*x^[k-1]); 
	      fac2 := Exp((Float(-mm)/2.0)*Ln(fac1)); 
	      y^[0]^[k-1] := PLgndr(n, mm, x^[k-1])*fac2; (* Pn^m from section 6.6. *)
	      deriv := -(Float(n-mm+1)*PLgndr(n+1, mm, x^[k-1])-Float(n+1)*x^[k-1]*PLgndr(n, mm, x^[k-1]))/fac1; (* Derivative of Pn^m from
                                                                                                             a recurrence relation. *)
	      y^[1]^[k-1] := Float(mm)*x^[k-1]*y^[0]^[k-1]/fac1+deriv*fac2; 
	      y^[2]^[k-1] := Float(n*(n+1)-mm*(mm+1));
	   END; 
	   x^[m-1] := 1.0; (* Initial guess at x=1 done separately. *)
	   y^[0]^[m-1] := norm; 
	   y^[2]^[m-1] := Float(n*(n+1)-mm*(mm+1)); 
	   y^[1]^[m-1] := (y^[2]^[m-1]-c2)*y^[0]^[m-1]/(2.0*(Float(mm)+1.0)); 
	   scalv^[0] := ABS(norm); 
	   IF y^[1]^[m-1] > ABS(norm) THEN 
	      scalv^[1] := y^[1]^[m-1]
	   ELSE 
	      scalv^[1] := ABS(norm)
	   END; 
	   IF y^[2]^[m-1] > 1.0 THEN 
	      scalv^[2] := y^[2]^[m-1]
	   ELSE 
	      scalv^[2] := 1.0
	   END; 
	   LOOP 
	      WriteString('Enter c**2 or 999 to end.'); 
	      ReadReal('c2:', c2); 
	      IF c2 = Float(999) THEN EXIT END; 
	      SolvDE(itmax, conv, slowc, SCALV, INDEXV, nb, m, Y, c, S, difeq); 
	      WriteLn; 
	      WriteString('m = '); 
	      WriteInt(mm, 2); 
	      WriteString(' n = '); 
	      WriteInt(n, 2); 
	      WriteString(' c**2 = '); 
	      WriteReal(c2, 7, 3); 
	      WriteString(' lam = '); 
	      WriteReal(y^[2]^[0]+Float(mm*(mm+1)), 10, 6); 
	      WriteLn; 
	      ReadLn;
	   END; (* Return for another value of c^2. *)
	ELSE
	   Error('SFROID', 'Not enough memory.');
	END;
	IF Y # NilMatrix THEN DisposeMatrix(Y); END;
	IF S # NilMatrix THEN DisposeMatrix(S); END;
	IF SCALV # NilVector THEN DisposeVector(SCALV); END;
	IF X # NilVector THEN DisposeVector(X); END;
	IF INDEXV # NilIVector THEN DisposeIVector(INDEXV); END;
END SFROID.
