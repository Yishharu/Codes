IMPLEMENTATION MODULE NRMatr;

   FROM NRSystem IMPORT Allocate, Deallocate;
   FROM NRIO   IMPORT Error;
   FROM SYSTEM IMPORT TSIZE;
            
   CONST
      MaxValues = 8000;
      NilREAL   = MIN(REAL);
      Module    = "NRMatr";
   TYPE
      Matrix = POINTER TO MatrixItem;
      MatrixItem = RECORD
                      n, m:  INTEGER;
                      lines: PtrToLines; 
                   END;

   PROCEDURE DisposeMatrix(VAR matrix: Matrix);
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
		   Error("EmptyMatrix", "NIL pointer allocation!");
      END;
   END DisposeMatrix;

   PROCEDURE EmptyMatrix(n, m: INTEGER): Matrix;
      VAR
         i: INTEGER;
         done: BOOLEAN;
         matrix: Matrix;
   BEGIN
      Allocate(matrix, (TSIZE(INTEGER)*2+TSIZE(PtrToLines)));
      IF matrix # NIL THEN
         matrix^.n := n;
         matrix^.m := m;
         Allocate(matrix^.lines, TSIZE(PtrToLine)*n);
         IF matrix^.lines # NIL THEN
	         done := TRUE;
	         FOR i := 0 TO n-1 DO
	            Allocate(matrix^.lines^[i], TSIZE(REAL)*m);
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
	            Error ('EmptyMatrix', 'Not enough memory. Matrix is not allocated.');
	         END;
	      ELSE
	         Deallocate(matrix);
	         matrix := NIL;
	         Error ('EmptyMatrix', 'Not enough memory. Matrix is not allocated.');
	      END;
	   ELSE
	     Error ('EmptyMatrix', 'Not enough memory. Matrix is not allocated.');
      END;
      RETURN matrix;
   END EmptyMatrix;


   PROCEDURE DimensionsOfMatrix(    matrix: Matrix;
                                VAR n, m:   INTEGER);
   BEGIN
      IF matrix # NIL THEN
         n := matrix^.n;
         m := matrix^.m;
      ELSE
         n := 0;
         m := 0;
         Error("DimensionsOfMatrix", "matrix does not exist!");
      END;
   END DimensionsOfMatrix;


   PROCEDURE MatrixPtr(matrix: Matrix): PtrToLines;
   BEGIN
      IF matrix # NIL THEN
        RETURN matrix^.lines;
      ELSE
         Error("GetMatrixAttr", "matrix does not exist!");
      END;
   END MatrixPtr;


   PROCEDURE GetMatrixAttr(    matrix: Matrix;
                           VAR n, m:   INTEGER;
                           VAR lines:  PtrToLines);
   BEGIN
      IF matrix # NIL THEN
         n := matrix^.n;
         m := matrix^.m;
         lines := matrix^.lines;
      ELSE
         n := 0;
         m := 0;
         lines := NIL;
         Error("GetMatrixAttr", "matrix does not exist!");
      END;
   END GetMatrixAttr;


   PROCEDURE CreateMatrix(    n, 
                              m:      INTEGER;
                          VAR matrix: Matrix;
                          VAR lines:  PtrToLines);
   BEGIN
      matrix := EmptyMatrix(n, m);
      lines := MatrixPtr(matrix);
   END CreateMatrix;

   PROCEDURE SetElement(matrix: Matrix;
                        i, j:   INTEGER;
                        number: REAL);
   BEGIN
      IF matrix # NIL THEN
         matrix^.lines^[i]^[j] := number;
      ELSE
         Error("SetElement", "matrix does not exist!");
      END;
   END SetElement;


   PROCEDURE GetElement(    matrix: Matrix;
                            i, j:   INTEGER;
                        VAR number: REAL);
   BEGIN
      IF matrix # NIL THEN
         number  := matrix^.lines^[i]^[j];
      ELSE
         Error("GetElement", "matrix does not exist!");
      END;
   END GetElement;


BEGIN
   NilMatrix := NIL;
END NRMatr.
