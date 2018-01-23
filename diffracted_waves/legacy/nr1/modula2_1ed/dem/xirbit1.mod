MODULE XIRBit1; (* driver for routine IRBit1 *) 
                (* calculate distribution of runs of zeros *) 

   FROM RBits IMPORT IRBit1;
   FROM NRSystem IMPORT Float;
   FROM NRIO IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString;

   CONST 
      nbin = 15; 
      ntries = 500; 
      bit0 = 0;
   TYPE 
      RealArrayNBIN = ARRAY [1..nbin] OF REAL; 
   VAR 
      i, iflg, ipts, j, n: INTEGER; 
      twoinv: REAL; 
      delay: RealArrayNBIN; 
      iseed: BITSET;
       
BEGIN 
   iseed := {}; 
   INCL(iseed, 0); INCL(iseed, 1); 
   INCL(iseed, 2); INCL(iseed, 3);
   FOR i := 1 TO nbin DO 
      delay[i] := 0.0
   END; 
   WriteString('distribution of runs of n zeros'); 
   WriteLn; 
   WriteString('     n'); 
   WriteString('           probability'); 
   WriteString('          expected'); 
   WriteLn; 
   ipts := 0; 
   FOR i := 1 TO ntries DO 
      IF bit0 IN IRBit1(iseed) THEN 
         INC(ipts, 1); 
         iflg := 0; 
         FOR j := 1 TO nbin DO 
            IF (bit0 IN IRBit1(iseed)) AND (iflg = 0) THEN 
               iflg := 1; 
               delay[j] := delay[j]+1.0
            END
         END
      END
   END; 
   twoinv := 0.5; 
   FOR n := 1 TO nbin DO 
      WriteInt(n-1, 6); 
      WriteReal(delay[n]/Float(ipts), 19, 4); 
      WriteReal(twoinv, 20, 4); 
      WriteLn; 
      twoinv := twoinv/2.0
   END;
   ReadLn;
END XIRBit1.
