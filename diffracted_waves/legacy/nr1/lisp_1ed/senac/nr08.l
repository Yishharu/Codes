; nr08.l
; Sorting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	piksrt: sort an array by straight insertion
;	piksr2: sort two arrays by straight insertion
;	shell: sort an array by Shell's method
;	sort1: sort an array by the heapsort method
;	sort2: sort two arrays the heapsort method
;	indexx: sort and construct an index for an array
;	sort3: sort, use and index to sort 3 or more arrays
;	rank: sort, construct a rank table for an array
;	qcksrt: sort an array by the quicksort method 
;	eclass: determine equivalence classes
;	eclazz: determine equivalence classes
;------------------------------------------------------------------------
(defun piksrt (arr)
 (declare (type (simple-array double-float (*)) arr)) 

 (prog ((n 0) (a 0d0) (isav 0))
  (declare (type fixnum n isav))
  (declare (type double-float a))
  (setq n (array-dimension arr 0))
  (do ((j 2 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf a (aref arr (1- j)))
    (do ((i (1- j) (1- i)))
        ((< i 1) t)
        (declare (type fixnum i))
      (when (<= (aref arr (1- i)) a) 
            (setq isav i)
            (go label10))
      (setf (aref arr i) (aref arr (1- i)))
      (setq isav i))
    (setf isav 0)
    label10
    (setf (aref arr isav) a)) 
   
  (return arr)))

;------------------------------------------------------------------------
(defun piksr2 (arr brr)
 (declare (type (simple-array double-float (*)) arr)) 
 (declare (type (simple-array double-float (*)) brr))

 (prog ((n 0) (a 0d0) (b 0d0) (isav 0))
  (declare (type fixnum n isav))
  (declare (type double-float a b)) 

  (setq n (array-dimension arr 0))

  (do ((j 2 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf a (aref arr (1- j)))
    (setf b (aref brr (1- j)))
    (do ((i (1- j) (1- i)))
        ((< i 1) t)
        (declare (type fixnum i))
      (when (<= (aref arr (1- i)) a) 
            (setq isav i)
            (go label10))
      (setf (aref arr i) (aref arr (1- i)))
      (setf (aref brr i) (aref brr (1- i)))
      (setq isav i))
    (setf isav 0)
    label10
    (setf (aref arr isav) a)
    (setf (aref brr isav) b)) 
  
  (return (values arr brr))))

;------------------------------------------------------------------------
(defun shell (arr &key (aln2i 1.4426950d0) (tiny 1.0d-5))
 (declare (type (simple-array double-float (*)) arr))
 (declare (type double-float aln2i tiny))

 (prog ((n 0) (m 0) (lognb2 0) (t0 0d0) (i 0) (k 0) (l 0))
  (declare (type fixnum n m lognb2 i k l))
  (declare (type double-float t0))

  (setq n (array-dimension arr 0))
  (setf lognb2 (floor (+ (* (log (dfloat n)) aln2i) tiny)))
  (setf m n)
  
  (do ((nn 1 (1+ nn)))
      ((> nn lognb2) t)
      (declare (type fixnum nn))
    (setf m (floor (/ m 2)))
    (setf k (- n m))
    (do ((j 1 (1+ j)))
        ((> j k) t)
        (declare (type fixnum j))
      (setf i j)
label3
      (setf l (+ i m))
      (when
        (< (aref arr (1- l)) (aref arr (1- i)))
        (setf t0 (aref arr (1- i)))
        (setf (aref arr (1- i)) (aref arr (1- l)))
        (setf (aref arr (1- l)) t0)
        (setf i (- i m))
        (if (>= i 1) (go label3)))))

  (return arr)))

;------------------------------------------------------------------------
(defun sort1 (ra)
 (declare (type (simple-array double-float (*)) ra))

 (prog ((n 0) (rra 0d0) (ir 0) (j 0) (l 0) (i 0))
  (declare (type fixnum n ir j l i))
  (declare (type double-float rra))

  (setq n (array-dimension ra 0))
  (setf l (1+ (floor (/ n 2))))
  (setf ir n)
label10
  (cond 
   ((> l 1)
    (setf l (1- l))
    (setf rra (aref ra (1- l))))
   (t
    (setf rra (aref ra (1- ir)))
    (setf (aref ra (1- ir)) (aref ra 0))
    (setf ir (1- ir))
    (when 
     (= ir 1)
     (setf (aref ra 0) rra) 
     (return ra))))

   (setf i l)
   (setf j (+ l l))
label20
   (when
     (<= j ir)
     (if (and (< j ir) 
              (< (aref ra (1- j)) (aref ra j)))
         (setf j (1+ j)))
     (cond
       ((< rra (aref ra (1- j))) 
        (setf (aref ra (1- i)) (aref ra (1- j)))
        (setf i j)
        (setf j (+ j j)))
       (t 
        (setf j (1+ ir))))
     (go label20))
    (setf (aref ra (1- i)) rra)
    (go label10)))
;------------------------------------------------------------------------

(defun sort2 (ra rb)
 (declare (type (simple-array double-float (*)) ra))
 (declare (type (simple-array double-float (*)) rb))

 (prog ((n 0) (rra 0d0) (rrb 0d0) (ir 0) (j 0) (l 0) (i 0))
  (declare (type fixnum n ir j l i))
  (declare (type double-float rra rrb))

  (setq n (array-dimension ra 0))
  (setf l (1+ (floor (/ n 2))))
  (setf ir n)
label10
  (cond 
   ((> l 1)
    (setf l (1- l))
    (setf rra (aref ra (1- l)))
    (setf rrb (aref rb (1- l))))
   (t
    (setf rra (aref ra (1- ir)))
    (setf rrb (aref rb (1- ir)))
    (setf (aref ra (1- ir)) (aref ra 0))
    (setf (aref rb (1- ir)) (aref rb 0))
    (setf ir (1- ir))
    (when 
     (= ir 1)
     (setf (aref ra 0) rra) 
     (setf (aref rb 0) rrb) 
     (return (values ra rb)))))

   (setf i l)
   (setf j (+ l l))
label20
   (when
     (<= j ir)
     (if (and (< j ir) 
              (< (aref ra (1- j)) (aref ra j)))
         (setf j (1+ j)))
     (cond
       ((< rra (aref ra (1- j))) 
        (setf (aref ra (1- i)) (aref ra (1- j)))
        (setf (aref rb (1- i)) (aref rb (1- j)))
        (setf i j)
        (setf j (+ j j)))
       (t 
        (setf j (1+ ir))))
     (go label20))
    (setf (aref ra (1- i)) rra)
    (setf (aref rb (1- i)) rrb)
    (go label10)))
;------------------------------------------------------------------------
(defun indexx (arrin)
 (declare (type (simple-array double-float (*)) arrin))
 
 (prog* (
  (n (array-dimension arrin 0))
  (indx (make-array n :element-type 'fixnum :initial-element 0))
  (l 0) (indxt 0) (ir 0) (q 0d0) (i 0) (j 0)) 

  (declare (type (simple-array fixnum (*)) indx)) 
  (declare (type fixnum n l indxt ir i j))
  (declare (type double-float q))


  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf (aref indx (1- j)) j))

  (if (= n 1) (return indx)) 
  (setf l (+ (floor (/ n 2)) 1)) 
  (setf ir n) 
  label10 

  (cond 
   ((> l 1) 
    (setf l (1- l)) 
    (setf indxt (aref indx (1- l))) 
    (setf q (aref arrin (1- indxt))))
   (t 
    (setf indxt (aref indx (1- ir))) 
    (setf q (aref arrin (1- indxt))) 
    (setf (aref indx (1- ir)) (aref indx 0)) 
    (setf ir (1- ir)) 
    (when 
     (= ir 1) 
     (setf (aref indx 0) indxt) 
     (return indx)))) 

  (setf i l) 
  (setf j (+ l l)) 
  label20 

  (when 
   (<= j ir) 
   (when 
    (< j ir) 
    (if (< (aref arrin (1- (aref indx (1- j)))) 
           (aref arrin (1- (aref indx j))))
        (setf j (1+ j)))) 
   (cond 
    ((< q (aref arrin (1- (aref indx (1- j))))) 
     (setf (aref indx (1- i)) (aref indx (1- j))) 
     (setf i j) 
     (setf j (+ j j)))
    (t 
     (setf j (1+ ir)))) 
   (go label20)) 

  (setf (aref indx (1- i)) indxt) 
  (go label10)))
;------------------------------------------------------------------------
(defun sort3 (ra rb rc)
 (declare (type (simple-array double-float (*)) ra)) 
 (declare (type (simple-array double-float (*)) rb)) 
 (declare (type (simple-array double-float (*)) rc)) 

 (prog* (
  (n (array-dimension ra 0))
  (wksp (make-array n :element-type 'double-float :initial-element 0d0))
  (iwksp (make-array n :element-type 'fixnum :initial-element 0)))

  (declare (type fixnum n))
  (declare (type (simple-array double-float (*)) wksp)) 
  (declare (type (simple-array fixnum (*)) iwksp)) 


  (setq iwksp (indexx ra)) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref wksp j) (aref ra j))) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref ra j) (aref wksp (1- (aref iwksp j))))) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref wksp j) (aref rb j))) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref rb j) (aref wksp (1- (aref iwksp j)))))

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref wksp j) (aref rc j)))

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref rc j) (aref wksp (1- (aref iwksp j)))))
  
  (return (values ra rb rc))))
