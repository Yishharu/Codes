IMPLEMENTATION MODULE NRIMatr;

   FROM NRSystem IMPORT Allocate, Deallocate;
   FROM NRIO IMPORT Error;
   FROM SYSTEM IMPORT TSIZE;
            
   CONST
      MaxValues = 8000;
      NilINTEGER   = MIN(INTEGER);
      Module    = "NRIMatr";

   TYPE
      IMatrix = POINTER TO IMatrixItem;
      IMatrixItem = RECORD
                      n, m:  INTEGER;
                      lines: PtrToILines; 
                   END;

   PROCEDURE DisposeIMatrix(VAR matrix: IMatrix);
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
		   Error("EmptyIMatrix", "NIL pointer allocation!");
      END;
   END DisposeIMatrix;


   PROCEDURE EmptyIMatrix(n, m: INTEGER): IMatrix;
      VAR
         i: INTEGER;
         done: BOOLEAN;
         matrix: IMatrix;
   BEGIN
      Allocate(matrix, (TSIZE(INTEGER)*2+TSIZE(PtrToILines)));
      IF matrix # NIL THEN
         matrix^.n := n;
         matrix^.m := m;
         Allocate(matrix^.lines, TSIZE(PtrToILine)*n);
         IF matrix^.lines # NIL THEN
	         done := TRUE;
	         FOR i := 0 TO n-1 DO
	            Allocate(matrix^.lines^[i], TSIZE(INTEGER)*m);
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
	            Error ('EmptyIMatrix', 'Not enough memory. IMatrix is not allocated.');
	         END;
	      ELSE
	         Deallocate(matrix);
	         matrix := NIL;
	         Error ('EmptyIMatrix', 'Not enough memory. IMatrix is not allocated.');
	      END;
	   ELSE
	     Error ('EmptyIMatrix', 'Not enough memory. IMatrix is not allocated.');
      END;
      RETURN matrix;
   END EmptyIMatrix;


   PROCEDURE DimensionsOfIMatrix(    matrix: IMatrix;
                                VAR n, m:   INTEGER);
   BEGIN
      IF matrix # NIL THEN
         n := matrix^.n;
         m := matrix^.m;
      ELSE
         n := 0;
         m := 0;
         Error("DimensionsOfIMatrix", "matrix does not exist!");
      END;
   END DimensionsOfIMatrix;


   PROCEDURE IMatrixPtr(matrix: IMatrix): PtrToILines;
   BEGIN
      IF matrix # NIL THEN
        RETURN matrix^.lines;
      ELSE
         Error("GetIMatrixAttr", "matrix does not exist!");
      END;
   END IMatrixPtr;


   PROCEDURE GetIMatrixAttr(    matrix: IMatrix;
                           VAR n, m:   INTEGER;
                           VAR lines:  PtrToILines);
   BEGIN
      IF matrix # NIL THEN
         n := matrix^.n;
         m := matrix^.m;
         lines := matrix^.lines;
      ELSE
         n := 0;
         m := 0;
         lines := NIL;
         Error("GetIMatrixAttr", "matrix does not exist!");
      END;
   END GetIMatrixAttr;


   PROCEDURE CreateIMatrix(    n, 
                              m:      INTEGER;
                          VAR matrix: IMatrix;
                          VAR lines:  PtrToILines);
   BEGIN
      matrix := EmptyIMatrix(n, m);
      lines := IMatrixPtr(matrix);
   END CreateIMatrix;


BEGIN
   NilIMatrix := NIL;
END NRIMatr.
