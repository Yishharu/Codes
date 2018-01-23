IMPLEMENTATION MODULE CnTabs;

   FROM IncGamma IMPORT GammQ;
   FROM NRMath   IMPORT Sqrt, Ln;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRIMatr  IMPORT IMatrix, CreateIMatrix, DisposeIMatrix, GetIMatrixAttr,  
                        NilIMatrix, PtrToILines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE CnTab1(    NN: IMatrix;
                    VAR chisq, df, prob: REAL; 
                    VAR cramrv, ccc: REAL); 
      CONST 
         tiny = 1.0E-30; 
      VAR 
         ni, nj, nnj, nni, j, i, min: INTEGER; 
         sum, expctd: REAL; 
         nn: PtrToILines;
         SUMI, SUMJ: Vector;
         sumi, sumj: PtrToReals; 
   BEGIN 
      GetIMatrixAttr(NN, ni, nj, nn);
      CreateVector(ni, SUMI, sumi);
      CreateVector(nj, SUMJ, sumj);
      IF (SUMI # NilVector) AND (SUMJ # NilVector) THEN
	      sum := 0.0; (* Will be total number of events. *)
	      nni := ni; (* Number of rows *)
	      nnj := nj; (* and columns. *)
	      FOR i := 0 TO ni-1 DO (* Get the row totals. *)
	         sumi^[i] := 0.0; 
	         FOR j := 0 TO nj-1 DO 
	            sumi^[i] := sumi^[i]+Float(nn^[i]^[j]); 
	            sum := sum+Float(nn^[i]^[j]); 
	         END; 
	         IF sumi^[i] = 0.0 THEN DEC(nni) END; (* Eliminate any zero rows by 
	                                                 reducing the number. *)
	      END; 
	      FOR j := 0 TO nj-1 DO (* Get the column totals. *)
	         sumj^[j] := 0.0; 
	         FOR i := 0 TO ni-1 DO 
	            sumj^[j] := sumj^[j]+Float(nn^[i]^[j])
	         END; 
	         IF sumj^[j] = 0.0 THEN DEC(nnj) END; (* Eliminate any zero columns. *)
	      END; 
	      df := Float(nni*nnj-nni-nnj+1); (* Corrected number of degrees
                                          of freedom. *)
	      chisq := 0.0; 
	      FOR i := 0 TO ni-1 DO (* Do the chi-square sum. *)
	         FOR j := 0 TO nj-1 DO 
	            expctd := sumj^[j]*sumi^[i]/sum; 
	            chisq := chisq+((Float(nn^[i]^[j])-expctd)*
	                             (Float(nn^[i]^[j])-expctd))/(expctd+tiny)
				   (*
				     Here tiny guarantees that any eliminated row or column
				     will not contribute to the sum.
				   *)
	         END
	      END; 
	      prob := GammQ(0.5*df, 0.5*chisq); (* Chi-square probability
                                            function. *)
	      IF nni-1 < nnj-1 THEN 
	         min := nni-1
	      ELSE 
	         min := nnj-1
	      END; 
	      cramrv := Sqrt(chisq/(sum*Float(min))); 
	      ccc := Sqrt(chisq/(chisq+sum)); 
      ELSE
         Error('CnTab1', 'Not enough memory.');
      END;
      IF SUMI # NilVector THEN DisposeVector(SUMI) END; 
      IF SUMJ # NilVector THEN DisposeVector(SUMJ) END; 
   END CnTab1; 

   PROCEDURE CnTab2(    NN: IMatrix; 
                    VAR h, hx, hy, hygx, hxgy: REAL; 
                    VAR uygx, uxgy, uxy: REAL); 
      CONST 
         tiny = 1.0E-30; 
      VAR 
         j, i, ni, nj: INTEGER; 
         sum, p: REAL; 
         nn: PtrToILines;
         SUMI, SUMJ: Vector;
         sumi, sumj: PtrToReals; 
   BEGIN 
      GetIMatrixAttr(NN, ni, nj, nn);
      CreateVector(ni, SUMI, sumi);
      CreateVector(nj, SUMJ, sumj);
      IF (SUMI # NilVector) AND (SUMJ # NilVector) THEN
	      sum := 0.0; 
	      FOR i := 0 TO ni-1 DO (* Get the row totals. *)
	         sumi^[i] := 0.0; 
	         FOR j := 0 TO nj-1 DO 
	            sumi^[i] := sumi^[i]+Float(nn^[i]^[j]); 
	            sum := sum+Float(nn^[i]^[j])
	         END
	      END; 
	      FOR j := 0 TO nj-1 DO (* Get the column totals. *)
	         sumj^[j] := 0.0; 
	         FOR i := 0 TO ni-1 DO 
	            sumj^[j] := sumj^[j]+Float(nn^[i]^[j])
	         END
	      END; 
	      hx := 0.0; (* Entropy of the x distribution, *)
	      FOR i := 0 TO ni-1 DO 
	         IF sumi^[i] <> 0.0 THEN 
	            p := sumi^[i]/sum; 
	            hx := hx-p*Ln(p)
	         END
	      END; 
	      hy := 0.0; (* and of the y distribution. *)
	      FOR j := 0 TO nj-1 DO 
	         IF sumj^[j] <> 0.0 THEN 
	            p := sumj^[j]/sum; 
	            hy := hy-p*Ln(p)
	         END
	      END; 
	      h := 0.0; 
	      FOR i := 0 TO ni-1 DO (* Total entropy: loop over both x *)
	         FOR j := 0 TO nj-1 DO (* and y. *)
	            IF nn^[i]^[j] <> 0 THEN 
	               p := Float(nn^[i]^[j])/sum; 
	               h := h-p*Ln(p)
	            END
	         END
	      END; 
	      hygx := h-hx; (* Uses equation (13.6.18), *)
	      hxgy := h-hy; (* as does this. *)
	      uygx := (hy-hygx)/(hy+tiny); (* Equation (13.6.15). *)
	      uxgy := (hx-hxgy)/(hx+tiny); (* Equation (13.6.16). *)
	      uxy := 2.0*(hx+hy-h)/(hx+hy+tiny); (* Equation (13.6.17). *)
      ELSE
         Error('CnTab1', 'Not enough memory.');
      END;
      IF SUMI # NilVector THEN DisposeVector(SUMI) END; 
      IF SUMJ # NilVector THEN DisposeVector(SUMJ) END; 
   END CnTab2; 

END CnTabs.
