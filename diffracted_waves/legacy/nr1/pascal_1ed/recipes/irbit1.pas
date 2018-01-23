FUNCTION irbit1(VAR iseed: integer): integer;
CONST
   ib1 = 1;
   ib3 = 4;
   ib5 = 16;
   ib14 = 8192;
VAR
   newbit: boolean;
BEGIN
   newbit := (iseed AND ib14) <> 0;
   IF iseed AND ib5 <> 0 THEN newbit :=  NOT newbit;
   IF iseed AND ib3 <> 0 THEN newbit :=  NOT newbit;
   IF iseed AND ib1 <> 0 THEN newbit :=  NOT newbit;
   iseed := iseed SHL 1;
   IF newbit THEN BEGIN
      irbit1 := 1;
      iseed := iseed OR ib1
   END
   ELSE
      irbit1 := 0
END;
