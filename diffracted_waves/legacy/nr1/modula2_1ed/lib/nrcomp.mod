IMPLEMENTATION MODULE NRComp;

   FROM NRSystem IMPORT NilREAL, Allocate, Deallocate, Size;
   FROM NRIO     IMPORT Error;
   FROM SYSTEM   IMPORT ADR, TSIZE;
   FROM Storage  IMPORT DEALLOCATE;

   TYPE
      CVector = POINTER TO CVectorItem;
      CVectorItem = RECORD
                      length: INTEGER; 
                      values: ARRAY [0..MaxCVectorLength-1] OF Complex;
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

   PROCEDURE EqualComplex(a, b: Complex): BOOLEAN;
   BEGIN
      IF (a.r = b.r) AND (a.i = b.i) THEN RETURN TRUE
      ELSE RETURN FALSE
      END;
   END EqualComplex;

   PROCEDURE GetAttributes(    values:      ARRAY OF Complex;
                           VAR length:      INTEGER;
                           VAR withNilComplex: BOOLEAN);
      VAR high: INTEGER;
   BEGIN
      high := HIGH(values);
      length := 0;
      WHILE (length <= high) AND
            (NOT EqualComplex(values[length], NilComplex) ) DO
         INC(length);
      END;
      IF length > high THEN
         withNilComplex := FALSE;
      ELSE
         INC(length);
         withNilComplex := TRUE
      END;
   END GetAttributes;

   PROCEDURE DisposeCVector(VAR vector: CVector);
   BEGIN
      IF vector # NIL THEN
         DEALLOCATE(vector, TSIZE(INTEGER) + TSIZE(Complex)*vector^.length);
         vector := NIL;
      ELSE
		   Error("DisposeCVector", "Deallocation of NIL pointer!");
      END;
   END DisposeCVector;

   PROCEDURE NewCVector(values: ARRAY OF Complex): CVector;
      VAR
         vector:  CVector;
         length,
         i:       INTEGER;
         lengthC: INTEGER;
         withNil: BOOLEAN;
   BEGIN
      GetAttributes(values, lengthC, withNil);
      length := lengthC;
      IF withNil THEN DEC(length) END;
      IF length <= MaxCVectorLength THEN
         Allocate(vector, (TSIZE(INTEGER) + TSIZE(Complex)*length) );
         IF vector # NIL THEN
            FOR i := 0 TO length-1 DO
               vector^.values[i] := values[i];
            END;
            vector^.length := length;
         END;
      ELSE
         Error("NewCVector", "CVector is too big!");
         vector := NIL;
      END;
      RETURN vector;
   END NewCVector;

   PROCEDURE EmptyCVector(length: INTEGER): CVector;
      VAR 
         lengthV: INTEGER;
         vector:  CVector;
   BEGIN
      IF length = 0 THEN
         vector := NIL;
      ELSIF length <= MaxCVectorLength THEN
         lengthV := length;
         Allocate(vector, (TSIZE(INTEGER) + TSIZE(Complex)*lengthV) );
         IF vector # NIL THEN
            vector^.length := lengthV;
         END;
      ELSE
         Error("EmptyCVector", "CVector is too big!");
         vector := NilCVector;
      END;
      RETURN vector;
    END EmptyCVector;

   PROCEDURE GetCVectorValues(    vector: CVector;
                             VAR length: INTEGER;
                             VAR values: ARRAY OF Complex);
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
         IF minHigh < high THEN values[minHigh+1] := NilComplex END;
      ELSE
         length := 0;
         values[0] := NilComplex;
      END;
   END GetCVectorValues;

   PROCEDURE CVectorPtr(vector: CVector): PtrToComplexes;
   BEGIN
      IF vector # NIL THEN
         RETURN ADR(vector^.values);
      ELSE
         RETURN NIL;
      END;
   END CVectorPtr;

   PROCEDURE CreateCVector(    n:      INTEGER;
                          VAR vector: CVector;
                          VAR complexes:  PtrToComplexes);
   BEGIN
      vector := EmptyCVector(n);
      complexes := CVectorPtr(vector);
   END CreateCVector;

   PROCEDURE GetCVectorAttr(    vector: CVector;
                           VAR length: INTEGER;
                           VAR values: PtrToComplexes);
   BEGIN
      IF vector # NIL THEN
         length := vector^.length;
         values := ADR(vector^.values);
      ELSE
         length := 0;
         values := NIL;
      END;
   END GetCVectorAttr;

   PROCEDURE LengthOfCVector(vector: CVector): INTEGER;
   BEGIN
      IF vector # NIL THEN
         RETURN vector^.length;
      ELSE
         RETURN 0
      END;
   END LengthOfCVector;

   PROCEDURE SetCVector(source, dest: CVector);
      VAR sourceL, destL, i: INTEGER;
   BEGIN
      sourceL := LengthOfCVector(source);
      destL := LengthOfCVector(dest);
      IF     (source # NilCVector) 
         AND (dest # NilCVector) 
         AND (sourceL = destL) 
         AND (sourceL # 0) THEN
         FOR i := 0 TO sourceL-1 DO
            dest^.values[i] := source^.values[i];
         END;
      ELSE
         Error("SetCVector", "CVectors are not allocated or lengths are different!");
      END;
   END SetCVector;

   PROCEDURE SetElement(vector: CVector;
                        ix:     INTEGER;
                        number: Complex);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      vector^.values[ix] := number;
	   ELSE
         Error("SetElement", "vector is Nil or index does not exist!");
	   END;
   END SetElement;

   PROCEDURE GetElement(    vector: CVector;
                            ix:     INTEGER;
                        VAR number: Complex);
   BEGIN
      IF (vector # NIL) AND (ix <= vector^.length-1) THEN
	      number := vector^.values[ix];
	   ELSE
         Error("GetElement", "vector is Nil or index does not exist!");
	   END;
   END GetElement;

   PROCEDURE InsertElement(VAR vector:  CVector; (* in/out *)
                               i:       INTEGER;
                               valueIn: Complex);
      VAR 
         new:    CVector;
         value:  Complex;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (i >= 0) AND (i <= length) THEN
	      new := EmptyCVector(length+1);
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
	       IF vector # NilCVector THEN DisposeCVector(vector); END;
	       vector := new;
	    END;
   END InsertElement;

   PROCEDURE DeleteElement(VAR vector: CVector; (* in/out *)
                               i:      INTEGER);
      VAR 
         new:    CVector;
         value:  Complex;
         k, j, 
         length: INTEGER;
   BEGIN
      length := vector^.length;
      IF (length > 0) AND (i >= 0) AND (i <= length-1) THEN
         new := EmptyCVector(length-1);
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
         DisposeCVector(vector);
         vector := new;
      END;
   END DeleteElement;

   PROCEDURE DuplicateCVector(    source: CVector;
                        VAR dest:   CVector);
      VAR 
         i, sourceL: INTEGER;
   BEGIN
      IF source # NIL THEN
         sourceL := source^.length;
         Allocate(dest, (TSIZE(INTEGER) + TSIZE(Complex)*sourceL) );
         IF dest # NIL THEN
		      FOR i := 0 TO sourceL-1 DO
		         dest^.values[i] := source^.values[i]; 
		      END;
		      dest^.length := sourceL;
		   ELSE
            Error("DuplicateCVector", "Out of memory!");
	      END;
	   ELSE
         dest := source;
	   END;
   END DuplicateCVector;

   PROCEDURE CopyCVector(    source: CVector;
                            n:      INTEGER;
                        VAR dest:   CVector);
      VAR 
         i: INTEGER;
   BEGIN
      IF (source # NIL) AND (n # 0) THEN
         IF (n >= source^.length) THEN
            DuplicateCVector(source, dest);
         ELSE
	         Allocate(dest, (TSIZE(INTEGER) + TSIZE(Complex)*n) );
	         IF dest # NIL THEN
			      FOR i := 0 TO n-1 DO
			         dest^.values[i] := source^.values[i]; 
			      END;
			      dest^.length := n;
			   ELSE
	            Error("CopyCVector", "Out of memory!");
		      END;
		   END;
	   ELSE
         dest := NilCVector;
	   END;
   END CopyCVector;

BEGIN
   NilCVector := NIL;
   NilComplex.r := NilREAL;
   NilComplex.i := NilREAL;
END NRComp.
