IMPLEMENTATION MODULE AnnealM;

   FROM Uniform  IMPORT Ran3;
   FROM RBits    IMPORT IRBit1;
   FROM NRMath   IMPORT Sqrt, Exp;
   FROM NRSystem IMPORT Trunc, Float;
   FROM NRIO     IMPORT WriteString, WriteLn, WriteInt, WriteReal;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;
   VAR
      MetropJdum: INTEGER;

   PROCEDURE Anneal(X, Y:  Vector; IORDER: IVector); 
      CONST 
         tfactr = 0.9; 
		   (*
		     Annealing schedule -- T is reduced by this factor on each step.
		   *)
      TYPE 
         IntegerArray6 = ARRAY [0..5] OF INTEGER; 
      VAR 
         ans: BOOLEAN; 
         path, de, t: REAL; 
         nover, nlimit, i1, i2, idum, nCity, nY, nIORDER: INTEGER; 
         i, j, k, nsucc, nn: INTEGER; 
         iseed, idec: BITSET;
         n: IntegerArray6; 
         x, y: PtrToReals;
         iorder: PtrToIntegers;

      PROCEDURE alen(x1, x2, y1, y2: REAL): REAL; 
      BEGIN 
         RETURN Sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1))); 
      END alen; 

      PROCEDURE revcst(    X, Y: Vector; 
                           IORDER: IVector; 
                       VAR n: IntegerArray6; 
                       VAR de: REAL); 
	   (*
	     This function returns the value of the cost function for a
	     proposed path reversal.  NCITY is the number of cities, and arrays
	     X[NCITY], Y[NCITY] give the coordinates of these cities.
	     IORDER[NCITY] holds the present itinerary. The first two values n[01] 
	     and n[1] of array n give the starting and ending cities along the path 
	     segment which is to be reversed.  On output, de is the cost of making 
	     the reversal. The actual reversal is not performed by this routine.
	   *)
         VAR 
            xx, yy: ARRAY [0..5] OF REAL; 
            j, ii, nCity, nY, nIORDER: INTEGER; 
            x, y: PtrToReals;
            iorder: PtrToIntegers;
      BEGIN 
         GetVectorAttr(X, nCity, x);
         GetVectorAttr(Y, nY, y);
         GetIVectorAttr(IORDER, nIORDER, iorder);
         n[2] := 1+((n[0]+nCity-2) MOD nCity); 
		   (*
		     Find the city before n[0] ..
		   *)
         n[3] := 1+(n[1] MOD nCity); (* .. and the city after n[2] *)
         FOR j := 1 TO 4 DO 
            ii := iorder^[n[j-1]-1]; (* Find coordinates for the four
                                        cities involved. *)
            xx[j-1] := x^[ii-1]; 
            yy[j-1] := y^[ii-1]
         END; 
		   (*
		     Calculate cost of disconnecting the segment at both ends  and 
		     reconnecting in the opposite order.
		   *)
         de := -alen(xx[0], xx[2], yy[0], yy[2])
               -alen(xx[1], xx[3], yy[1], yy[3])
               +alen(xx[0], xx[3], yy[0], yy[3])
               +alen(xx[1], xx[2], yy[1], yy[2])
      END revcst; 

      PROCEDURE reverse(    IORDER: IVector; 
                        VAR n: IntegerArray6); 
	   (*
	     This routine performs a path segment reversal.  IORDER[NCITY] is an 
	     input array giving the present itinerary.  The vector n has as its first 
	     four elements the first and last cities n[0],n[1] of the path segment to 
	     be reversed, and the two cities n[2] and n[3] which immediately 
	     precede and follow this segment.  n[2] and n[3] are found
	     by function REVCST.  On output, IORDER contains the segment from 
	     n[0] to n[1] in reversed order.
	   *)
         VAR 
            nn, j, k, l, itmp, nCity: INTEGER; 
            iorder: PtrToIntegers;
      BEGIN 
         GetIVectorAttr(IORDER, nCity, iorder);
         nn := (1+((n[1]-n[0]+nCity) MOD nCity)) DIV 2; 
		   (*
		     This many cities must be swapped to effect the reversal.
		   *)
         FOR j := 1 TO nn DO 
            k := 1+((n[0]+j-2) MOD nCity); (* Start at the ends of
                                              the segment and swap pairs of cities, moving toward the center. *)
            l := 1+((n[1]-j+nCity) MOD nCity); 
            itmp := iorder^[k-1]; 
            iorder^[k-1] := iorder^[l-1]; 
            iorder^[l-1] := itmp
         END
      END reverse; 

      PROCEDURE trncst(    X, Y: Vector; 
                           IORDER: IVector; 
                       VAR n: IntegerArray6; 
                       VAR de: REAL); 
	   (*
	     This function returns the value of the cost function for a
	     proposed path segment transport.  NCITY is the number of cities, and 
	     arrays X[NCITY] and Y[NCITY] give the city coordinates.
	     IORDER[1, NCITY] is an array giving the present itinerary. The first 
	     three elements of array n give the starting and ending cities of the 
	     path to be transported, and the point among the remaining cities after
	     which it is to be inserted. On output, de is the cost of the change.
	     The actual transport is not performed by this routine.
	   *)
         VAR 
            xx, yy: ARRAY [0..5] OF REAL; 
            j, ii, nCity, nY, nIORDER: INTEGER; 
            x, y: PtrToReals;
            iorder: PtrToIntegers;
      BEGIN 
         GetVectorAttr(X, nCity, x);
         GetVectorAttr(Y, nY, y);
         GetIVectorAttr(IORDER, nIORDER, iorder);
         n[3] := 1+(n[2] MOD nCity); (* Find the city following n[2] *)
         n[4] := 1+((n[0]+nCity-2) MOD nCity); (* ..and the one
                                                  preceding n[0] *)
         n[5] := 1+(n[1] MOD nCity); (* ..and the one following n[1]. *)
         FOR j := 1 TO 6 DO 
            ii := iorder^[n[j-1]-1]; (* Determine coordinates for the
                                        six cities involved. *)
            xx[j-1] := x^[ii-1]; 
            yy[j-1] := y^[ii-1]
			   (*
			     Calculate the cost of disconnecting the path segment from  n[0] to
			     n[1], opening a space between n[2] and n[3],  connecting 
			     the segment in the space, and connecting  n[4] to n[5].
			   *)
         END; 
         de := -alen(xx[1], xx[5], yy[1], yy[5])
               -alen(xx[0], xx[4], yy[0], yy[4])
               -alen(xx[2], xx[3], yy[2], yy[3]) 
               +alen(xx[0], xx[2], yy[0], yy[2])
               +alen(xx[1], xx[3], yy[1], yy[3])
               +alen(xx[4], xx[5], yy[4], yy[5])
      END trncst; 

      PROCEDURE trnspt(    IORDER: IVector; 
                        VAR n: IntegerArray6); 
	   (*
	     This routine does the actual path transport, if METROP has 
	     approved.  IORDER[NCITY] is an input array giving 
	     the present itinerary.  The array n has as its six elements the beginning
	     n[0] and end n[1] of the path to be transported, the adjacent 
	     cities n[2] and n[3] between which the path is to be placed, and 
	     the cities n[4] and n[5] which precede and follow the path.  n[3], 
	     n[4] and n[5] are calculated by function TRNCST.  On output, 
	     IORDER is modified to reflect the movement of the path segment.
	   *)
         VAR 
            iorder, jorder: PtrToIntegers;
            JORDER: IVector; 
            m1, m2, m3, nn, j, jj, nCity: INTEGER; 
      BEGIN 
         GetIVectorAttr(IORDER, nCity, iorder);
         CreateIVector(nCity, JORDER, jorder);
         m1 := 1+((n[1]-n[0]+nCity) MOD nCity); (* The number of cities from 
                                                   n[0] to n[1] *)
         m2 := 1+((n[4]-n[3]+nCity) MOD nCity); (* ..and the 
                                                   number from n[3] to n[4] *)
         m3 := 1+((n[2]-n[5]+nCity) MOD nCity); (* ..and the 
                                                   number from n[5] to n[2]. *)
         nn := 1; 
         FOR j := 1 TO m1 DO 
            jj := 1+((j+n[0]-2) MOD nCity); (* Copy the chosen segment. *)
            jorder^[nn-1] := iorder^[jj-1]; 
            INC(nn, 1)
         END; 
         IF m2 > 0 THEN 
            FOR j := 1 TO m2 DO (* Then copy the segment from n[3] to n[4] *)
               jj := 1+((j+n[3]-2) MOD nCity); 
               jorder^[nn-1] := iorder^[jj-1]; 
               INC(nn)
            END
         END; 
         IF m3 > 0 THEN 
            FOR j := 1 TO m3 DO (* ..and the segment from n[5] to n[2]. *)
               jj := 1+((j+n[5]-2) MOD nCity); 
               jorder^[nn-1] := iorder^[jj-1]; 
               INC(nn)
            END
         END; 
         FOR j := 1 TO nCity DO 
            iorder^[j-1] := jorder^[j-1](* Copy JORDER into IORDER. *)
         END; 
         DisposeIVector(JORDER)
      END trnspt; 

      PROCEDURE metrop(de, t: REAL; VAR ans: BOOLEAN); 
	   (*
	     Metropolis algorithm. METROP returns a boolean variable which issues a 
	     verdict on whether to accept a reconfiguration which leads to a change de
	     in the objective function E. If de<0, ans=TRUE, while if 
	     de>0, ans is only TRUE with probability exp(-de/t), where 
	     t is a temperature determined by the annealing schedule.
	   *)
      BEGIN 
         ans := (de < 0.0) OR (Ran3(MetropJdum) < Exp((-de)/t))
      END metrop; 

   BEGIN (* Anneal *)
      GetVectorAttr(X, nCity, x);
      GetVectorAttr(Y, nY, y);
      GetIVectorAttr(IORDER, nIORDER, iorder);
      nover := 100*nCity; 
	   (*
	     Maximum number of paths tried at any temperature.
	   *)
      nlimit := 10*nCity; 
	   (*
	     Maximum number of successful path changes before continuing.
	   *)
      path := 0.0; 
      t := 0.5; 
      FOR i := 1 TO nCity-1 DO (* Calculate initial path length. *)
         i1 := iorder^[i-1]; 
         i2 := iorder^[i]; 
         path := path+alen(x^[i1-1], x^[i2-1], y^[i1-1], y^[i2-1])
      END; 
      i1 := iorder^[nCity-1]; (* Close the loop by tying path ends
                                 together. *)
      i2 := iorder^[0]; 
      path := path+alen(x^[i1-1], x^[i2-1], y^[i1-1], y^[i2-1]); 
      idum := -1; 
      iseed := {};
      INCL(iseed, 0); INCL(iseed, 1); INCL(iseed, 2); 
      INCL(iseed, 3); INCL(iseed, 5); INCL(iseed, 6); 
      FOR j := 1 TO 100 DO (* Try up to 100 temperature steps. *)
         nsucc := 0; 
         k := 0; 
         REPEAT 
            INC(k, 1); 
            REPEAT 
               n[0] := 1+Trunc(Float(nCity)*Ran3(idum)); (* Choose beginning of segment .. *)
               n[1] := 1+Trunc(Float(nCity-1)*Ran3(idum)); 
				   (*
				     ..and end of segment.
				   *)
               IF n[1] >= n[0] THEN 
                  n[1] := n[1]+1
               END; 
               nn := 1+((n[0]-n[1]+nCity-1) MOD nCity); (* NN is the number of cities not 
                                                           on the segment. *)
            UNTIL nn >= 3; 
            idec := IRBit1(iseed); 
			   (*
			     Choose between segment reversal and transport.
			   *)
            IF idec = {} THEN (* Do a transport... *)
               n[2] := n[1]+Trunc(ABS(Float(nn-2))*Ran3(idum))+1; 
               n[2] := 1+((n[2]-1) MOD nCity); 
				   (*
				     ...to a location not on the path.
				   *)
               trncst(X, Y, IORDER, n, de); 
				   (*
				     Calculate cost.
				   *)
               metrop(de, t, ans); (* Consult the oracle. *)
               IF ans THEN 
                  INC(nsucc); 
                  path := path+de; 
                  trnspt(IORDER, n)(* Carry out the transport. *)
               END
            ELSE (* Do a path reversal *)
               revcst(X, Y, IORDER, n, de); 
				   (*
				     Calculate cost.
				   *)
               metrop(de, t, ans); (* Consult the oracle. *)
               IF ans THEN 
                  INC(nsucc, 1); 
                  path := path+de; 
                  reverse(IORDER, n)(* Carry out the reversal. *)
               END
            END; 
         UNTIL (nsucc >= nlimit) OR (k >= nover); (* Finish early if we have enough successful changes. *)
         WriteLn; 
         WriteString('T ='); 
         WriteReal(t, 10, 6); 
         WriteString(' Path Length ='); 
         WriteReal(path, 12, 6); 
         WriteLn; 
         WriteString('Successful Moves: '); 
         WriteInt(nsucc, 6); 
         WriteLn; 
         t := t*tfactr; (* Annealing schedule. *)
         IF nsucc = 0 THEN (* If no success, we are done. *)
            RETURN 
         END
      END; 
   END Anneal; 

BEGIN
   MetropJdum := -1;
END AnnealM.
