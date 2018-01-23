IMPLEMENTATION MODULE GammBeta;

   FROM NRMath   IMPORT RoundSD, Exp, LnDD;
   FROM NRSystem IMPORT LongInt, LongReal, D, S, Float, FloatDS;
   FROM NRIO     IMPORT Error;

   PROCEDURE GammLn(xx: REAL): REAL;
      CONST
         stp = 2.50662827465;
      VAR
         x, tmp, ser: LongReal; (* Internal arithmetic will be done in double precision, a nicety
                                   that you can omit if five-figure accuracy is good enough. *)
         gammLn: REAL;
   BEGIN
      x  := D(xx-1.0);
      tmp := x+D(5.5);
      tmp := (x+D(0.5))*LnDD(tmp)-tmp;
      ser := D(1.0)+D(76.18009173)   /(x+D(1.0))-D(86.50532033)/(x+D(2.0))
                   +D(24.01409822)   /(x+D(3.0))-D(1.231739516)/(x+D(4.0))
                   +D(0.120858003E-2)/(x+D(5.0))-D(0.536382E-5)/(x+D(6.0));
      gammLn :=S(tmp+LnDD(D(stp)*ser));
      RETURN gammLn
   END GammLn;

   VAR
      FactrlNTop: INTEGER; (* Initialization in PROCEDURE InitGlobals. *)
      FactrlA: ARRAY [1..33] OF REAL;

   PROCEDURE Factrl(n: INTEGER): REAL; 
      VAR 
         j: INTEGER; 
         factrl: REAL; 
   BEGIN 
      IF n < 0 THEN 
         Error('Factrl', 'negative factorial'); 
      ELSIF n <= FactrlNTop THEN (* Already in table. *)
         factrl := FactrlA[n+1]
      ELSIF n <= 32 THEN (* Fill in table up to desired value. *)
         FOR j := FactrlNTop+1 TO n DO 
            FactrlA[j+1] := Float(j)*FactrlA[j]
         END; 
         FactrlNTop := n; 
         factrl := FactrlA[n+1]
      ELSE 
         factrl := Exp(GammLn(Float(n)+1.0))
		   (*
		     Larger value than size of table is required.
		     Actually, this big a value is going to overflow on many computers, but
		     no harm in trying.
		   *)
      END; 
      RETURN factrl
   END Factrl;

   VAR
      FactLnA: ARRAY [1..100] OF REAL;

   PROCEDURE FactLn(n: INTEGER): REAL; 
      VAR factLn: REAL; 
   BEGIN
      IF n < 0 THEN
         Error('FactLn', 'negative factorial');
      ELSIF n <= 99 THEN (* In range of the table. *)
         IF FactLnA[n+1] < 0.0 THEN
            FactLnA[n+1] := GammLn(Float(n)+1.0)
         END; 
         factLn := FactLnA[n+1] (* If not already in the table, put it in. *)
      ELSE 
         factLn := GammLn(Float(n)+1.0)
		   (*
		     Out of range of the table.
		   *)
      END; 
      RETURN factLn
   END FactLn; 

   PROCEDURE BiCo(n, k: INTEGER): REAL;
      VAR
         long: LongInt;
         a, b, c, d: REAL;
   BEGIN
      a := FactLn(n);
      b := FactLn(k);
      c := FactLn(n-k);
      d:= Exp(a - b - c);
      long := RoundSD(d);
      RETURN FloatDS(long);
	   (*
	     The RoundSD function cleans up roundoff error for smaller values of n and k.
	   *)                    
   END BiCo;

   PROCEDURE Beta(z, w: REAL): REAL; 
   BEGIN 
      RETURN Exp(GammLn(z)+GammLn(w)-GammLn(z+w)); 
   END Beta;

   PROCEDURE InitGlobals; 
   (*
     Initialization.
   *)
      VAR i: INTEGER; 
   BEGIN 
      FactrlNTop := 0;
      FactrlA[1] := 1.0;
      FOR i := 1 TO 100 DO 
         FactLnA[i] := -1.0; 
      END;
   END InitGlobals;
  


BEGIN
   InitGlobals;
END GammBeta.