;------------------------------------------------------------------------
(defun rank (indx)
 (declare (type (simple-array fixnum (*)) indx)) 

 (prog* (
  (n (array-dimension indx 0))
  (irank (make-array n :element-type 'fixnum :initial-element 0)))

  (declare (type fixnum n))
  (declare (type (simple-array fixnum (*)) irank)) 


  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf (aref irank (1- (aref indx (1- j)))) j)) 

  (return irank)))
;------------------------------------------------------------------------


(defun qcksrt (arr &key (m 7) 
                        (nstack 50)
                        (fm 7875d0)
                        (fa 211d0)
                        (fc 1663d0)
                        (fmi 1.2698413d-4)) 
 (declare (type (simple-array double-float (*)) arr)) 
 (declare (type fixnum m nstack))
 (declare (type double-float fm fa fc fmi))

 (prog* (
  (n (array-dimension arr 0))
  (istack (make-array nstack :element-type 'fixnum :initial-element 0))
  (jstack 0) (l 0) (ir 0) 
  (fx 0d0) (a 0d0) (i 0) (j 0) (iq 0))

  (declare (type (simple-array fixnum (*)) istack)) 
  (declare (type fixnum n jstack l ir i j iq))
  (declare (type double-float fx a))


  (setf jstack 0) 
  (setf l 1) 
  (setf ir n) 
  (setf fx 0d0) 
label10 
  (cond 
   ((< (- ir l) m) 
    (tagbody 
     (do ((j (1+ l) (1+ j)))
         ((> j ir) t)
         (declare (type fixnum j))
      (setf a (aref arr (1- j))) 
      (do ((ii (1- j) (1- ii)))
          ((< ii 1) t)
          (declare (type fixnum ii))
       (when (<= (aref arr (1- ii)) a) 
             (setf i ii)
             (go label12)) 
       (setf (aref arr ii) (aref arr (1- ii))))
 
      (setf i 0) 
 label12 
      (setf (aref arr i) a)))

     (if (= jstack 0) (return arr)) 
     (setf ir (aref istack (1- jstack))) 
     (setf l (aref istack (2- jstack))) 
     (setf jstack (- jstack 2)))
   (t
    (tagbody
     (setf i l) 
     (setf j ir) 
     (setf fx (real-remainder (+ (* fx fa) fc) fm))
     (setf iq (floor (+ l (* (+ (- ir l) 1) (* fx fmi))))) 
     (setf a (aref arr (1- iq))) 
     (setf (aref arr (1- iq)) (aref arr (1- l))) 
     label20 
     label21 

     (if (> j 0) 
      (when 
       (< a (aref arr (1- j))) 
       (setf j (1- j)) 
       (go label21))) 

     (when 
      (<= j i) 
      (setf (aref arr (1- i)) a) 
      (go label30))
     (setf (aref arr (1- i)) (aref arr (1- j))) 
     (setf i (+ i 1)) 
 label22 

     (when 
      (<= i n) 
      (when 
       (> a (aref arr (1- i))) 
       (setf i (+ i 1)) 
       (go label22)))

     (when 
      (<= j i) 
      (setf (aref arr (1- j)) a) 
      (setf i j) 
      (go label30)) 
     (setf (aref arr (1- j)) (aref arr (1- i))) 
     (setf j (1- j)) 
     (go label20) 
 label30 
     (setf jstack (+ jstack 2)) 
     (if (> jstack nstack) (error " nstack must be made larger ")) 
     (cond 
      ((>= (- ir i) (- i l)) 
       (setf (aref istack (1- jstack)) ir) 
       (setf (aref istack (2- jstack)) (1+ i)) 
       (setf ir (1- i)) )
      (t
       (setf (aref istack (1- jstack)) (1- i)) 
       (setf (aref istack (2- jstack)) l) 
       (setf l (1+ i)))))))
   
  (go label10)))
;------------------------------------------------------------------------
(defun eclass (n lista listb)
  (declare (type (simple-array fixnum (*)) lista)) 
  (declare (type (simple-array fixnum (*)) listb)) 
  (declare (type fixnum n))

 (prog ((nf (make-array n :element-type 'fixnum :initial-element 0)) 
        (m 0) (j 0) (k 0))
  (declare (type (simple-array fixnum (*)) nf)) 
  (declare (type fixnum m j k))
  (setq m (array-dimension lista 0))

  (do ((k 1 (+ k 1)))
      ((> k n) t)
      (declare (type fixnum k))
    (setf (aref nf (1- k)) k)) 

  (do ((l 1 (+ l 1)))
      ((> l m) t)
      (declare (type fixnum l))
    (setf j (aref lista (1- l)))
    label1
    (when (not (= (aref nf (1- j))  j))
          (setf j (aref nf (1- j)))
          (go label1))
    (setf k (aref listb (1- l)))
    label2
    (when (not (= (aref nf (1- k)) k))
          (setf k (aref nf (1- k)))
          (go label2))
    (if (not (= j k)) 
        (setf (aref nf (1- j)) k)))
 
  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    label3
    (when (not (= (aref nf (1- j)) (aref nf (1- (aref nf (1- j))))))
          (setf (aref nf (1- j)) (aref nf (1- (aref nf (1- j))))) 
          (go label3))) 
   
  (return nf)))

;------------------------------------------------------------------------------

(defun eclazz (n equiv)
 (declare (type fixnum n))
; equiv is a logical function of two fixnum variables

 (prog ((nf (make-array n :initial-element 0 :element-type 'fixnum)))
  (declare (type (simple-array fixnum (*)) nf))
   
  (setf (aref nf 0) 1) 

  (do ((jj 2 (+ jj 1)))
      ((> jj n) t)
      (declare (type fixnum jj))
    (setf (aref nf (1- jj)) jj)
    (do ((kk 1 (+ kk 1)))
        ((> kk (1- jj)) t)
        (declare (type fixnum kk))
      (setf (aref nf (1- kk)) (aref nf (1- (aref nf (1- kk)))))
      (if (funcall equiv jj kk) 
          (setf (aref nf (1- (aref nf (1- (aref nf (1- kk)))))) jj)))) 

  (do ((jj 1 (+ jj 1)))
      ((> jj n) t)
      (declare (type fixnum jj))
    (setf (aref nf (1- jj)) (aref nf (1- (aref nf (1- jj)))))) 

  (return nf)))
;-----------------------------------------------------------------------------
; end of nr08.l

