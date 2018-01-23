IMPLEMENTATION MODULE NRLVect;

   FROM NRSystem IMPORT NilLongReal, Allocate, Deallocate, LongReal, Size;
   FROM NRIO     IMPORT Error;
   FROM SYSTEM   IMPORT ADR, TSIZE;
   FROM Storage  IMPORT DEALLOCATE;

   TYPE
      LVector = POINTER TO LVectorItem;
      LVectorItem = RECORD
                      length: INTEGER; 
                      values: ARRAY [0..MaxLVectorLength-1] OF LongReal;
                   END;

   (*
    * length:  the number of the valid elements in values
    * index range for a vector: 0..length-1
    *    
    *)

   PROCEDURE Min(i, j: INTEGER): INTEGER;
   BEGIN
      IF i <= j THEN RETURN i ELSE RETURN j END;
   END Min;

   PROCEDURE GetAttributes(    values:      ARRAY OF LongReal;
                           VAR length:      INTEGER;
                           VAR withNilREAL: BOOLEAN);
      VAR high: INTEGER;
   BEGIN
      high := HIGH(values);
      length := 0;
      WHILE (length <= high) AND (values[length] # NilLongReal) DO
         INC(length);
      END;
      IF length > high THEN
         withNilREAL := FALSE;
      ELSE
         INC(length);
         withNilREAL := TRUE
      END;
   END GetAttributes;

   PROCEDURE DisposeLVector(VAR vector: LVector);
   BEGIN
      IF vector # NIL THEN
         DEALLOCATE(vector, TSIZE(INTEGER)+TSIZE(LongReal)*vector^.length);
         vector := NIL;
      ELSE
		   Error("DisposeLVector", "Deallocation of NIL pointer!");
      END;
   END DisposeLVector;

   PROCEDURE NewLVector(values: ARRAY OF LongReal): LVector;
      VAR
         vector:  LVector;
         length,
         i:       INTEGER;
         lengthC: INTEGER;
         withNil: BOOLEAN;
   BEGIN
      GetAttributes(values, lengthC, withNil);
      length := lengthC;
      IF withNil THEN DEC(length) END;
      IF length <= MaxLVectorLength THEN
         Allocate(vector, (TSIZE(INTEGER) + TSIZE(LongReal)*length) );
         IF vector # NIL THEN
            FOR i := 0 TO length-1 DO
               vector^.values[i] := values[i];
            END;
            vector^.length := length;
         END;
      ELSE
         Error("NewLVector", "LVector is too big!");
         vector := NIL;
      END;
      RETURN vector;
   END NewLVector;

   PROCEDURE EmptyLVector(length: INTEGER): LVector;
      VAR 
         lengthV: INTEGER;
         vector:  LVector;
   BEGIN
      IF length = 0 THEN
         vector := NIL;
      ELSIF length <= MaxLVectorLength THEN
         lengthV := length;
         Allocate(vector, (TSIZE(INTEGER) + TSIZE(LongReal)*lengthV) );
         IF vector # NIL THEN
            vector^.length := lengthV;
         END;
      ELSE
         Error("EmptyLVector", "LVector is too big!");
         vector := NilLVector;
      END;
      RETURN vector;
    END EmptyLVector;

   PROCEDURE GetLVectorValues(    vector: LVector;
                             VAR length: INTEGER;
                             VAR values: ARRAY OF LongReal);
      VAR 
         i, minHigh, high: INTEGER;
   BEGIN
      IF vector # NIL THEN
         high := HIGH(values);
         length := vector^.length;
         minHigh := Min(high, length-1);
         FOR i := 0 TO minHigh DO
            values[i] := vector^.values[i];
         END;
         IF minHigh < high THEN values[minHigh+1] := NilLongReal END;
      ELSE
         length := 0;
         values[0] := NilLongReal;
      END;
   END GetLVectorValues;

   PROCEDURE LVectorPtr(vector: LVector): PtrToLongReals;
   BEGIN
      IF vector # NIL THEN
         RETURN ADR(vector^.values);
      ELSE
         RETURN NIL;
      END;
   END LVectorPtr;

   PROCEDURE CreateLVector(    n:      INTEGER;
                           VAR vector: LVector;
                           VAR values: PtrToLongReals);
   BEGIN
      vector := EmptyLVector(n);
      values := LVectorPtr(vector);
   END CreateLVector;

   PROCEDURE GetLVectorAttr(    vector: LVector;
                           VAR length: INTEGER;
                           VAR values: PtrToLongReals);
   BEGIN
      IF vector # NIL THEN
         length := vector^.length;
         values := ADR(vector^.values);
      ELSE
         length := 0;
         values := NIL;
      END;
   END GetLVectorAttr;

   PROCEDURE LengthOfLVector(vector: LVector): INTEGER;
   BEGIN
      IF vector # NIL THEN
         RETURN vector^.length;
      ELSE
         RETURN 0
      END;
   END LengthOfLVector;

   PROCEDURE SetLVector(source, dest: LVector);
      VAR sourceL, destL, i: INTEGER;
   BEGIN
      sourceL := LengthOfLVector(source);
      destL := LengthOfLVector(dest);
      IF     (source # NilLVector) 
         AND (dest # NilLVector) 
         AND (sourceL = destL) 
         AND (sourceL # 0) THEN
         FOR i := 0 TO sourceL-1 DO
            dest^.values[i] := source^.values[i];
         END;
      ELSE
         Error("SetLVector", "LVectors are not allocated or lengths are different!");
      END;
   END SetLVector;

   PROCEDURE SetElement(vector: LVector;
                        ix:     INTEGER;
                        number: LongReal);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      vector^.values[ix] := number;
	   ELSE
         Error("SetElement", "vector is Nil or index does not exist!");
	   END;
   END SetElement;

   PROCEDURE GetElement(    vector: LVector;
                            ix:     INTEGER;
                        VAR number: LongReal);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      number := vector^.values[ix];
	   ELSE
         Error("GetElement", "vector is Nil or index does not exist!");
	   END;
   END GetElement;

   PROCEDURE Increase(vector: LVector; 
                      value:   LongReal);
      VAR 
         i, 
         length: INTEGER;
         old:    LongReal;
   BEGIN
      length := vector^.length;
      IF length # 0 THEN
	      FOR i := 0 TO length-1 DO
	         GetElement(vector, i, old);
	         SetElement(vector, i, old+value);
	      END;
	   END;
   END Increase;

   PROCEDURE Decrease(vector: LVector; 
                      value:   LongReal);
      VAR 
         i, 
         length: INTEGER;
         old:    LongReal;
   BEGIN
      length := vector^.length;
      IF length # 0 THEN
	      FOR i := 0 TO length-1 DO
	         GetElement(vector, i, old);
	         SetElement(vector, i, old-value);
	      END;
	   END;
   END Decrease;

   PROCEDURE InsertElement(VAR vector:  LVector; (* in/out *)
                               i:       INTEGER;
                               valueIn: LongReal);
      VAR
         new:    LVector;
         value:  LongReal;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (i >= 0) AND (i <= length) THEN
	      new := EmptyLVector(length+1);
	      k := 0; j := 0;
	      WHILE j <= length DO
	         IF j = i THEN 
	            SetElement(new, j, valueIn); 
	            INC(j) 
	         ELSE
		         GetElement(vector, k, value);
		         SetElement(new, j, value);
		         INC(k);
		         INC(j);
		      END;
	       END;
	       IF vector # NilLVector THEN DisposeLVector(vector); END;
	       vector := new;
	    END;
   END InsertElement;

   PROCEDURE DeleteElement(VAR vector: LVector; (* in/out *)
                               i:      INTEGER);
      VAR 
         new:    LVector;
         value:  LongReal;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (length > 0) AND (i >= 0) AND (i <= length-1) THEN
         new := EmptyLVector(length-1);
         IF (length-1) > 0 THEN
            k := 0; j := 0;
            WHILE k <= length-1 DO
               IF k = i THEN 
                  INC(k);
               ELSE
	               GetElement(vector, k, value);
	               SetElement(new, j, value);
	               INC(k);
	               INC(j);
	            END;
            END;
         END;
         DisposeLVector(vector);
         vector := new;
      END;
   END DeleteElement;

   PROCEDURE DuplicateLVector(    source: LVector;
                        VAR dest:   LVector);
      VAR 
         i, sourceL: INTEGER;
   BEGIN
      IF source # NIL THEN
         sourceL := source^.length;
         Allocate(dest, (TSIZE(INTEGER) + TSIZE(LongReal)*sourceL) );
         IF dest # NIL THEN
		      FOR i := 0 TO sourceL-1 DO
		         dest^.values[i] := source^.values[i]; 
		      END;
		      dest^.length := sourceL;
		   ELSE
            Error("DuplicateLVector", "Out of memory!");
	      END;
	   ELSE
         dest := source;
	   END;
   END DuplicateLVector;

   PROCEDURE CopyLVector(    source: LVector;
                            n:      INTEGER;
                        VAR dest:   LVector);
      VAR 
         i: INTEGER;
   BEGIN
      IF (source # NIL) AND (n # 0) THEN
         IF (n >= source^.length) THEN
            DuplicateLVector(source, dest);
         ELSE
	         Allocate(dest, (TSIZE(INTEGER) + TSIZE(REAL)*n) );
	         IF dest # NIL THEN
			      FOR i := 0 TO n-1 DO
			         dest^.values[i] := source^.values[i]; 
			      END;
			      dest^.length := n;
			   ELSE
	            Error("CopyLVector", "Out of memory!");
		      END;
		   END;
	   ELSE
         dest := NilLVector;
	   END;
   END CopyLVector;

   PROCEDURE MinLVector(vector: LVector): LongReal;
      VAR 
         i:   INTEGER; 
         min: LongReal;
   BEGIN
      IF vector # NIL THEN
	      WITH vector^ DO
		      min := values[0];
		      FOR i := 0 TO length-1 DO
		         IF values[i] < min THEN min := values[i] END;
		      END;
		   END;
		ELSE
		   min := NilLongReal;
		END;
		RETURN min;
   END MinLVector;

   PROCEDURE MaxLVector(vector: LVector): LongReal;
      VAR 
         i:   INTEGER; 
         max: LongReal;
   BEGIN
      IF vector # NIL THEN
	      WITH vector^ DO
		      max := values[0];
		      FOR i := 0 TO length-1 DO
		         IF values[i] > max THEN max := values[i] END;
		      END;
	      END;
		ELSE
		   max := NilLongReal;
		END;
		RETURN max;
   END MaxLVector;


BEGIN
   NilLVector := NIL;
END NRLVect.
