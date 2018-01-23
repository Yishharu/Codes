IMPLEMENTATION MODULE DataEnc;

   FROM NRMath   IMPORT DIVD, MODD, ShiftLeft, ShiftRight, XOR;
   FROM NRSystem IMPORT Allocate, Deallocate, LongInt;
   FROM NRIO     IMPORT File, Open, Close, GetInt, GetLongInt, GetByte;
   FROM SYSTEM   IMPORT WORD, BYTE, ADR;

	TYPE
	   ByteArray4 = ARRAY [1..4] OF BYTE;
	   ByteArray32 = ARRAY [1..32] OF BYTE;
	   ByteArray48 = ARRAY [1..48] OF BYTE;
	   ByteArray56 = ARRAY [1..56] OF BYTE;
	   ByteArray64 = ARRAY [1..64] OF BYTE;
      RealArray65 = ARRAY [1..65] OF REAL;
	   Great = RECORD l,c,r: WORD END;
	   Operation = (or, and, xor, shl, shr);

	VAR
	   infile: File;
	   CyfunIet: ByteArray48;
	   CyfunIpp: ByteArray32;
	   CyfunIs: ARRAY [1..16],[1..4],[1..8] OF INTEGER;
	   CyfunIbin: ARRAY [0..15] OF LongInt;
	   CyfunFlg: BOOLEAN;
	   KsIcd: Immense;
	   KsIpc1: ByteArray56;
	   KsIpc2: ByteArray48;
	   KsFlg: BOOLEAN;
	   DesBit : ARRAY [1..32] OF LongInt;
	   DesIp,DesIpm: ByteArray64;
	   DesKns: ARRAY [1..16] OF Great;
	   DesFlg: BOOLEAN;

	   Ran4Newkey: BOOLEAN;
	   Ran4Inp,Ran4Key: Immense;
      Ran4Pow: RealArray65;
      ThreeFH: LongInt;

      PROCEDURE BitOp(x: ARRAY OF WORD; y: ARRAY OF WORD; op: Operation; step: INTEGER): LongInt;         VAR
            set1X, set2X, set1Y, set2Y, result1, result2: BITSET;
            ptr1X, ptr2X, ptr1Y, ptr2Y, ptr1Result, ptr2Result: POINTER TO BITSET;
            bytesX, bytesY, bytesResult: ByteArray4;
            result: LongInt;
            overflow: BOOLEAN;
            i: INTEGER;
            resultWord: ARRAY [0..1] OF WORD;
      BEGIN
         set1X := x[0];
         set2X := x[1];
         set1Y := y[0];
         set2Y := y[1];
         CASE op OF
            or:
	         result1 := set1X + set1Y;
	         result2 := set2X + set2Y;
	       | and:
	         result1 := set1X * set1Y;
	         result2 := set2X * set2Y;
	       | xor:
 	         result1 := set1X / set1Y;
	         result2 := set2X / set2Y;
	       | shl:
	         result1 := set1X;
	         result2 := set2X;
	         FOR i := 1 TO step DO
   	         IF 15 IN result1 THEN overflow := TRUE
   	         ELSE overflow := FALSE;
   	         END;
   	         ShiftLeft(result1, 1);
   	         ShiftLeft(result2, 1);
   	         IF overflow THEN INCL(result2, 0);
   	         END;
   	      END;
	       | shr:
	         result1 := set1X;
	         result2 := set2X;
	         FOR i := 1 TO step DO
   	         IF 0 IN result2 THEN overflow := TRUE
   	         ELSE overflow := FALSE;
   	         END;
   	         ShiftRight(result1, 1);
	            ShiftRight(result2, 1);
   	         IF overflow THEN INCL(result1, 15);
   	         END;
   	      END;
         END;
         resultWord[0] := result1;
         resultWord[1] := result2;
         result := LongInt(resultWord);
	      RETURN result;
      END BitOp;

   PROCEDURE Or(x: LongInt; y: LongInt): LongInt;
    BEGIN
       RETURN BitOp(x, y, or, 0);
    END Or;

   PROCEDURE And(x: LongInt; y: LongInt): LongInt;
   BEGIN
      RETURN BitOp(x, y, and, 0);
   END And;

   PROCEDURE XOr(x: LongInt; y: LongInt): LongInt;
   BEGIN
      RETURN BitOp(x, y, xor, 0);
   END XOr;

   PROCEDURE SHL(x: LongInt; step: INTEGER): LongInt;
      VAR dummy: LongInt;
   BEGIN
      RETURN BitOp(x, dummy, shl, step);
   END SHL;

   PROCEDURE SHR(x: LongInt; step: INTEGER): LongInt;
      VAR dummy: LongInt;
   BEGIN
         RETURN BitOp(x, dummy, shr, step);
   END SHR;

   PROCEDURE OrWord(x: WORD; y: WORD): WORD;
      VAR xSet, ySet, result: BITSET;
   BEGIN
      xSet :=  x;
      ySet := y;
      result := xSet + ySet;
      RETURN result;
  END OrWord;

   PROCEDURE XOrWord(x: WORD; y: WORD): WORD;
      VAR xSet, ySet, result: BITSET;
   BEGIN
      xSet := x;
      ySet := y;
      result := xSet / ySet;
      RETURN result;
   END XOrWord;

   PROCEDURE SHLWord(x: WORD; step: INTEGER): WORD;
      VAR xSet: BITSET;
   BEGIN
      xSet := x;
      ShiftLeft(xSet, step);
      RETURN xSet;
   END SHLWord;

   PROCEDURE SHRWord(x: WORD; step: INTEGER): WORD;
      VAR xSet: BITSET;
   BEGIN
      xSet := x;
      ShiftRight(xSet, step);
      RETURN xSet;
   END SHRWord;

   PROCEDURE GetBit(source: Immense;
                    bitNo:  BYTE;
                    nbits:  INTEGER): LongInt;
   (*
     Returns bit in position bitNo of record source. The rightmost
     nbits bits of each component of source have been filled.
   *)
      VAR
         bitResult: LongInt;
         bitNoInt: INTEGER;
   BEGIN
      bitNoInt := ORD(VAL(CHAR, bitNo));
      IF bitNoInt <= nbits THEN
         IF And(DesBit[bitNoInt], source.r) <> 0 THEN
            bitResult := 1
         ELSE
            bitResult := 0
         END
      ELSIF And(DesBit[bitNoInt-nbits], source.l) <> 0 THEN
         bitResult := 1
      ELSE
         bitResult := 0
      END;
      RETURN bitResult
   END GetBit;

   PROCEDURE CyFun(    ir:   LongInt;
                       k:    Great;
                   VAR iout: LongInt); 
   (*
     Returns the cipher function of ir and k in iout.
   *)
      VAR
         ie: Great;
         itmp1, itmp2, ietmp1, ietmp2, itmp3, jLong: LongInt;
         iec: ARRAY [1..8] OF BYTE;
         jj, ki, irow, icol, iss, j, l, m, ix: INTEGER;
   BEGIN
      IF CyfunFlg THEN
         CyfunFlg := FALSE;
         Open('cyfuni.dat', infile);
         FOR j := 1 TO 48 DO GetByte(infile, CyfunIet[j]); END;
         FOR j := 1 TO 32 DO GetByte(infile, CyfunIpp[j]); END;
         FOR jj := 1 TO 8 DO
            FOR ki := 1 TO 4 DO
               FOR j := 1 TO 16 DO GetInt(infile, CyfunIs[j, ki, jj]); END
            END
         END;
         FOR j := 0 TO 15 DO GetLongInt(infile, CyfunIbin[j]); END;
         Close(infile)
      END;
      ie.r := 0; 
      ie.c := 0; 
      ie.l := 0; 
      FOR j := 16 TO 1 BY -1 DO (* Expand ir to 48 bits and combine it 
                                  with k. *)
         l := j+16; 
         m := l+16; 
         ie.r := SHLWord(ie.r, 1); 
         ix := ORD(VAL(CHAR, CyfunIet[j]));
         IF And(DesBit[ix], ir) <> 0 THEN
            ie.r := OrWord(ie.r, 1);
         END;
         ie.c := SHLWord(ie.c, 1);
         IF And(DesBit[ORD(VAL(CHAR, CyfunIet[l]))], ir) <> 0 THEN
            ie.c := OrWord(ie.c, 1);
         END;
         ie.l := SHLWord(ie.l, 1);
         IF And(DesBit[ORD(VAL(CHAR, CyfunIet[m]))], ir) <> 0 THEN
            ie.l := OrWord(ie.l, 1);
         END
      END;
      ie.r := XOrWord(ie.r, k.r);
      ie.c := XOrWord(ie.c, k.c);
      ie.l := XOrWord(ie.l, k.l);
      itmp1 := VAL(LongInt, ie.c);
      itmp2 := VAL(LongInt, ie.r);
      ietmp1 := SHL(itmp1, 16)+itmp2;
      itmp2 := VAL(LongInt, ie.l);
      ietmp2 := SHL(itmp2, 8)+SHR(itmp1, 8);
      FOR j := 1 TO 4 DO
         m := j+4;
         iec[j] := VAL(BYTE, (And(ietmp1, ThreeFH)) );
         iec[m] := VAL(BYTE, (And(ietmp2, ThreeFH)) );
         ietmp1 := SHR(ietmp1, 6);
         ietmp2 := SHR(ietmp2, 6);
      END;
      itmp1 := 0;
      FOR jj := 8 TO 1 BY -1 DO (* Loop over 8 groups of 6 bits. *)
         j := ORD(VAL(CHAR, iec[jj]));
         jLong := VAL(LongInt, j);
         irow := VAL(INTEGER, SHL(And(jLong, 01H), 1)+SHR(And(jLong, 20H), 5));
                                                (* Find place in the s-box table. *)
         icol := VAL(INTEGER, SHL(And(jLong, 02H), 2)+And(jLong, 04H)+SHR(And(jLong, 08H), 2)+
                 SHR(And(jLong, 010H), 4));
         iss := CyfunIs[icol+1][irow+1][jj]; (* Look up the number in the s-box table *)
         itmp1 := Or(SHL(itmp1, 4), CyfunIbin[iss]);(* and plug its bits into the output. *)
      END;
      iout := 0;
      FOR j := 32 TO 1 BY -1 DO (* Final permutation. *)
         iout := SHL(iout, 1);
         IF And(DesBit[ORD(VAL(CHAR, CyfunIpp[j]))], itmp1) <> 0 THEN
            iout := Or(iout, 1);
         END
      END
   END CyFun;

   PROCEDURE KS(    key: Immense;
                    n:   INTEGER;
                VAR kn:  Great);
   (*
     Key schedule calculation, returns kn given key and n=1,2,...,16;
     must be called with n in that order.
   *)
      VAR it, i, j, k, l: INTEGER;
   BEGIN
      IF KsFlg THEN
         KsFlg := FALSE;
         Open('ksinpu.dat', infile);
         FOR i := 1 TO 56 DO GetByte(infile, KsIpc1[i]); END;
         FOR i := 1 TO 48 DO GetByte(infile, KsIpc2[i]); END;
         Close(infile)
      END;
      IF n = 1 THEN (* Initial selection and permutation. *)
         KsIcd.r := 0;
         KsIcd.l := 0;
         FOR j := 28 TO 1 BY -1 DO
            k := j+28;
            KsIcd.r := Or(SHL(KsIcd.r, 1), GetBit(key, KsIpc1[j], 32));
            KsIcd.l := Or(SHL(KsIcd.l, 1), GetBit(key, KsIpc1[k], 32));
         END
      END;
      IF (n = 1) OR (n = 2) OR (n = 9) OR (n = 16) THEN
         it := 1 (* One or two shifts, according to the value of n. *)
      ELSE
         it := 2
      END;
      FOR i := 1 TO it DO (* Circular left-shifts of the two halves of
                            the record tKsIcd. *)
         KsIcd.r := SHR(Or(KsIcd.r, (SHL(And(KsIcd.r, 1), 28))), 1);
         KsIcd.l := SHR(Or(KsIcd.l, (SHL(And(KsIcd.l, 1), 28))), 1);
      END; (* Done with the shifts. *)
      kn.r := 0;
      kn.c := 0;
      kn.l := 0;
      FOR j := 16 TO 1 BY -1 DO (* The sub-master key is a selection of bits
                                  from the shifted tKsIcd. *)
         k := j+16;
         l := k+16;
         kn.r := OrWord(SHLWord(kn.r, 1), VAL(WORD, VAL(INTEGER, GetBit(KsIcd, KsIpc2[j], 28))));
         kn.c := OrWord(SHLWord(kn.c , 1), VAL(WORD, VAL(INTEGER, GetBit(KsIcd, KsIpc2[k], 28))));
         kn.l := OrWord(SHLWord(kn.l, 1), VAL(WORD, VAL(INTEGER, GetBit(KsIcd, KsIpc2[l], 28))));
      END
   END KS;

   PROCEDURE DES(    inp, key: Immense;
                 VAR newkey:   BOOLEAN;
                     isw:      INTEGER;
                 VAR out:      Immense);
      VAR
         ii, i, j, k: INTEGER;
         ic: LongInt;
         itmp: Immense;
   BEGIN
      IF DesFlg THEN
         DesFlg := FALSE;
         DesBit[1] := 1; (* Store bit array. *)
         FOR j := 2 TO 32 DO DesBit[j] := DesBit[j-1]  * 2 END;
         Open('desinp.dat', infile);
         FOR i := 1 TO 64 DO GetByte(infile, DesIp[i]); END;
         FOR i := 1 TO 64 DO GetByte(infile, DesIpm[i]); END;
         Close(infile)
      END;
      IF newkey THEN (* Get the 16 sub-master keys from the master key. *)
         newkey := FALSE;
         FOR i := 1 TO 16 DO
            KS(key, i, DesKns[i])
         END
      END;
      itmp.r := 0; itmp.l := 0;
      FOR j := 32 TO 1 BY -1 DO (* The initial permutation. *)
         k := j+32;
         itmp.r :=Or(SHL(itmp.r, 1), GetBit(inp, DesIp[j], 32));
         itmp.l := Or(SHL(itmp.l, 1), GetBit(inp, DesIp[k], 32))
      END;
      FOR i := 1 TO 16 DO(* The 16 stages of encryption. *)
         IF isw = 1 THEN ii := 17-i ELSE ii := i END;
   (*
     The sub-master keys are used in reverse order for decryption.
   *)
         CyFun(itmp.l, DesKns[ii], ic); (* Get cipher function. *)
         ic := XOr(ic, itmp.r);(* Pass one half-word through unchanged.
                                  Encrypt the other half-word and 
                                  exchange the output of the two half-words. *)
         itmp.r := itmp.l;
         itmp.l := ic
      END;(* Done with the 16 stages. *)
      ic := itmp.r; (* a final exchange of the two half-words is required. *)
      itmp.r := itmp.l;
      itmp.l := ic;
      out.r := 0;
      out.l := 0;
      FOR j := 32 TO 1 BY -1 DO (* Final output permutation. *)
         k := j+32;
         out.r := Or(SHL(out.r, 1), GetBit(itmp, DesIpm[j], 32));
         out.l := Or(SHL(out.l, 1), GetBit(itmp, DesIpm[k], 32))
      END
   END DES;

   PROCEDURE Ran4(VAR idum: INTEGER): REAL;
      CONST
         m = 11979;
         a = 430;
         c = 2531;
         nacc = 24;
         ib1 = 1;(* Powers of two for the primitive polynomial (64,4,3,1,0). *)
         ib3 = 4;
         ib4 = 8;
         ib32 = 080000000H;
         mask = ib1+ib3+ib4;
      VAR
         isav, isav2: LongInt;
         j: INTEGER;
         jot: POINTER TO Immense;
         r4: REAL;
         ran4Result: REAL;
   BEGIN
      Allocate(jot, SIZE(Immense));
      IF idum < 0 THEN (* Initialization block. *)
         idum := idum MOD m;
         IF idum < 0 THEN INC(idum, m) END;
         Ran4Pow[1] := 0.5;
         Ran4Key.l := 0;
         Ran4Key.r := 0;
         Ran4Inp.l := 0;
         Ran4Inp.r := 0;
         FOR j := 1 TO 64 DO (* Set both the 64 bits of key and also
                                the starting configuration of the 64-bit input array. *)
            idum := (idum*a+c) MOD m;
            isav := 2 * LongInt(idum) DIV m; (* Highest order bit. *)
            IF isav = 1 THEN
               isav := ib32
            END;
            isav2 := (4 * LongInt(idum) DIV m) MOD 2;(* Next highest order bit. *)
            IF isav2 = 1 THEN
               isav2 := ib32
            END;
            IF j <= 32 THEN
               Ran4Key.r := Or(SHR(Ran4Key.r, 1), isav);
               Ran4Inp.r := Or(SHR(Ran4Inp.r, 1), isav2);
            ELSE
               Ran4Key.l := Or(SHR(Ran4Key.l, 1), isav);
               Ran4Inp.l := Or(SHR(Ran4Inp.l, 1), isav2)
            END;
            Ran4Pow[j+1] := 0.5*Ran4Pow[j] (* Inverse powers of 2
                                             in floating point. *)
         END;
         Ran4Newkey := TRUE(* Set this flag. *)
      END;
      isav := And(Ran4Inp.r, ib32);(* Start here except on initialization. *)
      IF isav <> 0 THEN(* isav ensures that bit 32 is shifted into bit 33 below. *)
         isav := 1
      END;
      IF And(Ran4Inp.l, ib32) <> 0 THEN(* Generate the next input bit
                                          configuration; *)
         Ran4Inp.r := Or(SHL(XOr(Ran4Inp.r, mask), 1), ib1)
      ELSE
         Ran4Inp.r := SHL(Ran4Inp.r, 1)
      END;
      Ran4Inp.l := Or(SHL(Ran4Inp.l, 1), isav); (* Input bit configuration now ready. *)
      DES(Ran4Inp, Ran4Key, Ran4Newkey, 0, jot^);(* Here is the real business. *)
      r4 := 0.0;
      FOR j := 1 TO nacc DO(* It remains only to make a floating number out
                              of random bits. We assume here that nacc number of
                              bits in floating point representation. *)
         IF And(jot^.r, ib1) <> 0 THEN
            r4 := r4+Ran4Pow[j]
         END;
         jot^.r := SHR(jot^.r, 1)
      END;
      ran4Result := r4;
      Deallocate(jot);
      RETURN ran4Result
   END Ran4;

BEGIN
   CyfunFlg := TRUE;(* Initializations. *)
   KsFlg := TRUE;
   DesFlg := TRUE;
   ThreeFH := 3FH;
END DataEnc.
