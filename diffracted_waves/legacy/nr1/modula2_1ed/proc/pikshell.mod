IMPLEMENTATION MODULE PikShell;

   FROM NRMath   IMPORT Ln;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, PtrToReals, GetVectorAttr;

   PROCEDURE PikSr2(ARR, BRR: Vector); 
      VAR 
         j, i, n, nB: INTEGER; 
         b, a: REAL; 
         arr, brr: PtrToReals;
   BEGIN 
      GetVectorAttr(ARR, n, arr);
      GetVectorAttr(BRR, nB, brr);
      IF n = nB THEN
	      FOR j := 1 TO n-1 DO (* Pick out each element in turn. *)
	         a := arr^[j]; 
	         b := brr^[j]; 
	         i := j-1;
	         WHILE ((i >= 0) AND (arr^[i] > a))  DO 
				   (*
				     Look for the place to insert it.
				   *)
	            arr^[i+1] := arr^[i]; 
	            brr^[i+1] := brr^[i];
	            DEC(i);
	         END; 
            arr^[i+1] := a; (* Insert it. *)
	         brr^[i+1] := b
	      END
      ELSE
         Error('PikSr2', 'Incompatible input vectors.'); 
      END;
   END PikSr2; 


   PROCEDURE PikSrt(ARR: Vector); 
      VAR 
         j, i, n: INTEGER; 
         a: REAL; 
         arr: PtrToReals;
   BEGIN 
      GetVectorAttr(ARR, n, arr);
      FOR j := 1 TO n-1 DO (* Pick out each element in turn. *)
         a := arr^[j]; 
         i := j-1;
         WHILE ((i >= 0) AND (arr^[i] > a)) DO
		   (*
		     Look for the place to insert it.
		   *)
            arr^[i+1] := arr^[i];
            DEC(i);
         END;
         arr^[i+1] := a;(* Insert it. *)
      END;
   END PikSrt; 

   PROCEDURE Shell(ARR: Vector); 
      CONST 
         aln2i = 1.442695022; 
         tiny = 1.0E-5; 
      VAR 
         nn, m, lognb2, l, k, j, i, n: INTEGER; 
         t: REAL; 
         arr: PtrToReals;
   BEGIN 
      GetVectorAttr(ARR, n, arr);
      lognb2 := Trunc(Ln(Float(n))*aln2i+tiny); 
      m := n; 
      FOR nn := 1 TO lognb2 DO 
	   (*
	     Loop over the partial sorts.
	   *)
         m := m DIV 2; 
         k := n-m; 
         FOR j := 0 TO k-1 DO (* Outer loop of straight insertion. *)
            i := j; 
            LOOP
	            l := i+m; (* Inner loop of straight insertion. *)
	            IF arr^[l] < arr^[i] THEN 
	               t := arr^[i]; 
	               arr^[i] := arr^[l]; 
	               arr^[l] := t; 
	               i := i-m; 
	               IF i < 0 THEN 
	                  EXIT;
	               END;
	            ELSE
	               EXIT;
	            END;
	         END;
         END;
      END;
   END Shell; 

END PikShell.
