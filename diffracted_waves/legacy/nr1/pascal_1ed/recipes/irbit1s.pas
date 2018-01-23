FUNCTION irbit1(VAR iseed: integer): integer;
CONST
   ib1 = 1;
   ib3 = 4;
   ib5 = 16;
   ib14 = 8192;
VAR
   mask: integer;
   newbit: boolean;

FUNCTION iand(i1,i2: integer): integer;
VAR
   i: integer;
BEGIN
   IF (i1 = 0) OR (i2 = 0) THEN iand := 0
   ELSE BEGIN
      i := ord(odd(i1) AND odd(i2));
      i1 := i1 DIV 2;
      i2 := i2 DIV 2;
      iand := 2*iand(i1,i2) + i
   END
END;

FUNCTION inot(ib: integer): integer;
BEGIN
   inot := maxint-ib
END;

FUNCTION ior(i1,i2: integer): integer;
VAR
   i: integer;
BEGIN
   IF (i1 = 0) AND (i2 = 0) THEN ior := 0
   ELSE BEGIN
      i := ord(odd(i1) OR odd(i2));
      i1 := i1 DIV 2;
      i2 := i2 DIV 2;
      ior := 2*ior(i1,i2) + i
   END
END;

BEGIN
   mask := maxint DIV 2;
   newbit := iand(iseed,ib14) <> 0;
   IF iand(iseed,ib5) <> 0 THEN
      newbit := NOT newbit;
   IF iand(iseed,ib3) <> 0 THEN
      newbit := NOT newbit;
   IF iand(iseed,ib1) <> 0 THEN
      newbit := NOT newbit;
   irbit1 := 0;
   iseed := iand(2*iand(mask,iseed),inot(ib1));
   IF newbit THEN BEGIN
      irbit1 := 1;
      iseed := ior(iseed,ib1)
   END
END;
