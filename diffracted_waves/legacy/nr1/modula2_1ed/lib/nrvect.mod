IMPLEMENTATION MODULE NRVect;

   FROM NRSystem IMPORT NilREAL, LongInt, Allocate, Deallocate, Size;
   FROM NRIO     IMPORT Error;
   FROM SYSTEM   IMPORT ADR, TSIZE;
   FROM Storage  IMPORT DEALLOCATE;

   TYPE
      Vector = POINTER TO VectorItem;
      VectorItem = RECORD
                      length: INTEGER; 
                      values: ARRAY [0..MaxVectorLength-1] OF REAL;
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

   PROCEDURE GetAttributes(    values:      ARRAY OF REAL;
                           VAR length:      INTEGER;
                           VAR withNilREAL: BOOLEAN);
      VAR
         high: INTEGER;
   BEGIN
      high := HIGH(values);
      length := 0;
      WHILE (length <= high) AND (values[length] # NilREAL) DO
         INC(length);
      END;
      IF length > high THEN
         withNilREAL := FALSE;
      ELSE
         INC(length);
         withNilREAL := TRUE
      END;
   END GetAttributes;

   PROCEDURE DisposeVector(VAR vector: Vector);
   BEGIN
      IF vector # NIL THEN
         DEALLOCATE(vector, TSIZE(INTEGER) + TSIZE(REAL)*vector^.length);
         vector := NIL;
      ELSE
		   Error("DisposeVector", "Deallocation of NIL pointer!");
      END;
   END DisposeVector;

   PROCEDURE NewVector(values: ARRAY OF REAL): Vector;
      VAR
         vector:  Vector;
         length,
         i:       INTEGER;
         lengthC: INTEGER;
         withNil: BOOLEAN;
   BEGIN
      GetAttributes(values, lengthC, withNil);
      length := lengthC;
      IF withNil THEN DEC(length) END;
      IF length <= MaxVectorLength THEN
         Allocate(vector,  (TSIZE(INTEGER) + TSIZE(REAL)*length) );
         IF vector # NIL THEN
            FOR i := 0 TO length-1 DO
               vector^.values[i] := values[i];
            END;
            vector^.length := length;
         END;
      ELSE
         Error("NewVector", "Vector is too big!");
         vector := NIL;
      END;
      RETURN vector;
   END NewVector;

   PROCEDURE EmptyVector(length: INTEGER): Vector;
      VAR 
         vector:  Vector;
   BEGIN
      IF length = 0 THEN
         vector := NIL;
      ELSIF length <= MaxVectorLength THEN
         Allocate(vector, (TSIZE(INTEGER) + TSIZE(REAL)*length) );
         IF vector # NIL THEN
            vector^.length := length;
         ELSE
            Error("EmptyVector", "Not enough memory.");
            vector^.length := 0;
         END;
      ELSE
         Error("EmptyVector", "Vector is too big!");
         vector := NilVector;
      END;
      RETURN vector;
    END EmptyVector;

   PROCEDURE GetVectorValues(    vector: Vector;
                             VAR length: INTEGER;
                             VAR values: ARRAY OF REAL);
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
         IF minHigh < high THEN values[minHigh+1] := NilREAL END;
      ELSE
         length := 0;
         values[0] := NilREAL;
      END;
   END GetVectorValues;

   PROCEDURE VectorPtr(vector: Vector): PtrToReals;
   BEGIN
      IF vector # NIL THEN
         RETURN ADR(vector^.values);
      ELSE
         RETURN NIL;
      END;
   END VectorPtr;

   PROCEDURE CreateVector(    n:      INTEGER;
                          VAR vector: Vector;
                          VAR reals:  PtrToReals);
   BEGIN
      vector := EmptyVector(n);
      reals := VectorPtr(vector);
   END CreateVector;

   PROCEDURE GetVectorAttr(    vector: Vector;
                           VAR length: INTEGER;
                           VAR values: PtrToReals);
   BEGIN
      IF vector # NIL THEN
         length := vector^.length;
         values := ADR(vector^.values);
      ELSE
         length := 0;
         values := NIL;
      END;
   END GetVectorAttr;

   PROCEDURE LengthOfVector(vector: Vector): INTEGER;
   BEGIN
      IF vector # NIL THEN
         RETURN vector^.length;
      ELSE
         RETURN 0
      END;
   END LengthOfVector;

   PROCEDURE SetVector(source, dest: Vector);
      VAR sourceL, destL, i: INTEGER;
   BEGIN
      sourceL := LengthOfVector(source);
      destL := LengthOfVector(dest);
      IF     (source # NilVector) 
         AND (dest # NilVector) 
         AND (sourceL = destL) 
         AND (sourceL # 0) THEN
         FOR i := 0 TO sourceL-1 DO
            dest^.values[i] := source^.values[i];
         END;
      ELSE
         Error("SetVector", "Vectors are not allocated or lengths are different!");
      END;
   END SetVector;

   PROCEDURE SetElement(vector: Vector;
                        ix:     INTEGER;
                        number: REAL);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      vector^.values[ix] := number;
	   ELSE
         Error("SetElement", "vector is Nil or index does not exist!");
	   END;
   END SetElement;

   PROCEDURE GetElement(    vector: Vector;
                            ix:     INTEGER;
                        VAR number: REAL);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      number := vector^.values[ix];
	   ELSE
         Error("GetElement", "vector is Nil or index does not exist!");
	   END;
   END GetElement;

   PROCEDURE Increase(vector: Vector; 
                      value:   REAL);
      VAR 
         i, 
         length: INTEGER;
         old:    REAL;
   BEGIN
      length := vector^.length;
      IF length # 0 THEN
	      FOR i := 0 TO length-1 DO
	         GetElement(vector, i, old);
	         SetElement(vector, i, old+value);
	      END;
	   END;
   END Increase;

   PROCEDURE Decrease(vector: Vector; 
                      value:   REAL);
      VAR 
         i, 
         length: INTEGER;
         old:    REAL;
   BEGIN
      length := vector^.length;
      IF length # 0 THEN
	      FOR i := 0 TO length-1 DO
	         GetElement(vector, i, old);
	         SetElement(vector, i, old-value);
	      END;
	   END;
   END Decrease;

   PROCEDURE InsertElement(VAR vector:  Vector; (* in/out *)
                               i:       INTEGER;
                               valueIn: REAL);
      VAR 
         new:    Vector;
         value:  REAL;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (i >= 0) AND (i <= length) THEN
	      new := EmptyVector(length+1);
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
	       IF vector # NilVector THEN DisposeVector(vector); END;
	       vector := new;
	    END;
   END InsertElement;

   PROCEDURE DeleteElement(VAR vector: Vector; (* in/out *)
                               i:      INTEGER);
      VAR 
         new:    Vector;
         value:  REAL;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (length > 0) AND (i >= 0) AND (i <= length-1) THEN
         new := EmptyVector(length-1);
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
         DisposeVector(vector);
         vector := new;
      END;
   END DeleteElement;

   PROCEDURE DuplicateVector(    source: Vector;
                        VAR dest:   Vector);
      VAR 
         i, sourceL: INTEGER;
   BEGIN
      IF source # NIL THEN
         sourceL := source^.length;
         Allocate(dest,  (TSIZE(INTEGER) + TSIZE(REAL)*sourceL) );
         IF dest # NIL THEN
		      FOR i := 0 TO sourceL-1 DO
		         dest^.values[i] := source^.values[i]; 
		      END;
		      dest^.length := sourceL;
		   ELSE
            Error("DuplicateVector", "Out of memory!");
	      END;
	   ELSE
         dest := source;
	   END;
   END DuplicateVector;

   PROCEDURE CopyVector(    source: Vector;
                            n:      INTEGER;
                        VAR dest:   Vector);
      VAR 
         i: INTEGER;
   BEGIN
      IF (source # NIL) AND (n # 0) THEN
         IF (n >= source^.length) THEN
            DuplicateVector(source, dest);
         ELSE
	         Allocate(dest, (TSIZE(INTEGER) + TSIZE(REAL)*n) );
	         IF dest # NIL THEN
			      FOR i := 0 TO n-1 DO
			         dest^.values[i] := source^.values[i]; 
			      END;
			      dest^.length := n;
			   ELSE
	            Error("CopyVector", "Out of memory!");
		      END;
		   END;
	   ELSE
         dest := NilVector;
	   END;
   END CopyVector;

   PROCEDURE MinVector(vector: Vector): REAL;
      VAR 
         i:   INTEGER; 
         min: REAL;
   BEGIN
      IF vector # NIL THEN
	      WITH vector^ DO
		      min := values[0];
		      FOR i := 0 TO length-1 DO
		         IF values[i] < min THEN min := values[i] END;
		      END;
		   END;
		ELSE
		   min := NilREAL;
		END;
		RETURN min;
   END MinVector;

   PROCEDURE MaxVector(vector: Vector): REAL;
      VAR 
         i:   INTEGER; 
         max: REAL;
   BEGIN
      IF vector # NIL THEN
	      WITH vector^ DO
		      max := values[0];
		      FOR i := 0 TO length-1 DO
		         IF values[i] > max THEN max := values[i] END;
		      END;
	      END;
		ELSE
		   max := NilREAL;
		END;
		RETURN max;
   END MaxVector;

BEGIN
   NilVector := NIL;
END NRVect.
