IMPLEMENTATION MODULE EClasses;

   FROM NRIO    IMPORT Error;
   FROM NRIVect IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector, 
                GetIVectorAttr, NilIVector;

   PROCEDURE EClass(NF, LISTA, LISTB: IVector); 
      VAR 
         l, k, j, n, m, mb: INTEGER; 
         nf, lista, listb: PtrToIntegers; 
   BEGIN 
      GetIVectorAttr(NF, n, nf);
      GetIVectorAttr(LISTA, m, lista);
      GetIVectorAttr(LISTB, mb, listb);
      IF (m = mb) THEN 
	      FOR k := 0 TO n-1 DO 
		   (*
		     Initialize each element in its own class.
		   *)
	         nf^[k] := k+1;
	      END; 
	      FOR l := 0 TO m-1 DO (* For each piece of input information... *)
	         j := lista^[l]; 
	         WHILE nf^[j-1] <> j DO (* Track first element up
                                    to its ancestor. *)
	            j := nf^[j-1]
	         END; 
	         k := listb^[l]; 
	         WHILE nf^[k-1] <> k DO (* Track second element up
                                    to its ancestor. *)
	            k := nf^[k-1]
	         END; 
	         IF j <> k THEN (* If they are not already
                            related, make them so. *)
	            nf^[j-1] := k
	         END
	      END; 
	      FOR j := 0 TO n-1 DO (* Final sweep up to highest ancestors. *)
	         WHILE nf^[j] <> nf^[nf^[j]-1] DO 
	            nf^[j] := nf^[nf^[j]-1]
	         END
	      END; 
	   ELSE
	      Error('EClass', 'Inproper input vectors.');
	   END;
   END EClass; 

   PROCEDURE EClazz(NF:    IVector;
                    equiv: EquivFunction); 
      VAR 
         kk, jj, n: INTEGER; 
         nf: PtrToIntegers;
   BEGIN 
      GetIVectorAttr(NF, n, nf);
      nf^[0] := 1; 
      FOR jj := 1 TO n-1 DO (* Loop over first element of all pairs. *)
         nf^[jj] := jj+1; 
         FOR kk := 0 TO jj-1 DO 
		   (*
		     Loop over second element of all pairs.
		   *)
            nf^[kk] := nf^[nf^[kk]-1]; (* Sweep
                                          it up this much. *)
            IF equiv(jj, kk) THEN 
			   (*
			     Good exercise for the reader to
			     figure out why this much ancestry is necessary!
			   *)
               nf^[nf^[nf^[kk]-1]-1] := jj+1;
            END
         END
      END; 
      FOR jj := 0 TO n-1 DO (* Only this much sweeping is needed finally. *)
         nf^[jj] := nf^[nf^[jj]-1]
      END
   END EClazz; 

END EClasses.
