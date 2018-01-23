IMPLEMENTATION MODULE NRMath;

   FROM NRSystem  IMPORT LongInt, LongReal, S, DI, SI, Float, Trunc, TruncSD;
   FROM Lib       IMPORT RAND;
   IMPORT MATHLIB;

   CONST wordLength = 16;

   PROCEDURE Round(x: REAL): INTEGER;
      VAR
         truncX: INTEGER;
         float: REAL;
         longX: LongReal;
   BEGIN
      truncX :=  Trunc(x);
      float := Float(truncX);
      IF (x-float) < 0.5 THEN
         RETURN truncX;
      ELSE
         RETURN truncX+1;
      END;
   END Round;

   PROCEDURE RoundSD(x: REAL): LongInt;
      VAR
         truncX: LONGINT;
         float: REAL;
         longX: LongReal;
   BEGIN
      RETURN VAL(LongInt, x);
   END RoundSD;

   PROCEDURE Sqrt(x: REAL): REAL;
      VAR longX: LongReal;
   BEGIN
      longX := VAL(LongReal, x);
      RETURN S(MATHLIB.Sqrt(longX));
   END Sqrt;

   PROCEDURE SqrtSD(x: REAL): LongReal;
      VAR longX: LongReal;
   BEGIN
      longX := VAL(LongReal, x);
      RETURN MATHLIB.Sqrt(longX);
   END SqrtSD;

   PROCEDURE SqrtDS(x: LongReal): REAL;
      VAR short: REAL;
   BEGIN
      short := S(MATHLIB.Sqrt(x));
      RETURN short;
   END SqrtDS;

   PROCEDURE SqrtDD(x: LongReal): LongReal;
   BEGIN
      RETURN MATHLIB.Sqrt(x);
   END SqrtDD;

   PROCEDURE Exp(x: REAL): REAL;
      VAR a, exp, val, abs: LongReal;
   BEGIN
      val := VAL(LongReal, x);
      abs := ABS(val);
      IF abs > 700. THEN
         exp := MAX(LongReal);
      ELSE
         exp := MATHLIB.Exp(abs);
      END;
      IF val < 0.0 THEN
         IF exp = MAX(LongReal) THEN
            RETURN 0.0;
         ELSE
            RETURN S(1.0/exp);
         END;
      ELSE
         RETURN S(exp);
      END;
   END Exp;

   PROCEDURE ExpSD(x: REAL): LongReal;
   BEGIN
      RETURN MATHLIB.Exp(VAL(LongReal, x));
   END ExpSD;

   PROCEDURE ExpDS(x: LongReal): REAL;
   BEGIN
      RETURN S(MATHLIB.Exp(x));
   END ExpDS;

   PROCEDURE ExpDD(x: LongReal): LongReal;
   BEGIN
      RETURN MATHLIB.Exp(x);
   END ExpDD;

   PROCEDURE Ln(x: REAL): REAL;
   BEGIN
      RETURN S(MATHLIB.Log(VAL(LongReal, x)));
   END Ln;

   PROCEDURE LnSD(x: REAL): LongReal;
   BEGIN
      RETURN MATHLIB.Log(VAL(LongReal, x));
   END LnSD;

   PROCEDURE LnDS(x: LongReal): REAL;
   BEGIN
      RETURN S(MATHLIB.Log(x));
   END LnDS;

   PROCEDURE LnDD(x: LongReal): LongReal;
   BEGIN
      RETURN MATHLIB.Log(x);
   END LnDD;

   PROCEDURE Sin(x: REAL): REAL;
   BEGIN
      RETURN S(MATHLIB.Sin(VAL(LongReal, (x))));
   END Sin;

   PROCEDURE SinSD(x: REAL): LongReal;
   BEGIN
      RETURN MATHLIB.Sin(VAL(LongReal, x));
   END SinSD;

   PROCEDURE SinDS(x: LongReal): REAL;
   BEGIN
      RETURN S(MATHLIB.Sin(x));
   END SinDS;

   PROCEDURE SinDD(x: LongReal): LongReal;
   BEGIN
      RETURN MATHLIB.Sin(x);
   END SinDD;

   PROCEDURE Cos(x: REAL): REAL;
   BEGIN
      RETURN S(MATHLIB.Cos(VAL(LongReal, x)));
   END Cos;

   PROCEDURE CosSD(x: REAL): LongReal;
   BEGIN
      RETURN MATHLIB.Cos(VAL(LongReal, x));
   END CosSD;

   PROCEDURE CosDS(x: LongReal): REAL;
   BEGIN
      RETURN S(MATHLIB.Cos(x));
   END CosDS;

   PROCEDURE CosDD(x: LongReal): LongReal;
   BEGIN
      RETURN MATHLIB.Cos(x);
   END CosDD;

   PROCEDURE ArcTan(x: REAL): REAL;
   BEGIN
      RETURN S(MATHLIB.ATan(VAL(LongReal, x)));
   END ArcTan;

   PROCEDURE ArcTanSD(x: REAL): LongReal;
   BEGIN
      RETURN MATHLIB.ATan(VAL(LongReal, x));
   END ArcTanSD;

   PROCEDURE ArcTanDS(x: LongReal): REAL;
   BEGIN
      RETURN S(MATHLIB.ATan(x));
   END ArcTanDS;

   PROCEDURE ArcTanDD(x: LongReal): LongReal;
   BEGIN
      RETURN MATHLIB.ATan(x);
   END ArcTanDD;

   PROCEDURE Random(): REAL;
   BEGIN
      RETURN RAND();
   END Random;

   PROCEDURE DIVD(a, b: LongInt): LongInt;
      VAR realA, realB: LongReal;
         value: LongInt;
   BEGIN
      realA := VAL(LongReal, a);
      realB := VAL(LongReal, b);
      value := VAL(LongInt, (realA/realB));
      RETURN value;
   END DIVD;

   PROCEDURE MODD(a, b: LongInt): LongInt;
      VAR value: LongInt;
   BEGIN
      value := a - b*DIVD(a, b);
      RETURN value;
   END MODD;

   PROCEDURE ShiftLeftOne(VAR bits: BITSET);
      VAR
         i: CARDINAL;
         new: BITSET;
   BEGIN
      new := BITSET{};
      FOR i:= 0 TO wordLength-2 DO
         IF i IN bits THEN
            INCL(new, i+1);
         END;
      END;
      bits := new;
   END ShiftLeftOne;

   PROCEDURE ShiftRightOne(VAR bits: BITSET);
      VAR
         i: CARDINAL;
         new: BITSET;
   BEGIN
      new := BITSET{};
      FOR i := 1 TO wordLength-1 DO
         IF i IN bits THEN
            INCL(new, i-1);
         END;
      END;
      bits := new;
   END ShiftRightOne;

   PROCEDURE ShiftLeft(VAR bits: BITSET;
                           no:   INTEGER);
      VAR i: INTEGER;
   BEGIN
      FOR i:= 1 TO no DO
         ShiftLeftOne(bits);
      END;
   END ShiftLeft;

   PROCEDURE ShiftRight(VAR bits: BITSET;
                            no:   INTEGER);
      VAR i: INTEGER;
   BEGIN
      FOR i:= 1 TO no DO
         ShiftRightOne(bits);
      END;
   END ShiftRight;

   PROCEDURE XOR(VAR bits1: BITSET;
                     bits2: BITSET);
   BEGIN
      bits1 := (bits1 + bits2) / (bits1 * bits2);
   END XOR;

END NRMath.
