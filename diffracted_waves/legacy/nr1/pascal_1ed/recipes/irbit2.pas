FUNCTION irbit2(VAR iseed: integer): integer;
CONST
   ib1 = 1;
   ib3 = 4;
   ib5 = 16;
   ib14 = 8192;
   mask = 21;
BEGIN
   IF iseed AND ib14 <> 0 THEN BEGIN
      iseed := ((iseed XOR mask) SHL 1) OR ib1;
      irbit2 := 1
   END
   ELSE BEGIN
      iseed := iseed SHL 1;
      irbit2 := 0
   END
END;
