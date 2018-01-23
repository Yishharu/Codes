IMPLEMENTATION MODULE SpctrmM;

   FROM Four1M   IMPORT Four1;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT File, GetReal, Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE window(j: INTEGER; 
                  facm, facp: REAL): REAL; 
   BEGIN 
      RETURN 1.0-ABS((Float(j-1)-facm)*facp); (* Parzen window. *)
      (* RETURN 1.0 *) (* Square window. *)
      (* RETURN 1.0-sqr(((j-1)-facm)*facp) *) (* Welch window. *)
   END window; 

   PROCEDURE Spctrm(P: Vector; m, k: INTEGER; ovrlap: BOOLEAN; file: File); 
      VAR 
         mm, m44, m43, m4, kk, joffn, joff, j2, j, jj: INTEGER; 
         w, sumw, facp, facm, den: REAL; 
         W1, W2: Vector;
         w1, w2, p: PtrToReals; 
   BEGIN 
      GetVectorAttr(P, m, p);
      CreateVector(m, W2, w2);
      CreateVector(4*m, W1, w1);
      IF (W1 # NilVector) AND (W2 # NilVector) THEN
	      mm := m+m; (* Useful factors. *)
	      m4 := mm+mm; 
	      m44 := m4+4; 
	      m43 := m4+3; 
	      den := 0.0; 
	      facm := Float(m)-0.5; (* Factors used by the window function. *)
	      facp := 1.0/(Float(m)+0.5); 
	      sumw := 0.0; (* Accumulate the squared sum of the weights. *)
	      FOR j := 1 TO mm DO 
	         sumw := sumw+(window(j, facm, facp)*window(j, facm, facp))
	      END; 
	      FOR j := 1 TO m DO p^[j-1] := 0.0 END; (* Initialize the spectrum to zero. *)
	      IF ovrlap THEN (* Initialize the "save" half-buffer. *)
	         FOR j := 1 TO m DO GetReal(file, w2^[j-1]); END;
	      END; 
	      FOR kk := 1 TO k DO (* Loop over data set segments in groups of two. *)
	         FOR joff := (-1) TO 0 DO (* Get two complete segments into workspace. *)
	            IF ovrlap THEN 
	               FOR j := 1 TO m DO 
	                  w1^[joff+j+j-1] := w2^[j-1]
	               END; 
	               FOR j := 1 TO m DO 
	                  GetReal(file, w2^[j-1]); 
	               END; 
	               joffn := joff+mm; 
	               FOR j := 1 TO m DO 
	                  w1^[joffn+j+j-1] := w2^[j-1]
	               END
	            ELSE
	               FOR jj := 0 TO (m4-joff-2) DIV 2 DO 
	                  j := joff+2+2*jj; 
	                  GetReal(file, w1^[j-1]); 
	               END;
	            END
	         END; 
	         FOR j := 1 TO mm DO (* Apply the window to the data. *)
	            j2 := j+j; 
	            w := window(j, facm, facp); 
	            w1^[j2-1] := w1^[j2-1]*w; 
	            w1^[j2-2] := w1^[j2-2]*w
	         END; 
	         Four1(W1, mm, 1); (* Fourier transform the
                               windowed data. *)
	         p^[0] := p^[0]+(w1^[0]*w1^[0])+(w1^[1]*w1^[1]); (* Sum results into
                                                             previous segments. *)
	         FOR j := 2 TO m DO 
	            j2 := j+j; 
	            p^[j-1] := p^[j-1]+(w1^[j2-1]*w1^[j2-1])+(w1^[j2-2]*w1^[j2-2])+(w1^[m44-j2-1]*w1^[m44-j2-1])+(w1^[m43-j2-1]*w1^[m43-j2-1])
	         END; 
	         den := den+sumw(* Correct normalization. *)
	      END; 
	      den := Float(m4)*den; 
	      FOR j := 1 TO m DO (* Normalize the output. *)
	         p^[j-1] := p^[j-1]/den
	      END; 
	   ELSE
	      Error('Spctrm', 'Not enough memory.');
	   END;
      IF W1 # NilVector THEN DisposeVector(W1); END; 
      IF W2 # NilVector THEN DisposeVector(W2); END; 
   END Spctrm; 
END SpctrmM.
