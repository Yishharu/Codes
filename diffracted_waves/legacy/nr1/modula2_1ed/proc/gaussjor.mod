IMPLEMENTATION MODULE GaussJor;

   FROM NRIO    IMPORT Error;
   FROM NRMatr  IMPORT Matrix, GetMatrixAttr, PtrToLines;
   FROM NRIVect IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector,
                GetIVectorAttr;

   PROCEDURE GaussJ(VAR A: Matrix; n: INTEGER; VAR B: Matrix; m: INTEGER);
      VAR
         big, dum, pivinv: REAL;
         i, icol, irow, j, k, l, ll, nA, mA, nB, mB, length: INTEGER;
         a, b: PtrToLines;
         INDXC, INDXR, IPIV: IVector;
         indxc, indxr, ipiv: PtrToIntegers;
		   (*
		     The integer vectors IPIV, INDXR,
		     and INDXC are used for bookkeeping on the pivoting.
		   *)
   BEGIN
      GetMatrixAttr(A, nA, mA, a);
      GetMatrixAttr(B, nB, mB, b);
      IF (nA = mA) AND (nA = nB) THEN
	      CreateIVector(n, IPIV, ipiv);
	      CreateIVector(n, INDXC, indxc);
	      CreateIVector(n, INDXR, indxr);
	      FOR j := 0 TO n-1 DO
	         ipiv^[j] := 0
	      END;
	      FOR i := 0 TO n-1 DO (* This is the main loop over the columns to be
                               reduced. *)
	         big := 0.0;
	         FOR j := 0 TO n-1 DO (* This is the outer loop of the search for a
                                    pivot element. *)
	            IF ipiv^[j] <> 1 THEN 
	               FOR k := 0 TO n-1 DO 
	                  IF ipiv^[k] = 0 THEN 
	                     IF ABS(a^[j]^[k]) >= big THEN 
	                        big := ABS(a^[j]^[k]); 
	                        irow := j; 
	                        icol := k
	                     ELSIF ipiv^[k] > 1 THEN 
	                        Error('GAUSSJ', 'singular matrix'); 
	                     END
	                  END
	               END
	            END
	         END; 
	         ipiv^[icol] := ipiv^[icol]+1; 
			   (*
			     We now have the pivot element, so we interchange rows, if needed, 
			     to put the pivot element on the diagonal.
			     The columns are not physically interchanged, only relabeled: 
			     indx[i], the column of the ith pivot element, is the ith column 
			     that is reduced, while indxr[i] is the row in which that 
			     pivot element was originally located.  If indxr[i]#indxc[i] 
			     there is an implied column interchange.  With this form of 
			     bookkeeping, the solution b's will end up in the correct order, 
			     and the inverse matrix will be scrambled by columns.
			   *)
	         IF irow <> icol THEN 
	            FOR l := 0 TO n-1 DO 
	               dum := a^[irow]^[l]; 
	               a^[irow]^[l] := a^[icol]^[l]; 
	               a^[icol]^[l] := dum
	            END; 
	            FOR l := 0 TO m-1 DO 
	               dum := b^[irow]^[l]; 
	               b^[irow]^[l] := b^[icol]^[l]; 
	               b^[icol]^[l] := dum
	            END
	         END; 
	         indxr^[i] := irow; (* We are now ready to divide the pivot
                                  row by the pivot element, located at 
                                  irow and icol. *)
	         indxc^[i] := icol; 
	         IF a^[icol]^[icol] = 0.0 THEN 
	            Error('GAUSSJ', 'singular matrix'); 
	         END; 
	         pivinv := 1.0/a^[icol]^[icol]; 
	         a^[icol]^[icol] := 1.0; 
	         FOR l := 0 TO n-1 DO 
	            a^[icol]^[l] := a^[icol]^[l]*pivinv
	         END; 
	         FOR l := 0 TO m-1 DO 
	            b^[icol]^[l] := b^[icol]^[l]*pivinv
	         END; 
	         FOR ll := 0 TO n-1 DO (* Next, we reduce the rows... *)
	            IF ll <> icol THEN (* ...except for the
                                   pivot one, of course. *)
	               dum := a^[ll]^[icol]; 
	               a^[ll]^[icol] := 0.0; 
	               FOR l := 0 TO n-1 DO 
	                  a^[ll]^[l] := a^[ll]^[l]-a^[icol]^[l]*dum
	               END; 
	               FOR l := 0 TO m-1 DO 
	                  b^[ll]^[l] := b^[ll]^[l]-b^[icol]^[l]*dum
	               END
	            END
	         END; 
	      END; 
		   (*
		     This is the end of the main loop over columns
		     of the reduction. It only remains to unscramble the solution
		     in view of the column interchanges. We do this by interchanging pairs of
		     columns in the reverse order that the permutation was built up.
		   *)
	      FOR l := n-1 TO 0 BY -1 DO 
	         IF indxr^[l] <> indxc^[l] THEN 
	            FOR k := 0 TO n-1 DO 
	               dum := a^[k]^[indxr^[l]]; 
	               a^[k]^[indxr^[l]] := a^[k]^[indxc^[l]]; 
	               a^[k]^[indxc^[l]] := dum
	            END
	         END
	      END; 
	      DisposeIVector(IPIV); 
	      DisposeIVector(INDXR); 
	      DisposeIVector(INDXC); 
	   ELSE
	      Error('GaussJ', 'Inproper matrices!');
      END;
   END GaussJ; (* And we are done. *)

END GaussJor.
