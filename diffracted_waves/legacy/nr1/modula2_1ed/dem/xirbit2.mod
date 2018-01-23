MODULE XIRBit2; (* driver for routine IRBitT2 *) 
                (* calculate distribution of runs of zeros *) 

   FROM RBits    IMPORT IRBit2;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString;

   CONST 
      nbin = 15; 
      ntries = 500; 
      bit0 = 0;
   TYPE 
      RealArrayNBIN = ARRAY [1..nbin] OF REAL; 
   VAR 
      i, iflg, ipts, j, n: INTEGER; 
      delay: RealArrayNBIN; 
      iseed: BITSET;

   PROCEDURE twoton(n: INTEGER): INTEGER; 
   BEGIN 
      IF n = 0 THEN RETURN 1
      ELSE RETURN 2*twoton(n-1)
      END; 
   END twoton; 
    
BEGIN 
   iseed := {};
   INCL(iseed, 0); INCL(iseed, 1); INCL(iseed, 2); 
   INCL(iseed, 3); INCL(iseed, 5); INCL(iseed, 6); 
   FOR i := 1 TO nbin DO 
      delay[i] := 0.0
   END; 
   ipts := 0; 
   FOR i := 1 TO ntries DO 
      IF bit0 IN IRBit2(iseed) THEN 
         INC(ipts, 1); 
         iflg := 0; 
         FOR j := 1 TO nbin DO 
            IF (bit0 IN IRBit2(iseed)) AND (iflg = 0) THEN 
               iflg := 1; 
               delay[j] := delay[j]+1.0
            END
         END
      END
   END; 
   WriteString('distribution of runs of n zeros'); 
   WriteLn; 
   WriteString('     n           probability          expected'); 
   WriteLn; 
   FOR n := 1 TO nbin DO 
      WriteInt(n-1, 6); 
      WriteReal(delay[n]/Float(ipts), 19, 4); 
      WriteReal(Float(1)/Float(twoton(n)), 20, 4); 
      WriteLn
   END; 
   ReadLn;
END XIRBit2.
