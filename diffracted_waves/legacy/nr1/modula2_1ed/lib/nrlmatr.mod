IMPLEMENTATION MODULE NRLMatr;

   FROM NRIO     IMPORT Error;
   FROM NRSystem IMPORT Allocate, Deallocate, LongReal;
   FROM SYSTEM   IMPORT TSIZE;
            
   CONST
      MaxValues = 8000;
      NilLongReal = MIN(LongReal);
      Module    = "NRLMatr";
   TYPE
      LMatrix = POINTER TO LMatrixItem;
      LMatrixItem = RECORD
                      n, m:  INTEGER;
                      lines: PtrToLLines; 
                   END;

   PROCEDURE DisposeLMatrix(VAR matrix: LMatrix);
      VAR i: INTEGER;
   BEGIN
      IF matrix # NIL THEN
         IF matrix^.lines # NIL THEN
		      FOR i := 0 TO matrix^.n-1 DO
		         IF matrix^.lines^[i] # NIL THEN
		            Deallocate(matrix^.lines^[i]);
		         END;
		      END;
		   END;
		   Deallocate(matrix^.lines);
		   Deallocate(matrix);
      ELSE
		   Error("EmptyLMatrix", "NIL pointer allocation!");
      END;
   END DisposeLMatrix;


   PROCEDURE EmptyLMatrix(n, m: INTEGER): LMatrix;
      VAR
         i: INTEGER;
         done: BOOLEAN;
         matrix: LMatrix;
   BEGIN
      Allocate(matrix, (TSIZE(INTEGER)*2+TSIZE(PtrToLLines)));
      IF matrix # NIL THEN
         matrix^.n := n;
         matrix^.m := m;
         Allocate(matrix^.lines, TSIZE(PtrToLLine)*n);
         IF matrix^.lines # NIL THEN
	         done := TRUE;
	         FOR i := 0 TO n-1 DO
	            Allocate(matrix^.lines^[i], TSIZE(LongReal)*m);
	            done := done AND (matrix^.lines^[i] # NIL);
	         END;
	         IF NOT done THEN
	            FOR i := 0 TO n-1 DO
	               IF matrix^.lines^[i] # NIL THEN
	                  Deallocate(matrix^.lines^[i]);
	               END;
	            END;
	            Deallocate(matrix^.lines);
	            Deallocate(matrix);
	            Error ('EmptyLMatrix', 'Not enough memory. LMatrix is not allocated.');
	         END;
	      ELSE
	         Deallocate(matrix);
	         matrix := NIL;
	         Error ('EmptyLMatrix', 'Not enough memory. LMatrix is not allocated.');
	      END;
	   ELSE
	     Error ('EmptyLMatrix', 'Not enough memory. LMatrix is not allocated.');
      END;
      RETURN matrix;
   END EmptyLMatrix;


   PROCEDURE DimensionsOfLMatrix(    matrix: LMatrix;
                                VAR n, m:   INTEGER);
   BEGIN
      IF matrix # NIL THEN
         n := matrix^.n;
         m := matrix^.m;
      ELSE
         n := 0;
         m := 0;
         Error("DimensionsOfLMatrix", "matrix does not exist!");
      END;
   END DimensionsOfLMatrix;


   PROCEDURE LMatrixPtr(matrix: LMatrix): PtrToLLines;
   BEGIN
      IF matrix # NIL THEN
        RETURN matrix^.lines;
      ELSE
         Error("GetLMatrixAttr", "matrix does not exist!");
      END;
   END LMatrixPtr;


   PROCEDURE GetLMatrixAttr(    matrix: LMatrix;
                           VAR n, m:   INTEGER;
                           VAR lines:  PtrToLLines);
   BEGIN
      IF matrix # NIL THEN
         n := matrix^.n;
         m := matrix^.m;
         lines := matrix^.lines;
      ELSE
         n := 0;
         m := 0;
         lines := NIL;
         Error("GetLMatrixAttr", "matrix does not exist!");
      END;
   END GetLMatrixAttr;


   PROCEDURE CreateLMatrix(    n, 
                              m:      INTEGER;
                          VAR matrix: LMatrix;
                          VAR lines:  PtrToLLines);
   BEGIN
      matrix := EmptyLMatrix(n, m);
      lines := LMatrixPtr(matrix);
   END CreateLMatrix;


   PROCEDURE SetElement(matrix: LMatrix;
                        i, j:   INTEGER;
                        number: LongReal);
   BEGIN
      IF matrix # NIL THEN
         matrix^.lines^[i]^[j] := number;
      ELSE
         Error("SetElement", "matrix does not exist!");
      END;
   END SetElement;


   PROCEDURE GetElement(    matrix: LMatrix;
                            i, j:   INTEGER;
                        VAR number: LongReal);
   BEGIN
      IF matrix # NIL THEN
         number  := matrix^.lines^[i]^[j];
      ELSE
         Error("GetElement", "matrix does not exist!");
      END;
   END GetElement;


BEGIN
   NilLMatrix := NIL;
END NRLMatr.
