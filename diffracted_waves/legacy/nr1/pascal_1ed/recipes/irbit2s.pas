FUNCTION irbit2(VAR iseed: integer): integer;
CONST
   ib1 = 1;
   ib3 = 4;
   ib5 = 16;
   ib14 = 8192;
   mask = 21;
VAR
   mask1: integer;

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

FUNCTION inot(i: integer): integer;
BEGIN
   inot := maxint-i
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

FUNCTION ieor(i1,i2: integer): integer;
VAR
   i: integer;
BEGIN
   IF (i1 = 0) AND (i2 = 0) THEN ieor := 0
   ELSE BEGIN
      i := ord((odd(i1) AND NOT odd(i2)) OR (odd(i2) AND NOT odd(i1)));
      i1 := i1 DIV 2;
      i2 := i2 DIV 2;
      ieor := 2*ieor(i1,i2) + i
   END
END;

BEGIN
   mask1 := maxint DIV 2;
   IF iand(iseed,ib14) <> 0 THEN BEGIN
      iseed := ior(2*iand(ieor(iseed,mask),mask1),ib1);
      irbit2 := 1
   END
   ELSE BEGIN
      iseed := iand(2*iand(iseed,mask1),inot(ib1));
      irbit2 := 0
   END
END;
