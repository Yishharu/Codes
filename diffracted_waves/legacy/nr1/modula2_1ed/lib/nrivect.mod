IMPLEMENTATION MODULE NRIVect;

   FROM NRSystem IMPORT NilINTEGER, Allocate, Deallocate, Size;
   FROM NRIO     IMPORT Error;
   FROM SYSTEM   IMPORT ADR, TSIZE;
   FROM Storage  IMPORT DEALLOCATE;

   TYPE
      IVector = POINTER TO IVectorItem;
      IVectorItem = RECORD
                      length: INTEGER; 
                      values: ARRAY [0..MaxIVectorLength-1] OF INTEGER;
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

   PROCEDURE GetAttributes(    values:      ARRAY OF INTEGER;
                           VAR length:      INTEGER;
                           VAR withNilREAL: BOOLEAN);
      VAR high: INTEGER;
   BEGIN
      high := HIGH(values);
      length := 0;
      WHILE (length <= high) AND (values[length] # NilINTEGER) DO
         INC(length);
      END;
      IF length > high THEN
         withNilREAL := FALSE;
      ELSE
         INC(length);
         withNilREAL := TRUE
      END;
   END GetAttributes;

   PROCEDURE DisposeIVector(VAR vector: IVector);
   BEGIN
      IF vector # NIL THEN
         DEALLOCATE(vector, TSIZE(INTEGER)+TSIZE(INTEGER)*vector^.length);
         vector := NIL;
      ELSE
		   Error("DisposeIVector", "Deallocation of NIL pointer!");
      END;
   END DisposeIVector;

   PROCEDURE NewIVector(values: ARRAY OF INTEGER): IVector;
      VAR
         vector:  IVector;
         length,
         i:       INTEGER;
         lengthC: INTEGER;
         withNil: BOOLEAN;
   BEGIN
      GetAttributes(values, lengthC, withNil);
      length := lengthC;
      IF withNil THEN DEC(length) END;
      IF length <= MaxIVectorLength THEN
         Allocate(vector, (TSIZE(INTEGER) + TSIZE(INTEGER)*length) );
         IF vector # NIL THEN
            FOR i := 0 TO length-1 DO
               vector^.values[i] := values[i];
            END;
            vector^.length := length;
         END;
      ELSE
         Error("NewIVector", "IVector is too big!");
         vector := NIL;
      END;
      RETURN vector;
   END NewIVector;

   PROCEDURE EmptyIVector(length: INTEGER): IVector;
      VAR 
         lengthV: INTEGER;
         vector:  IVector;
   BEGIN
      IF length = 0 THEN
         vector := NIL;
      ELSIF length <= MaxIVectorLength THEN
         lengthV := length;
         Allocate(vector, (TSIZE(INTEGER) + TSIZE(INTEGER)*lengthV) );
         IF vector # NIL THEN
            vector^.length := lengthV;
         END;
      ELSE
         Error("EmptyIVector", "IVector is too big!");
         vector := NilIVector;
      END;
      RETURN vector;
    END EmptyIVector;

   PROCEDURE GetIVectorValues(    vector: IVector;
                             VAR length: INTEGER;
                             VAR values: ARRAY OF INTEGER);
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
         IF minHigh < high THEN values[minHigh+1] := NilINTEGER END;
      ELSE
         length := 0;
         values[0] := NilINTEGER;
      END;
   END GetIVectorValues;

   PROCEDURE IVectorPtr(vector: IVector): PtrToIntegers;
   BEGIN
      IF vector # NIL THEN
         RETURN ADR(vector^.values);
      ELSE
         RETURN NIL;
      END;
   END IVectorPtr;

   PROCEDURE CreateIVector(    n:        INTEGER;
                           VAR vector:   IVector;
                           VAR integers: PtrToIntegers);
   BEGIN
      vector := EmptyIVector(n);
      integers := IVectorPtr(vector);
   END CreateIVector;

   PROCEDURE GetIVectorAttr(    vector: IVector;
                           VAR length: INTEGER;
                           VAR values: PtrToIntegers);
   BEGIN
      IF vector # NIL THEN
         length := vector^.length;
         values := ADR(vector^.values);
      ELSE
         length := 0;
         values := NIL;
      END;
   END GetIVectorAttr;

   PROCEDURE LengthOfIVector(vector: IVector): INTEGER;
   BEGIN
      IF vector # NIL THEN
         RETURN vector^.length;
      ELSE
         RETURN 0
      END;
   END LengthOfIVector;

   PROCEDURE SetIVector(source, dest: IVector);
      VAR sourceL, destL, i: INTEGER;
   BEGIN
      sourceL := LengthOfIVector(source);
      destL := LengthOfIVector(dest);
      IF     (source # NilIVector) 
         AND (dest # NilIVector) 
         AND (sourceL = destL) 
         AND (sourceL # 0) THEN
         FOR i := 0 TO sourceL-1 DO
            dest^.values[i] := source^.values[i];
         END;
      ELSE
         Error("SetIVector", "IVectors are not allocated or lengths are different!");
      END;
   END SetIVector;

   PROCEDURE SetElement(vector: IVector;
                        ix:     INTEGER;
                        number: INTEGER);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      vector^.values[ix] := number;
	   ELSE
         Error("SetElement", "vector is Nil or index does not exist!");
	   END;
   END SetElement;

   PROCEDURE GetElement(    vector: IVector;
                            ix:     INTEGER;
                        VAR number: INTEGER);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      number := vector^.values[ix];
	   ELSE
         Error("GetElement", "vector is Nil or index does not exist!");
	   END;
   END GetElement;

   PROCEDURE Increase(vector: IVector; 
                      value:   INTEGER);
      VAR 
         i, 
         length: INTEGER;
         old:    INTEGER;
   BEGIN
      length := vector^.length;
      IF length # 0 THEN
	      FOR i := 0 TO length-1 DO
	         GetElement(vector, i, old);
	         SetElement(vector, i, old+value);
	      END;
	   END;
   END Increase;

   PROCEDURE Decrease(vector: IVector; 
                      value:   INTEGER);
      VAR 
         i, 
         length: INTEGER;
         old:    INTEGER;
   BEGIN
      length := vector^.length;
      IF length # 0 THEN
	      FOR i := 0 TO length-1 DO
	         GetElement(vector, i, old);
	         SetElement(vector, i, old-value);
	      END;
	   END;
   END Decrease;

   PROCEDURE InsertElement(VAR vector:  IVector; (* in/out *)
                               i:       INTEGER;
                               valueIn: INTEGER);
      VAR 
         new:    IVector;
         value:  INTEGER;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (i >= 0) AND (i <= length) THEN
	      new := EmptyIVector(length+1);
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
	       IF vector # NilIVector THEN DisposeIVector(vector); END;
	       vector := new;
	    END;
   END InsertElement;

   PROCEDURE DeleteElement(VAR vector: IVector; (* in/out *)
                               i:      INTEGER);
      VAR 
         new:    IVector;
         value:  INTEGER;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (length > 0) AND (i >= 0) AND (i <= length-1) THEN
         new := EmptyIVector(length-1);
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
         DisposeIVector(vector);
         vector := new;
      END;
   END DeleteElement;

   PROCEDURE DuplicateIVector(    source: IVector;
                        VAR dest:   IVector);
      VAR 
         i, sourceL: INTEGER;
   BEGIN
      IF source # NIL THEN
         sourceL := source^.length;
         Allocate(dest, (TSIZE(INTEGER) + TSIZE(INTEGER)*sourceL) );
         IF dest # NIL THEN
		      FOR i := 0 TO sourceL-1 DO
		         dest^.values[i] := source^.values[i]; 
		      END;
		      dest^.length := sourceL;
		   ELSE
            Error("DuplicateIVector", "Out of memory!");
	      END;
	   ELSE
         dest := source;
	   END;
   END DuplicateIVector;

   PROCEDURE CopyIVector(    source: IVector;
                            n:      INTEGER;
                        VAR dest:   IVector);
      VAR 
         i: INTEGER;
   BEGIN
      IF (source # NIL) AND (n # 0) THEN
         IF (n >= source^.length) THEN
            DuplicateIVector(source, dest);
         ELSE
	         Allocate(dest, (TSIZE(INTEGER) + TSIZE(REAL)*n) );
	         IF dest # NIL THEN
			      FOR i := 0 TO n-1 DO
			         dest^.values[i] := source^.values[i]; 
			      END;
			      dest^.length := n;
			   ELSE
	            Error("CopyIVector", "Out of memory!");
		      END;
		   END;
	   ELSE
         dest := NilIVector;
	   END;
   END CopyIVector;

   PROCEDURE MinIVector(vector: IVector): INTEGER;
      VAR 
         i:   INTEGER; 
         min: INTEGER;
   BEGIN
      IF vector # NIL THEN
	      WITH vector^ DO
		      min := values[0];
		      FOR i := 0 TO length-1 DO
		         IF values[i] < min THEN min := values[i] END;
		      END;
		   END;
		ELSE
		   min := NilINTEGER;
		END;
		RETURN min;
   END MinIVector;

   PROCEDURE MaxIVector(vector: IVector): INTEGER;
      VAR 
         i:   INTEGER; 
         max: INTEGER;
   BEGIN
      IF vector # NIL THEN
	      WITH vector^ DO
		      max := values[0];
		      FOR i := 0 TO length-1 DO
		         IF values[i] > max THEN max := values[i] END;
		      END;
	      END;
		ELSE
		   max := NilINTEGER;
		END;
		RETURN max;
   END MaxIVector;

BEGIN
   NilIVector := NIL;
END NRIVect.
