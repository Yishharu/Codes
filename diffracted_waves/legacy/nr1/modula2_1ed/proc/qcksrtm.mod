IMPLEMENTATION MODULE QckSrtM;

   FROM NRIO   IMPORT Error;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr, 
                      NilVector;

   PROCEDURE QckSrt(ARR: Vector); 
      CONST 
         m = 7; 
         nstack = 50; 
      VAR 
         i, j, k, l, ir, jstack, n: INTEGER; 
         a, temp: REAL; 
         arr: PtrToReals;
         istack: ARRAY [1..nstack] OF INTEGER; (* Here m is the size of subarrays sorted by straight insertion and
                                                  istack is the required auxiliary storage. *)
   BEGIN 
      GetVectorAttr(ARR, n, arr);
      jstack := 0; 
      l := 1; 
      ir := n; 
      LOOP 
         IF ir-l < m THEN (* Insertion sort when subarray small enough. *)
            FOR j := l+1 TO ir DO 
               a := arr^[j-1]; 
               LOOP
	               FOR i := j-1 TO 1 BY -1 DO 
	                  IF arr^[i-1] <= a THEN 
	                     EXIT; 
	                  END; 
	                  arr^[i] := arr^[i-1]
	               END; 
	               i := 0; 
	               EXIT;
	            END;
               arr^[i] := a
            END; 
            IF jstack = 0 THEN 
               RETURN 
            END; 
            ir := istack[jstack]; (* Pop stack and begin a new round of partitioning. *)
            l := istack[jstack-1]; 
            DEC(jstack, 2)
         ELSE 
            k := (l+ir) DIV 2; (* Choose median of left, center and right elements as partitioning element
                                  a. Also rearrange so that *)
            temp := arr^[k-1]; 
            arr^[k-1] := arr^[l]; (* a[l+1]leqa[l],
                                     a[ir]=a[l]. *)
            arr^[l] := temp; 
            IF arr^[l] > arr^[ir-1] THEN 
               temp := arr^[l]; 
               arr^[l] := arr^[ir-1]; 
               arr^[ir-1] := temp
            END; 
            IF arr^[l-1] > arr^[ir-1] THEN 
               temp := arr^[l-1]; 
               arr^[l-1] := arr^[ir-1]; 
               arr^[ir-1] := temp
            END; 
            IF arr^[l] > arr^[l-1] THEN 
               temp := arr^[l]; 
               arr^[l] := arr^[l-1]; 
               arr^[l-1] := temp
            END; 
            i := l+1; (* Initialize pointers for partitioning. *)
            j := ir; 
            a := arr^[l-1]; (* Partitioning element. *)
            LOOP (* Beginning of innermost loop. *)
               REPEAT (* Scan up to find element >a. *)
                  INC(i, 1); 
               UNTIL arr^[i-1] >= a; 
               REPEAT (* Scan down to find element <a. *)
                  DEC(j, 1); 
               UNTIL arr^[j-1] <= a; 
               IF j < i THEN (* Pointers crossed. Exit with partitioning complete. *)
                  EXIT 
               END; 
               temp := arr^[i-1]; (* Exchange elements. *)
               arr^[i-1] := arr^[j-1]; 
               arr^[j-1] := temp
            END; (* End of innermost loop. *)
            arr^[l-1] := arr^[j-1]; (* Insert partitioning element. *)
            arr^[j-1] := a; 
            INC(jstack, 2); (* Push pointers to larger subarray on stack, process smaller subarray
                               immediately. *)
            IF jstack > nstack THEN 
               Error('QckSrt', 'nstack must be made larger'); 
            END; 
            IF ir-i+1 >= j-l THEN 
               istack[jstack] := ir; 
               istack[jstack-1] := i; 
               ir := j-1
            ELSE 
               istack[jstack] := j-1; 
               istack[jstack-1] := l; 
               l := i
            END
         END
      END; 
   END QckSrt; 

END QckSrtM.
