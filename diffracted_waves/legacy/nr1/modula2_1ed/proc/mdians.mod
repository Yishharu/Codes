IMPLEMENTATION MODULE Mdians;

   FROM SortM  IMPORT Sort;
   FROM NRIO   IMPORT Error;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   PROCEDURE Mdian1(    X: Vector; 
                    VAR xmed: REAL); 
      VAR 
         n, n2: INTEGER; 
         x: PtrToReals;
   BEGIN 
      GetVectorAttr(X, n, x);
      Sort(X); 
	   (*
	     This routine is in section8.2.
	   *)
      n2 := n DIV 2; 
      IF ODD(n) THEN 
         xmed := x^[n2]
      ELSE 
         xmed := 0.5*(x^[n2-1]+x^[n2])
      END
   END Mdian1; 

   PROCEDURE Mdian2(    X: Vector; 
                    VAR xmed: REAL); 
      CONST 
         big = 1.0E30; (* Here, amp is an overconvergence factor: on each iteration,
                          we move the guess by this factor more than (13.2.4) would naively
                          indicate.  afac is a factor used to optimize the size of the
                          "smoothing constant" eps at each iteration. *)
         afac = 1.5; 
         amp = 1.5; 
      VAR 
         np, nm, j, n: INTEGER; 
         xx, xp, xm, sumx, sum, eps: REAL; 
         stemp, dum, ap, am, aa, a: REAL; 
         x: PtrToReals;
   BEGIN 
      GetVectorAttr(X, n, x);
      a := 0.5*(x^[0]+x^[n-1]); (* This can be any first guess for
                                   the median. *)
      eps := ABS(x^[n-1]-x^[0]); (* This can be any first guess for
                                    the characteristic spacing of the data points near the median. *)
      ap := big; 
      am := -big; (* ap and am are upper and lower bounds
                     on the median. *)
      LOOP 
         sum := 0.0; (* Here we start one pass through the data. *)
         sumx := 0.0; 
         np := 0; (* Number of points above the current guess, and below it. *)
         nm := 0; 
         xp := big; (* Value of the point above and closest to the guess, and below and closest. *)
         xm := -big; 
         FOR j := 1 TO n DO (* Go through the points, *)
            xx := x^[j-1]; 
            IF xx <> a THEN (* omit a zero denominator in the sums, *)
               IF xx > a THEN (* and update the diagnostics. *)
                  INC(np, 1); 
                  IF xx < xp THEN 
              xp := xx
                  END
               ELSIF xx < a THEN 
                  INC(nm, 1); 
                  IF xx > xm THEN 
                     xm := xx
                  END
               END; 
               dum := 1.0/(eps+ABS(xx-a)); (* The smoothing constant is used here. *)
               sum := sum+dum; (* Accumulate the sums. *)
               sumx := sumx+xx*dum
            END
         END; 
         stemp := (sumx/sum)-a; 
         IF np-nm >= 2 THEN (* Guess is too low; make another pass, *)
            am := a; (* with a new lower bound, *)
            IF stemp < 0.0 THEN 
               aa := xp (* a new best guess *)
            ELSE 
               aa := xp+stemp*amp
            END; 
            IF aa > ap THEN 
               aa := 0.5*(a+ap) (* (but no larger than the upper bound) *)
            END; 
            eps := afac*ABS(aa-a); (* If they are not already
                                      related, make them so. *)
            a := aa
         ELSIF nm-np >= 2 THEN (* Guess is too high; make another pass, *)
            ap := a; (* with a new upper bound, *)
            IF stemp > 0.0 THEN 
               aa := xm (* a new best guess *)
            ELSE 
               aa := xm+stemp*amp
            END; 
            IF aa < am THEN 
               aa := 0.5*(a+am) (* (but no smaller than the lower bound) *)
            END; 
            eps := afac*ABS(aa-a); (* and a new smoothing factor. *)
            a := aa
         ELSE (* Got it! *)
            IF ODD(n) THEN (* For odd n median is always one point. *)
               IF np = nm THEN 
                  xmed := a
               ELSIF np > nm THEN 
                  xmed := xp
               ELSE 
                  xmed := xm
               END
            ELSE (* For even n median is always an average. *)
               IF np = nm THEN 
                  xmed := 0.5*(xp+xm)
               ELSIF np > nm THEN 
                  xmed := 0.5*(a+xp)
               ELSE 
                  xmed := 0.5*(xm+a)
               END
            END; 
            EXIT; 
         END
      END; 
   END Mdian2; 

END Mdians.
