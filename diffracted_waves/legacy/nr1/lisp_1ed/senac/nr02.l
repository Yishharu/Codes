; nr02.l
; Solution of linear equations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	gaussj: matrix inversion/linear equation solution using gauss-jordan
;	ludcmp: linear equation solution, LU decomposition
;	lubksb: linear equation solution, backsubstitution
;	tridag: linear equation solution, tridiagonal equations
;	mprove: linear equation solution, iterative improvement
;	vander: linear equation solution, Vandermonde matrices
;	toeplz: linear equation solution, Toeplitz matrices
;	svdcmp: singular value decomposition of a matrix
;	svbksb: singular value backsubstitution
;	sparse: linear equation solution, sparse matrix, 
;		conjugate-gradient method
;	    ffuncall: array to array from Senac function list to list - sparse
;------------------------------------------------------------------------------

(defun gaussj (a b)
 (declare (type (simple-array double-float (* *)) a)) 
 (declare (type (simple-array double-float (* *)) b)) 

 (prog* (
  (n (array-dimension a 0))
  (m (array-dimension b 1))
  (ipiv (make-array n :element-type 'fixnum :initial-element 0))
  (indxr (make-array n :element-type 'fixnum :initial-element 0))
  (indxc (make-array n :element-type 'fixnum :initial-element 0))
  (irow 0) (icol 0) (dum 0d0) (pivinv 0d0) (big 0d0))


  (declare (type (simple-array fixnum (*)) ipiv)) 
  (declare (type (simple-array fixnum (*)) indxr)) 
  (declare (type (simple-array fixnum (*)) indxc)) 
  (declare (type fixnum n m irow icol))
  (declare (type double-float dum pivinv big))

  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (fset (fref ipiv j) 0)) 


  (do ((i 1 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))
    (setf big 0d0)
    (do ((j 1 (+ j 1)))
        ((> j n) t)
        (declare (type fixnum j))
      (when 
       (not (= (fref ipiv j) 1))
       (do ((k 1 (+ k 1)))
           ((> k n) t)
           (declare (type fixnum k))
         (cond 
          ((= (fref ipiv k) 0) 
           (when 
            (>= (abs (fref a j k)) big)
            (setf big (abs (fref a j k))) 
            (setf irow j) 
            (setf icol k)))
          ((> (fref ipiv k) 1) 
           (error " Singular matrix in gaussj"))))))
 
    (fset (fref ipiv icol) (+ (fref ipiv icol) 1))
    (when 
     (not (= irow icol))
     (do ((l 1 (+ l 1)))
         ((> l n) t)
         (declare (type fixnum l))
       (setf dum (fref a irow l))
       (fset (fref a irow l) (fref a icol l))
       (fset (fref a icol l) dum))

     (do ((l 1 (+ l 1)))
         ((> l m) t)
         (declare (type fixnum l))
       (setf dum (fref b irow l))
       (fset (fref b irow l) (fref b icol l))
       (fset (fref b icol l) dum)))

    (fset (fref indxr i) irow)
    (fset (fref indxc i) icol)

    (if (= (fref a icol icol) 0d0) 
        (error " singular matrix in gaussj "))
    (setf pivinv (/ 1d0 (fref a icol icol)))
    (fset (fref a icol icol) 1d0)

    (do ((l 1 (+ l 1)))
        ((> l n) t)
        (declare (type fixnum l))
      (fset (fref a icol l) (* (fref a icol l) pivinv)))

    (do ((l 1 (+ l 1)))
        ((> l m) t)
        (declare (type fixnum l))
      (fset (fref b icol l) (* (fref b icol l) pivinv)))

    (do ((ll 1 (+ ll 1)))
        ((> ll n) t)
        (declare (type fixnum ll))
      (when 
       (not (= ll icol)) 
       (setf dum (fref a ll icol)) (fset (fref a ll icol) 0d0)
       (do ((l 1 (+ l 1)))
           ((> l n) t)
           (declare (type fixnum l))
         (fset (fref a ll l) (- (fref a ll l) (* (fref a icol l) dum))))
       (do ((l 1 (+ l 1)))
           ((> l m) t)
           (declare (type fixnum l))
         (fset (fref b ll l) 
               (- (fref b ll l) (* (fref b icol l) dum)))))))

  (do ((l n (+ l (- 1))))
      ((< l 1) t)
      (declare (type fixnum l))
    (when 
     (not (= (fref indxr l) (fref indxc l)))
     (do ((k 1 (+ k 1)))
         ((> k n) t)
         (declare (type fixnum k))
       (setf dum (fref a k (fref indxr l)))
       (fset (fref a k (fref indxr l)) (fref a k (fref indxc l)))
       (fset (fref a k (fref indxc l)) dum)))) 
   
  (return (values a b))))

;------------------------------------------------------------------------------

(defun ludcmp (a &key (tiny 1.0d-20))
 (declare (type (simple-array double-float (* *)) a))
 (declare (type double-float tiny))

 (prog* (
  (n (array-dimension a 0))
  (indx (make-array n :element-type 'fixnum :initial-element 0)) 
  (vv (make-array n :element-type 'double-float :initial-element 0d0)) 
  (d 0d0) (imax 0) (aamax 0d0)
  (sum 0d0) (dum 0d0))

  (declare (type (simple-array fixnum (*)) indx)) 
  (declare (type (simple-array double-float (*)) vv)) 
  (declare (type fixnum idnx imax))
  (declare (type double-float d aamax sum dum))

 
  (setf d 1d0) 
  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf aamax 0d0)
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (if (> (abs (aref a i j)) aamax) 
          (setf aamax (abs (aref a i j)))))
    (if (= aamax 0d0) (error " singular matrix passed to ludcmp "))
    (setf (aref vv i) (/ 1d0 aamax))) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (do ((i 0 (+ i 1)))
        ((> i (1- j)) t)
        (declare (type fixnum i))
      (setf sum (aref a i j))
      (do ((k 0 (+ k 1)))
          ((> k (1- i)) t)
        (setf sum (- sum (* (aref a i k) (aref a k j)))))
      (setf (aref a i j) sum))

    (setf aamax 0d0)
    (do ((i j (+ i 1)))
        ((> i (1- n)) t)
        (declare (type fixnum i))
      (setf sum (aref a i j))

      (do ((k 0 (+ k 1)))
          ((> k (1- j)) t)
          (declare (type fixnum k))
        (setf sum (- sum (* (aref a i k) (aref a k j)))))

      (setf (aref a i j) sum)
      (setf dum (* (aref vv i) (abs sum)))
      (when 
       (>= dum aamax) 
       (setf imax i)
       (setf aamax dum)))

    (when 
     (not (= j imax))
     (do ((k 0 (+ k 1)))
         ((> k (1- n)) t)
         (declare (type fixnum k))
       (setf dum (aref a imax k))
       (setf (aref a imax k) (aref a j k))
       (setf (aref a j k) dum))
     (setf d (* -1d0 d)) 
     (setf (aref vv imax) (aref vv j)))

    (setf (aref indx j) imax)
    (if (= (aref a j j) 0) (setf (aref a j j) tiny))
    (when 
     (not (= (1- n) j))
     (setf dum (/ 1 (aref a j j)))
     (do ((i (1+ j) (+ i 1)))
         ((> i (1- n)) t)
         (declare (type fixnum i))
       (setf (aref a i j) (* (aref a i j) dum))))) 
   
  (return (values a indx d))))

;-----------------------------------------------------------------------------
(defun lubksb (a indx b)
 (declare (type (simple-array double-float (* *)) a)) 
 (declare (type (simple-array fixnum (*)) indx)) ; refers to 0 based array
 (declare (type (simple-array double-float (*)) b)) 

 (prog ((n 0) (ii 0) (sum 0d0) (ll 0))
  (declare (type fixnum n ii ll))
  (declare (type double-float sum))

  (setq n (array-dimension a 0))
  (setf ii 0) 

  (do ((i 1 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))
    (setf ll (1+ (aref indx (1- i))))
    (setf sum (aref b (1- ll)))
    (setf (aref b (1- ll)) (aref b (1- i)))
    (cond 
     ((not (= ii 0)) 
      (do ((j ii (+ j 1)))
          ((> j (1- i)) t)
          (declare (type fixnum j))
        (setf sum (- sum (* (aref a (1- i) (1- j)) (aref b (1- j)))))))
     ((not (= sum 0d0))
      (setf ii i)))
    (setf (aref b (1- i)) sum)) 

  (do ((i (1- n) (1- i)))
      ((< i 0) t)
      (declare (type fixnum i))
    (setf sum (aref b i))
    (do ((j (1+ i) (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf sum (- sum (* (aref a i j) (aref b j)))))
    (setf (aref b i) (/ sum (aref a i i)))) 
   
  (return b)))

;-----------------------------------------------------------------------------
(defun tridag (a b c r)
 (declare (type (simple-array double-float (*)) a)) 
 (declare (type (simple-array double-float (*)) b)) 
 (declare (type (simple-array double-float (*)) c)) 
 (declare (type (simple-array double-float (*)) r)) 
 
 (prog* (
  (n (array-dimension a 0))
  (u (make-array n :element-type 'double-float :initial-element 0d0))
  (gam (make-array n :element-type 'double-float :initial-element 0d0))
  (bet 0d0))

  (declare (type (simple-array double-float (*)) u)) 
  (declare (type (simple-array double-float (*)) gam)) 
  (declare (type fixnum n))
  (declare (type double-float bet))


  (if (= (aref b 0) 0d0) (error " error in tridag - b(1) is zero ")) 
  (setf bet (aref b 0)) 
  (setf (aref u 0) (/ (aref r 0) bet)) 

  (do ((j 1 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref gam j) (/ (aref c (1- j)) bet))
    (setf bet (+ (aref b j) (* (- (aref a j)) (aref gam j))))
    (if (= bet 0d0) (error " error in tridag "))
    (setf (aref u j) (/ (+ (aref r j)
                           (* (- (aref a j)) (aref u (1- j))))
                        bet))) 

  (do ((j (2- n) (1- j)))
      ((< j 0) t)
      (declare (type fixnum j))
    (setf (aref u j) (+ (aref u j)
                        (* (- (aref gam (1+ j))) (aref u (1+ j)))))) 
   
  (return u)))

;-----------------------------------------------------------------------------
(defun mprove (a alud indx b x)
 (declare (type (simple-array double-float (* *)) a)) 
 (declare (type (simple-array double-float (* *)) alud)) 
 (declare (type (simple-array fixnum (*)) indx)) 
 (declare (type (simple-array double-float (*)) b)) 
 (declare (type (simple-array double-float (*)) x))

 (prog* (
  (n (array-dimension a 0))
  (r (make-array n :element-type 'double-float :initial-element 0d0))
  (sdp 0d0))

  (declare (type (simple-array double-float (*)) r)) 
  (declare (type double-float sdp))
  (declare (type fixnum n)) 


  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf sdp (- (aref b i)))
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf sdp (+ sdp (* (aref a i j) (aref x j)))))
    (setf (aref r i) sdp)) 
  (setq r (lubksb alud indx r)) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref x i) (- (aref x i) (aref r i)))) 
   
  (return x)))

;-----------------------------------------------------------------------------
(defun vander (x q)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) q)) 

 (prog* (
  (n (array-dimension x 0))
  (c (make-array n :element-type 'double-float :initial-element 0d0))
  (w (make-array n :element-type 'double-float :initial-element 0d0))
  (zero 0d0) (one 1d0)
  (b 0d0) (s 0d0) (t0 0d0) (xx 0d0) (k 0) (k1 0))


  (declare (type (simple-array double-float (*)) c)) 
  (declare (type (simple-array double-float (*)) w)) 
  (declare (type fixnum n k k1))
  (declare (type double-float zero one b s t0 xx))

  (setq zero 0d0 one 1d0)
 
  (cond 
   ((= n 1)  
    (setf (aref w 0) (aref q 0)))
   (t
    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
        (declare (type fixnum i))
      (setf (aref c i) zero))

    (setf (aref c (1- n)) (- (aref x 0)))
    (do ((i 2 (+ i 1)))
        ((> i n) t)
        (declare (type fixnum i))
      (setf xx (- (aref x (1- i))))
      (do ((j (+ n 1 (- i)) (+ j 1)))
          ((> j (1- n)) t)
          (declare (type fixnum j))
        (setf (aref c (1- j)) (+ (aref c (1- j)) (* xx (aref c j)))))
      (setf (aref c (1- n)) (+ (aref c (1- n)) xx)))

    (do ((i 1 (+ i 1)))
        ((> i n) t)
        (declare (type fixnum i))
      (setf xx (aref x (1- i)))
      (setf t0 one)
      (setf b one)
      (setf s (aref q (1- n)))
      (setf k n)
      (do ((j 2 (+ j 1)))
          ((> j n) t)
          (declare (type fixnum j))
        (setf k1 (1- k))
        (setf b (+ (aref c (1- k)) (* xx b)))
        (setf s (+ s (* (aref q (1- k1)) b)))
        (setf t0 (+ (* xx t0) b))
        (setf k k1))
      (setf (aref w (1- i)) (/ s t0))))) 
   
  (return w)))

;-----------------------------------------------------------------------------
(defun toeplz (r y)
 (declare (type (simple-array double-float (*)) r)) 
 (declare (type (simple-array double-float (*)) y)) 


 (prog* (
  (n (array-dimension y 0))
  (x (make-array n :element-type 'double-float :initial-element 0d0))
  (g (make-array n :element-type 'double-float :initial-element 0d0))
  (h (make-array n :element-type 'double-float :initial-element 0d0))
  (m1 0) (m2 0) (pp 0d0) (qq 0d0) 
  (sxn 0d0) (sd 0d0) (sgn 0d0) (shn 0d0) 
  (sgd 0d0) (k 0) (pt1 0d0) (pt2 0d0) (qt1 0d0) (qt2 0d0))


  (declare (type (simple-array double-float (*)) x)) 
  (declare (type (simple-array double-float (*)) g)) 
  (declare (type (simple-array double-float (*)) h)) 
  (declare (type fixnum n m1 m2 k))
  (declare (type double-float pp qq sxn sd sgn shn sgd pt1 pt2 qt1 qt2))

  
 
  (if (= (aref r (1- n)) 0d0) (go label99)) 
  (setf (aref x 0) (/ (aref y 0) (aref r (1- n)))) 
   
  (if (= n 1) (return x)) 
  (setf (aref g 0) (/ (aref r (2- n)) (aref r (1- n)))) 
  (setf (aref h 0) (/ (aref r n) (aref r (1- n)))) 

  (do ((m 1 (+ m 1)))
      ((> m n) t)
      (declare (type fixnum m))
    (setf m1 (+ m 1))
    (setf sxn (- (aref y (1- m1))))
    (setf sd (- (aref r (1- n))))
    (do ((j 1 (+ j 1)))
        ((> j m) t)
        (declare (type fixnum j))
      (setf sxn (+ sxn (* (aref r (1- (+ (+ n m1) (- j)))) (aref x (1- j)))))
      (setf sd (+ sd
                  (* (aref r (1- (+ (+ n m1) (- j))))
                     (aref g (1- (+ (+ m (- j)) 1)))))))
    
    (if (= sd 0d0) (go label99))
    (setf (aref x (1- m1)) (/ sxn sd))

    (do ((j 1 (+ j 1)))
        ((> j m) t)
        (declare (type fixnum j))
      (setf (aref x (1- j)) (+ (aref x (1- j))
                       (* (- (aref x (1- m1))) (aref g (1- (+ (- m j) 1)))))))
    
    (if (= m1 n) (go end))
    (setf sgn (- (aref r (1- (- n m1)))))
    (setf shn (- (aref r (1- (+ n m1)))))
    (setf sgd (- (aref r (1- n))))

    (do ((j 1 (+ j 1)))
        ((> j m) t)
        (declare (type fixnum j))
      (setf sgn (+ sgn (* (aref r (1- (+ (+ n j) (- m1)))) (aref g (1- j)))))
      (setf shn (+ shn (* (aref r (1- (+ (+ n m1) (- j)))) (aref h (1- j)))))
      (setf sgd (+ sgd
                   (* (aref r (1- (+ (+ n j) (- m1))))
                      (aref h (1- (+ (+ m (- j)) 1)))))))

    
    (if (or (= sd 0d0) (= sgd 0d0)) (go label99))
    (setf (aref g (1- m1)) (/ sgn sgd))
    (setf (aref h (1- m1)) (/ shn sd))
    (setf k m)
    (setf m2 (/ (+ m 1) 2))
    (setf pp (aref g (1- m1)))
    (setf qq (aref h (1- m1)))
    (do ((j 1 (+ j 1)))
        ((> j m2) t)
        (declare (type fixnum j))
      (setf pt1 (aref g (1- j)))
      (setf pt2 (aref g (1- k)))
      (setf qt1 (aref h (1- j)))
      (setf qt2 (aref h (1- k)))
      (setf (aref g (1- j)) (+ pt1 (* (- pp) qt2)))
      (setf (aref g (1- k)) (+ pt2 (* (- pp) qt1)))
      (setf (aref h (1- j)) (+ qt1 (* (- qq) pt2)))
      (setf (aref h (1- k)) (+ qt2 (* (- qq) pt1)))
      (setf k (1- k)))) 
   
  (error " never get here ") 
  label99 
   
  (error " Levinson method fails in toeplz - singular principal minor. ")
end
(return x)))
;------------------------------------------------------------------------------


(defun svdcmp (a)
 (declare (type (simple-array double-float (* *)) a))

  (prog*
    ((m (array-dimension a 0))
     (n (array-dimension a 1))
     
     (w (make-array n :element-type 'double-float :initial-element 0d0))
     (v (make-array (list n n) 
                :element-type 'double-float :initial-element 0d0))
     (rv1 (make-array n :element-type 'double-float :initial-element 0d0))
     (g 0d0) (scale 0d0) (anorm 0d0) (s 0d0) (h 0d0) (f 0d0) (c 0d0) 
     (x 0d0) (y 0d0) (z 0d0) (l 0) (ll 0) (nm 0) (i 0))
    (declare (type fixnum l ll m n nm i))
    (declare (type double-float c anorm f g h s scale x y z))
    (declare (type (simple-array double-float (*)) w))
    (declare (type (simple-array double-float (*)) rv1))
    (declare (type (simple-array double-float (* *)) v))
  
  (do ((i 1 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))

    (setf l (+ i 1))
    (fset (fref rv1 i) (* scale g))
    (setf g 0d0)
    (setf s 0d0)
    (setf scale 0d0)
    (when (<= i m)
      (do ((k i (+ k 1)))
          ((> k m) t)
          (declare (type fixnum k))
        (setf scale (+ scale (abs (fref a k i)))))
      (when (not (= scale 0d0)) 
        (do ((k i (+ k 1)))
            ((> k m) t)
            (declare (type fixnum k))
          (fset (fref a k i) (/ (fref a k i) scale))
          (setf s (+ s (* (fref a k i) (fref a k i)))))

        (setf f (fref a i i))
        (setf g (- (signp (the double-float (sqrt s)) f)))
        (setf h (+ (* f g) (- s)))
        (fset (fref a i i) (+ f (- g)))
        (when (not (= i n)) 
          (do ((j l (+ j 1)))
              ((> j n) t)
              (declare (type fixnum j))
            (setf s 0d0)
            (do ((k i (+ k 1)))
                ((> k m) t)
                (declare (type fixnum k))
              (setf s (+ s (* (fref a k i) (fref a k j)))))

            (setf f (/ s h))
            (do ((k i (+ k 1)))
                ((> k m) t)
               (declare (type fixnum k))
              (fset (fref a k j) (+ (fref a k j) (* f (fref a k i)))))))

        (do ((k i (+ k 1)))
            ((> k m) t)
            (declare (type fixnum k))
        (fset (fref a k i) (* scale (fref a k i))))))
;-------------------------------------------
    (fset (fref w i) (* scale g))
    (setf g 0d0)
    (setf s 0d0)
    (setf scale 0d0)
    (when (and (<= i m) (not (= i n))) 
      (do ((k l (+ k 1)))
          ((> k n) t)
          (declare (type fixnum k))
        (setf scale (+ scale (abs (fref a i k)))))

      (when (not (= scale 0d0)) 
        (do ((k l (+ k 1)))
            ((> k n) t)
            (declare (type fixnum k))
          (fset (fref a i k) (/ (fref a i k) scale))
          (setf s (+ s (* (fref a i k) (fref a i k)))))

        (setf f (fref a i l))
        (setf g (- (signp (the double-float (sqrt s)) f)))
        (setf h (+ (* f g) (- s)))
        (fset (fref a i l) (+ f (- g)))
        (do ((k l (+ k 1)))
            ((> k n) t)
            (declare (type fixnum k))
        (fset (fref rv1 k) (/ (fref a i k) h)))

        (when (not (= i m)) 
          (do ((j l (+ j 1)))
              ((> j m) t)
              (declare (type fixnum j))
            (setf s 0d0)
           (do ((k l (+ k 1)))
                ((> k n) t)
               (declare (type fixnum k))
              (setf s (+ s (* (fref a j k) (fref a i k)))))

            (do ((k l (+ k 1)))
                ((> k n) t)
                (declare (type fixnum k))
            (fset (fref a j k) (+ (fref a j k) (* s (fref rv1 k)))))))

        (do ((k l (+ k 1)))
            ((> k n) t)
            (declare (type fixnum k))
          (fset (fref a i k) (* scale (fref a i k))))))


    (setf anorm (max anorm (+ (abs (fref w i)) (abs (fref rv1 i))))))
;=============================================  

  (do ((i n (+ i (- 1))))
        ((< i 1) t)
       (declare (type fixnum i))
    (when (< i n) 
      (when (not (= g 0d0)) 
        (do ((j l (+ j 1)))
            ((> j n) t)
            (declare (type fixnum j))
          (fset (fref v j i) (/ (/ (fref a i j) (fref a i l)) g)))

        (do ((j l (+ j 1)))
            ((> j n) t)
            (declare (type fixnum j))
          (setf s 0d0)
          (do ((k l (+ k 1)))
              ((> k n) t)
              (declare (type fixnum k))
            (setf s (+ s (* (fref a i k) (fref v k j)))))

          (do ((k l (+ k 1)))
              ((> k n) t)
              (declare (type fixnum k))
            (fset (fref v k j) (+ (fref v k j) (* s (fref v k i)))))))

      (do ((j l (+ j 1)))
          ((> j n) t)
          (declare (type fixnum j))
        (fset (fref v i j) 0d0)
        (fset (fref v j i) 0d0)))

    (fset (fref v i i) 1d0)
    (setf g (fref rv1 i))
    (setf l i))
;**********************************
  (do ((i n (+ i (- 1))))
      ((< i 1) t)
      (declare (type fixnum i))
    (setf l (+ i 1))
    (setf g (fref w i))
    (when (< i n) 
      (do ((j l (+ j 1)))
          ((> j n) t)
          (declare (type fixnum j))
        (fset (fref a i j) 0d0)))

    (cond ((not (= g 0d0))
      (setf g (/ 1d0 g))
      (when (not (= i n)) 
        (do ((j l (+ j 1)))
            ((> j n) t)
            (declare (type fixnum j))
          (setf s 0d0)
          (do ((k l (+ k 1)))
              ((> k m) t)
              (declare (type fixnum k))
              (setf s (+ s (* (fref a k i) (fref a k j)))))

          (setf f (* (/ s (fref a i i)) g))
          (do ((k i (+ k 1)))
             ((> k m) t)
             (declare (type fixnum k))
          (fset (fref a k j) (+ (fref a k j) (* f (fref a k i)))))))

      (do ((j i (+ j 1)))
          ((> j m) t)
          (declare (type fixnum j))
        (fset (fref a j i) (* (fref a j i) g))))

    (t
      (do ((j i (+ j 1)))
          ((> j m) t)
          (declare (type fixnum j))
        (fset (fref a j i) 0d0))))

    (fset (fref a i i) (+ (fref a i i) 1d0)))
;----------------------------------------------------------

  (do ((k n (+ k (- 1))))
      ((< k 1) t)
      (declare (type fixnum k))
    (do ((its 1 (+ its 1)))
        ((> its 30) t)
        (declare (type fixnum its))
        (do ((l k (1- l)))
            ((< l 1) t)
            (declare (type fixnum l))
          (setf nm (1- l))
          (setq ll l)
          (when (= anorm (+ (abs (fref rv1 l)) anorm)) (go label2))
           (when (= anorm (+ (abs (fref w nm)) anorm)) (go label1)))


label1
        (setf c 0d0)
        (setf s 1d0)
        (do ((i ll (+ i 1)))
            ((> i k) t)
            (declare (type fixnum i))
          (setf f (* s (fref rv1 i)))
          (fset (fref rv1 i) (* c (fref rv1 i)))
          (when (= anorm (+ (abs f) anorm)) (go label2))
          (setf g (fref w i))
          (setf h (the double-float (sqrt (+ (* f f) (* g g)))))
          (fset (fref w i) h)
          (setf h (/ 1d0 h))
          (setf c (* g h))
          (setf s (- (* f h)))

          (do ((j 1 (+ j 1)))
              ((> j m) t)
              (declare (type fixnum j))
            (setf y (fref a j nm))
            (setf z (fref a j i))
            (fset (fref a j nm) (+ (* y c) (* z s)))
            (fset (fref a j i) (+ (- (* y s)) (* z c)))))

label2

        (setf z (fref w k))
        (when (= ll k) 
          (when (< z 0d0) 
            (fset (fref w k) (- z))
            (do ((j 1 (+ j 1)))
                ((> j n) t)
                (declare (type fixnum j))
              (fset (fref v j k) (- (fref v j k)))))
          (go label3))

        (if (= its 30) (error "no convergence in 30 iterations of svdcmp"))
        (setf x (fref w ll))
        (setf nm (+ k (- 1)))
        (setf y (fref w nm))
        (setf g (fref rv1 nm))
        (setf h (fref rv1 k))
        (setf f
              (/ (+ (* (+ y (- z)) (+ y z)) (* (+ g (- h)) (+ g h)))
                 (* (* 2d0 h) y)))
        (setf g (the double-float (sqrt (+ (* f f) 1.0d0))))

        (setf f
              (/
               (+ (* (+ x (- z)) (+ x z))
                  (* h (+ (/ y (+ f (signp g f))) (- h))))
               x))
        (setf c 1d0)
        (setf s 1d0)
        (do ((j ll (+ j 1)))
            ((> j nm) t)
            (declare (type fixnum j))
          (setf i (+ j 1))
          (setf g (fref rv1 i))
          (setf y (fref w i))
          (setf h (* s g))
          (setf g (* c g))
          (setf z (the double-float (sqrt (+ (* f f) (* h h)))))
          (fset (fref rv1 j) z)
          (setf c (/ f z))
          (setf s (/ h z))
          (setf f (+ (* x c) (* g s)))
          (setf g (+ (- (* x s)) (* g c)))
          (setf h (* y s))
          (setf y (* y c))

          (do ((jj 1 (+ jj 1)))
              ((> jj n) t)
              (declare (type fixnum jj))
            (setf x (fref v jj j))
            (setf z (fref v jj i))
            (fset (fref v jj j) (+ (* x c) (* z s)))
            (fset (fref v jj i) (+ (- (* x s)) (* z c))))

          (setf z (the double-float (sqrt (+ (* f f) (* h h)))))
          (fset (fref w j) z)

          (when (not (= z 0d0)) 
            (setf z (/ 1d0 z))
            (setf c (* f z))
            (setf s (* h z)))

          (setf f (+ (* c g) (* s y)))
          (setf x (+ (- (* s g)) (* c y)))
          (do ((jj 1 (+ jj 1)))
              ((> jj m) t)
              (declare (type fixnum jj))
            (setf y (fref a jj j))
            (setf z (fref a jj i))
            (fset (fref a jj j) (+ (* y c) (* z s)))
            (fset (fref a jj i) (+ (- (* y s)) (* z c)))))
    (fset (fref rv1 ll) 0d0)
    (fset (fref rv1 k) f)
    (fset (fref w k) x))
  label3)
(return (values a w v))))

;------------------------------------------------------------------------------

(defun svbksb (u w v b)
 (declare (type (simple-array double-float (* *)) u)) 
 (declare (type (simple-array double-float (*)) w)) 
 (declare (type (simple-array double-float (* *)) v)) 
 (declare (type (simple-array double-float (*)) b)) 

 (prog* (
  (n (array-dimension w 0))
  (m (array-dimension b 0))
  (x (make-array n :element-type 'double-float :initial-element 0d0))
  (tmp (make-array n :element-type 'double-float :initial-element 0d0))
  (s 0d0))

  (declare (type (simple-array double-float (*)) x)) 
  (declare (type (simple-array double-float (*)) tmp)) 
  (declare (type fixnum m n))
  (declare (type double-float s))


  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf s 0d0)
    (when 
     (not (= (aref w j) 0d0))
     (do ((i 0 (+ i 1)))
         ((> i (1- m)) t)
         (declare (type fixnum i))
       (setf s (+ s (* (aref u i j) (aref b i)))))

     (setf s (/ s (aref w j))))

    (setf (aref tmp j) s)) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf s 0d0)
    (do ((jj 0 (+ jj 1)))
        ((> jj (1- n)) t)
        (declare (type fixnum jj))
      (setf s (+ s (* (aref v j jj) (aref tmp jj)))))
    (setf (aref x j) s)) 
   
  (return x)))

;-----------------------------------------------------------------------------
(defun sparse (b asub atsub x &key (eps 1.0d-6))
 (declare (type (simple-array double-float (*)) b)) 
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type double-float eps))

 (prog* ( 
  (n (array-dimension b 0))
  (g (make-array n :element-type 'double-float :initial-element 0d0))
  (h (make-array n :element-type 'double-float :initial-element 0d0))
  (xj (make-array n :element-type 'double-float :initial-element 0d0))
  (xi (make-array n :element-type 'double-float :initial-element 0d0))        
  (eps2 0d0) (irst 0) (rp 0d0)
  (bsq 0d0) (anum 0d0) (aden 0d0) (rsq 0d0) 
  (gg 0d0) (dgg 0d0) (gam 0d0))
  (declare (type fixnum n))
  (declare (type (simple-array double-float (*)) g)) 
  (declare (type (simple-array double-float (*)) h)) 
  (declare (type (simple-array double-float (*)) xi)) 
  (declare (type (simple-array double-float (*)) xj)) 
  (declare (type double-float eps2 rp bsq anum aden rsq gg dgg gam))
  (declare (type fixnum irst))


  (setf eps2 (* (dfloat n) (expt eps 2))) 
  (setf irst 0) 
  label1 
  (setf irst (+ irst 1)) 
  (setq xi (ffuncall asub x)) 

  (setf rp 0d0) 
  (setf bsq 0d0) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
    (setf bsq (+ bsq (expt (aref b j) 2)))
    (setf (aref xi j) (+ (aref xi j) (- (aref b j))))
    (setf rp (+ rp (expt (aref xi j) 2)))) 

  (setq g (ffuncall atsub xi)) 


  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref g j) (- (aref g j)))
    (setf (aref h j) (aref g j))) 

  (do ((iter 1 (+ iter 1)))
      ((> iter (* 10 n)) t)
      (declare (type fixnum iter))
    (setq xi (ffuncall asub h))

    (setf anum 0d0)
    (setf aden 0d0)
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf anum (+ anum (* (aref g j) (aref h j))))
      (setf aden (+ aden (expt (aref xi j) 2))))
    (if (= aden 0d0) (error " very singular matrix in sparse "))
    (setf anum (/ anum aden))
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf (aref xi j) (aref x j))
      (setf (aref x j) (+ (aref x j) (* anum (aref h j)))))

    (setq xj (ffuncall asub x))
    (setf rsq 0d0)
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf (aref xj j) (+ (aref xj j) (- (aref b j))))
      (setf rsq (+ rsq (expt (aref xj j) 2))))

    (if (or (= rsq rp) (<= rsq (* bsq eps2))) (go end))

    (when 
     (> rsq rp)
     (do ((j 0 (+ j 1)))
         ((> j (1- n)) t)
        (declare (type fixnum j))
       (setf (aref x j) (aref xi j)))
     (if 
       (>= irst 3) 
       (go end)) 
     (go label1))

    (setf rp rsq)
    (setq xi (ffuncall atsub xj))
    (setf gg 0d0)
    (setf dgg 0d0)
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf gg (+ gg (expt (aref g j) 2)))
      (setf dgg (+ dgg (* (+ (aref xi j) (aref g j)) (aref xi j)))))
    
    (if (= gg 0d0) (return (values x rsq)))
    (setf gam (/ dgg gg))
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf (aref g j) (- (aref xi j)))
      (setf (aref h j) (+ (aref g j) (* gam (aref h j)))))) 
  (error " too many iterations in sparse ") 
end
(return (values x rsq))
  ))

(defun ffuncall (fun arg)
   (make-array (array-dimension arg 0) 
               :element-type 'double-float 
               :initial-contents
                     (cdr (funcall fun (cons '(mlist) (list-array arg))))))
;-----------------------------------------------------------------------------
; end of nr02.l
