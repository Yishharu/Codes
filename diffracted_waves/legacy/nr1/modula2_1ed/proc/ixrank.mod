IMPLEMENTATION MODULE IxRank;

   FROM NRIO    IMPORT Error;
   FROM NRIVect IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector, 
                       GetIVectorAttr, NilIVector;
   FROM NRVect  IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr, 
                       NilVector;

   PROCEDURE Indexx(ARRIN: Vector; INDX: IVector); 
      VAR 
         l, j, ir, indxt, i, nIndx, nArrIn, n: INTEGER; 
         q: REAL; 
         arrin: PtrToReals;
         indx: PtrToIntegers;
   BEGIN 
      GetVectorAttr(ARRIN, n, arrin);
      GetIVectorAttr(INDX, nIndx, indx);
      FOR j := 0 TO n-1 DO (* Initialize the index array with consecutive integers. *)
         indx^[j] := j;
      END; 
      IF n = 1 THEN 
         RETURN 
      END; 
      l := (n DIV 2)+1; (* From here on, we just have Heapsort, but with
                           indirect indexing through INDX in all references to 
                           ARRIN. *)
      ir := n; 
      LOOP 
         IF l > 1 THEN 
            DEC(l, 1); 
            indxt := indx^[l-1]; 
            q := arrin^[indxt];
         ELSE 
            indxt := indx^[ir-1]; 
            q := arrin^[indxt]; 
            indx^[ir-1] := indx^[0]; 
            DEC(ir, 1); 
            IF ir = 1 THEN 
               indx^[0] := indxt; 
               EXIT 
            END
         END; 
         i := l; 
         j := l+l; 
         WHILE j <= ir DO 
            IF j < ir THEN 
               IF arrin^[indx^[j-1]] < arrin^[indx^[j]] THEN 
                  INC(j, 1)
               END
            END; 
            IF q < arrin^[indx^[j-1]] THEN 
               indx^[i-1] := indx^[j-1]; 
               i := j; 
               INC(j, j)
            ELSE 
               j := ir+1
            END
         END; 
         indx^[i-1] := indxt
      END; 
   END Indexx; 

   PROCEDURE Rank(INDX, IRANK: IVector); 
      VAR 
         j, n, nIrank: INTEGER; 
         indx, irank: PtrToIntegers;
   BEGIN 
      GetIVectorAttr(INDX, n, indx);
      GetIVectorAttr(IRANK, nIrank, irank);
      FOR j := 0 TO n-1 DO 
         irank^[indx^[j]] := j+1;
      END
   END Rank; 

   PROCEDURE Sort3(RA, RB, RC: Vector); 
      VAR 
         j, n, nI, nB, nC: INTEGER; 
         WKSP: Vector;
         IWKSP: IVector;
         wksp, ra, rb, rc: PtrToReals; 
         iwksp: PtrToIntegers; 
   BEGIN 
      GetVectorAttr(RA, n, ra);
      GetVectorAttr(RB, nB, rb);
      GetVectorAttr(RC, nC, rc);
      CreateVector(n, WKSP, wksp); 
      CreateIVector(n, IWKSP, iwksp); 
      IF ( (n = nB) AND (n = nC) AND (WKSP # NilVector) AND (IWKSP # NilIVector) ) THEN
	      Indexx(RA, IWKSP); (* Make the index table. *)
	      FOR j := 0 TO n-1 DO (* Save the array RA. *)
	         wksp^[j] := ra^[j]
	      END; 
	      FOR j := 0 TO n-1 DO (* Copy it back in rearranged order. *)
	         ra^[j] := wksp^[iwksp^[j]]
	      END; 
	      FOR j := 0 TO n-1 DO (* Ditto RB. *)
	         wksp^[j] := rb^[j]
	      END; 
	      FOR j := 0 TO n-1 DO 
	         rb^[j] := wksp^[iwksp^[j]]
	      END; 
	      FOR j := 0 TO n-1 DO (* Ditto RC. *)
	         wksp^[j] := rc^[j]
	      END; 
	      FOR j := 0 TO n-1 DO 
	         rc^[j] := wksp^[iwksp^[j]]
	      END; 
	   ELSE
	      Error('Sort3', 'Inproper input data, or not enough memory.');
	   END;
      IF (IWKSP # NilIVector) THEN DisposeIVector(IWKSP); END;
      IF (WKSP # NilVector) THEN DisposeVector(WKSP); END;
   END Sort3; 

END IxRank.
