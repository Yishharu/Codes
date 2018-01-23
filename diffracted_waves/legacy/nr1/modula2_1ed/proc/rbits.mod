IMPLEMENTATION MODULE RBits;

   FROM NRMath IMPORT ShiftLeft, XOR;

   CONST 
      bit0  =  0; (* The values are chosen not to overflow 2-byte integers.
                     If you have 4-byte integers, choose a set of constants with larger
                     values using the table at the end of this section. *)
      bit2  =  2; 
      bit4  =  4; 
      bit13 = 13; 

   PROCEDURE IRBit1(VAR seed: BITSET): BITSET; 
      VAR 
         newBit: BOOLEAN; 
         result: BITSET; (* The accumulated XOR's. *)
   BEGIN 
      newBit := bit13 IN seed; (* Get bit 14. *)
      IF (bit4 IN seed) THEN (* XOR with bit 5. *)
         newBit :=  NOT newBit 
      END; 
      IF bit2 IN seed THEN (* XOR with bit 3. *)
         newBit :=  NOT newBit 
      END; 
      IF bit0 IN seed THEN (* XOR with bit 1. *)
         newBit :=  NOT newBit 
      END; 
      ShiftLeft(seed, 1); 
	   (*
	     Leftshift the seed and put a zero in its bit 1.
	   *)
      result := {};
      IF newBit THEN (* But if the XOR calculation gave a 1, *)
         INCL(result, 0); 
         INCL(seed, 0);(* then put that in bit 1 instead. *)
      END; 
      RETURN result
   END IRBit1; 

   PROCEDURE IRBit2(VAR seed: BITSET): BITSET; 
      VAR mask, one, result: BITSET; 
   BEGIN 
      result := {};
      IF bit13 IN seed THEN (* Change all masked bits, shift,
                               and put 1 into bit 1. *)
         mask := {};
         INCL(mask, 0); INCL(mask, 2); INCL(mask, 4);
         one := {};
         INCL(one, 0);
         XOR(seed, mask);
         ShiftLeft(seed, 1);(* Shift and put 0 into bit 1. *)
         seed := seed + one;
         INCL(result, 0); 
      ELSE 
         ShiftLeft(seed, 1); 
      END; 
      RETURN result
   END IRBit2; 

END RBits.
