IMPLEMENTATION MODULE EulSumM;

   FROM NRIO   IMPORT Error;
   FROM NRVect IMPORT Vector, PtrToReals, GetVectorAttr;

   VAR EulsumNterm: INTEGER;

   PROCEDURE EulSum(VAR sum:   REAL; 
                        term:  REAL; 
                        jterm: INTEGER;
                        WKSP:  Vector); 
      VAR 
         j, n: INTEGER; 
         tmp, dum: REAL; 
         wksp: PtrToReals;
   BEGIN 
      GetVectorAttr(WKSP, n, wksp);
      IF jterm = 0 THEN (* Initialize: *)
         EulsumNterm := 0; (* Number of saved differences in 
                              array EulsumWksp. *)
         wksp^[0] := term; 
         sum := 0.5*term(* Return first estimate. *)
      ELSE 
         tmp := wksp^[0]; 
         wksp^[0] := term; 
         FOR j := 0 TO EulsumNterm-1 DO (* Use van Wijn-gaarden's algorithm
                                           to update saved quantities. *)
            dum := wksp^[j+1]; 
            wksp^[j+1] := 0.5*(wksp^[j]+tmp); 
            tmp := dum
         END; 
         wksp^[EulsumNterm+1] := 0.5*(wksp^[EulsumNterm]+tmp); 
         IF ABS(wksp^[EulsumNterm+1]) <= ABS(wksp^[EulsumNterm]) THEN (* Favorable to increase p, *)
            sum := sum+0.5*wksp^[EulsumNterm+1]; 
            EulsumNterm := EulsumNterm+1(* and the table becomes longer. *)
         ELSE 
            sum := sum(* Favorable to increase n, and the table doesn't become longer. *)
            +wksp^[EulsumNterm+1]
         END
      END;
   END EulSum; 

END EulSumM.
