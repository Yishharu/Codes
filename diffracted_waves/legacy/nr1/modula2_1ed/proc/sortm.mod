IMPLEMENTATION MODULE SortM;

   FROM NRIO IMPORT Error;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, EmptyVector, GetVectorAttr;

   PROCEDURE Sort(RA: Vector); 
      VAR 
         l, j, ir, i, n: INTEGER; (* The index l will be decremented from its initial
                                     value down to 1 during the "hiring" (heap creation) phase.  
                                     Once it reaches 1, the index ir will be decremented from its 
                                     initial value down to 1 during the "retirement-and-promotion" 
                                     (heap selection) phase. *)
         rra: REAL; 
         ra: PtrToReals;
   BEGIN 
      GetVectorAttr(RA, n, ra); (* indices *)
      l := (n DIV 2)+1; 
      ir := n; 
      LOOP 
         IF l > 1 THEN (* Still in hiring phase. *)
            DEC(l, 1); 
            rra := ra^[l-1]
         ELSE (* In retirement-and-promotion phase. *)
            rra := ra^[ir-1]; (* Clear a space at end of array. *)
            ra^[ir-1] := ra^[0]; (* Retire the top of the heap into it. *)
            DEC(ir, 1); (* Decrease the size of the corporation. *)
            IF ir = 1 THEN 
			   (*
			     Done with the last promotion.
			   *)
               ra^[0] := rra; (* The least competent worker
                                 of all! *)
               RETURN;
            END
         END; 
		   (*
		     Whether we are in the hiring phase or promotion
		     phase, we here set up to sift down element rra to its proper level.
		   *)
         i := l; 
         j := l+l; 
         WHILE j <= ir DO 
            IF j < ir THEN 
               IF ra^[j-1] < ra^[j] THEN (* Compare to the better underling. *)
                  INC(j, 1)
               END
            END; 
            IF rra < ra^[j-1] THEN (* Demote rra. *)
               ra^[i-1] := ra^[j-1]; 
               i := j; 
               INC(j, j)
            ELSE (* This is rra's level. Set J to terminate the sift-down. *)
               j := ir+1
            END
         END; 
         ra^[i-1] := rra (* Put rra into its slot. *)
      END; 
   END Sort; 

   PROCEDURE Sort2(RA, RB: Vector); 
      VAR 
         l, j, ir, i, n, nB: INTEGER; 
         rrb, rra: REAL; 
         ra, rb: PtrToReals;
   BEGIN 
      GetVectorAttr(RA, n, ra); (* indices *)
      GetVectorAttr(RB, nB, rb); 
      IF n = nB THEN
	      l := (n DIV 2)+1; 
	      ir := n; 
	      LOOP 
	         IF l > 1 THEN 
	            DEC(l, 1); 
	            rra := ra^[l-1]; 
	            rrb := rb^[l-1]
	         ELSE 
	            rra := ra^[ir-1]; 
	            rrb := rb^[ir-1]; 
	            ra^[ir-1] := ra^[0]; 
	            rb^[ir-1] := rb^[0]; 
	            DEC(ir, 1); 
	            IF ir = 1 THEN 
	               ra^[0] := rra; 
	               rb^[0] := rrb; 
	               RETURN;
	            END
	         END; 
	         i := l; 
	         j := l+l; 
	         WHILE j <= ir DO 
	            IF j < ir THEN 
	               IF ra^[j-1] < ra^[j] THEN 
	                  INC(j, 1)
	               END
	            END; 
	            IF rra < ra^[j-1] THEN 
	               ra^[i-1] := ra^[j-1]; 
	               rb^[i-1] := rb^[j-1]; 
	               i := j; 
	               INC(j, j)
	            ELSE 
	               j := ir+1
	            END
	         END; 
	         ra^[i-1] := rra; 
	         rb^[i-1] := rrb
	      END; 
      ELSE
         Error('Sort2', 'Incompatible input vectors.');
      END;
   END Sort2; 

END SortM.
