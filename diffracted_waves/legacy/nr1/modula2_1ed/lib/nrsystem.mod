IMPLEMENTATION MODULE NRSystem;

   FROM Storage IMPORT ALLOCATE, DEALLOCATE;
   FROM SYSTEM IMPORT ADDRESS, BYTE;

   PROCEDURE D(x: REAL): LongReal;
   BEGIN
      RETURN VAL(LongReal, x);
   END D;

   PROCEDURE S(x: LongReal): REAL;
   BEGIN
      IF (x > MAX(REAL)) THEN
         RETURN MAX(REAL);
      ELSIF (x < MIN(REAL)) THEN
         RETURN MIN(REAL);
      ELSIF (x > -1.E-36) AND (x < 1.E-36) THEN
         RETURN 0.0;
      ELSE
         RETURN VAL(REAL, x);
      END;
   END S;

   PROCEDURE DI(x: INTEGER):  LongInt;
   BEGIN
      RETURN VAL(LongInt, x);
   END DI;

   PROCEDURE SI(x: LongInt):  INTEGER;
   BEGIN
      RETURN VAL(INTEGER, x);
   END SI;

   PROCEDURE Float(x: INTEGER): REAL;
      VAR val: REAL;
   BEGIN
      val := VAL(REAL, x);
      RETURN VAL(REAL, x);
   END Float;

   PROCEDURE FloatSD(x: INTEGER): LongReal;
      VAR val: LongReal;
   BEGIN
      val := VAL(LongReal, x);
      RETURN VAL(LongReal, x);
   END FloatSD;

   PROCEDURE FloatDS(x: LongInt): REAL;
      VAR val: REAL;
   BEGIN
      val := VAL(REAL, x);
      RETURN VAL(REAL, x);
   END FloatDS;

   PROCEDURE FloatDD(x: LONGINT): LongReal;
      VAR val: LongReal;
   BEGIN
      val := VAL(LongReal, x);
      RETURN VAL(LongReal, x);
   END FloatDD;

   PROCEDURE Trunc(x: REAL): INTEGER;
      VAR val: INTEGER;
   BEGIN
      val := VAL(INTEGER, x);
      RETURN VAL(INTEGER, x);
   END Trunc;

   PROCEDURE TruncSD(x: REAL): LongInt;
      VAR val: LongInt;
   BEGIN
      val := VAL(LongInt, x);
      RETURN VAL(LongInt, x);
   END TruncSD;

   PROCEDURE TruncDS(x: LongReal):INTEGER;
      VAR val: INTEGER;
   BEGIN
      val := VAL(INTEGER, x);
      RETURN VAL(INTEGER, x);
   END TruncDS;

   PROCEDURE Allocate(VAR ptr:  ADDRESS;
                          size: INTEGER);
   BEGIN
      ALLOCATE(ptr, VAL(CARDINAL, size));
   END Allocate;

   PROCEDURE Deallocate(VAR ptr: ADDRESS);
   BEGIN
      DISPOSE(ptr);
   END Deallocate;

   PROCEDURE Size(variable: ARRAY OF BYTE): LongInt;
      VAR result: LongInt;
   BEGIN
      result := VAL(LongInt, HIGH(variable)+1);
      RETURN result;
   END Size;

END NRSystem.
