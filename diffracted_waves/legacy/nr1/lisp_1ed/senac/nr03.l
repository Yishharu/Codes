; nr03.l
; Interpolation and extrapolation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	polint: interpolation, polynomial
;	ratint: interpolation, rational function
;	spline: interpolation, construct a cubic spline
;	splint: evaluate a cubic spline
;	locate: search an ordered table, bisection
;	hunt: search an ordered table, correlated calls
;	polcoe, polynomial coefficients from a table of values
;	polcof: polynomial coefficients from a table of values
;	polin2: interpolation, two dimensional polynomial
;	bcucof: interpolation, two dimensional construct bicubic
;	bcuint: interpolation, two dimensional evalute bicubic
;	splie2 interpolation, two dimensional, construct two dimensional spline
;	splin2 interpolation, two dimensional, evaluate two dimensional spline
;------------------------------------------------------------------------------
(defun polint (xa ya n x)
 (declare (type (simple-array double-float (*)) xa)) 
 (declare (type (simple-array double-float (*)) ya)) 
 (declare (type double-float x))
 (declare (type fixnum n))

 (prog* ((y 0d0) (dy 0d0) 
        (c (make-array n :element-type 'double-float :initial-element 0d0))
        (d (make-array n :element-type 'double-float :initial-element 0d0))
        (dif 0d0) (dift 0d0)
        (ns 0) (ho 0d0) (hp 0d0) (w 0d0) (den 0d0))
  (declare (type (simple-array double-float (*)) c)) 
  (declare (type (simple-array double-float (*)) d))
  (declare (type double-float y dy dif dift ho hp w den))
  (declare (type fixnum ns))


  (setf ns 1) 
  (setf dif (abs (- x (aref xa 0)))) 
  (do ((i 1 (+ i 1)))
      ((> i n) t)
      (declare (type integer i))
    (setf dift (abs (- x (aref xa (1- i)))))
    (when 
      (< dift dif)
      (setf ns i) 
      (setf dif dift))
    (setf (aref c (1- i)) (aref ya (1- i)))
    (setf (aref d (1- i)) (aref ya (1- i)))) 

  (setf y (aref ya (1- ns))) 
  (setf ns (1- ns)) 
  (do ((m 1 (+ m 1)))
      ((> m (1- n)) t)
      (declare (type integer m))
    (do ((i 1 (+ i 1)))
        ((> i (- n m)) t)
        (declare (type integer i))
      (setf ho (- (aref xa (1- i)) x))
      (setf hp (- (aref xa (1- (+ i m))) x))
      (setf w (- (aref c i) (aref d (1- i))))
      (setf den (- ho hp))
      (if (= den 0d0) (error " den = 0d0 in polint "))
      (setf den (/ w den))
      (setf (aref d (1- i)) (* hp den))
      (setf (aref c (1- i)) (* ho den)))

    (cond 
     ((< (* 2 ns) (- n m)) 
      (setf dy (aref c ns)))
     (t 
      (setf dy (aref d (1- ns)))
      (setf ns (1- ns))))
    (setf y (+ y dy))) 
  
  (return (values y dy))))

;----------------------------------------------------------------------------
(defun ratint (xa ya x &key (tiny 1.0d-25))
 (declare (type (simple-array double-float (*)) xa)) 
 (declare (type (simple-array double-float (*)) ya)) 

 (prog* 
  ((ns 0) (h 0d0) (dd 0d0) (y 0d0) (dy 0d0) 
  (n (array-dimension xa 0))
  (c (make-array n :element-type 'double-float :initial-element 0d0))
  (d (make-array n :element-type 'double-float :initial-element 0d0)) 
  (w 0d0) (t0 0d0) (hh 0d0) (ret nil))

  (declare (type (simple-array double-float (*)) c)) 
  (declare (type (simple-array double-float (*)) d)) 
  (declare (type double-float y dy dd h t0 w hh))
  (declare (type integer ns n))
  (declare (type symbol ret))

  (setf ns 1) 
  (setf hh (abs (- x (fref xa 1))))
  (setq ret
   (do ((i 1 (+ i 1)))
       ((> i n) nil)
       (declare (type integer i))
     (setf h (abs (- x (fref xa i))))

     (cond 
      ((= h 0d0)
       (setf y (fref ya i))
       (setf dy 0.0d0) 
       (return t))
      ((< h hh)  
       (setf ns i) 
       (setf hh h)))
     (setf (aref c (1- i)) (fref ya i))
     (setf (aref d (1- i)) (+ (fref ya i) tiny))))

  (if ret (return (values y dy)))


  (setf y (fref ya ns)) 
  (setf ns (1- ns)) 
  (do ((m 1 (+ m 1)))
      ((> m (1- n)) t)
      (declare (type integer m))
    (do ((i 1 (1+ i)))
        ((> i (- n m)) t)
        (declare (type integer m))
      (setf w (- (fref c (+ i 1)) (fref d i)))
      (setf h (- (fref xa (+ i m)) x))
      (setf t0 (/ (* (- (fref xa i) x) (fref d i)) h))
      (setf dd (- t0 (fref c (1+ i))))
      (if (= dd 0d0) (error " error in ratint "))
      (setf dd (/ w dd))
      (setf (aref d (1- i)) (* (fref c (1+ i)) dd))
      (setf (aref c (1- i)) (* t0 dd)))

    (cond 
     ((< (* 2 ns) (- n m))
      (setf dy (fref c (1+ ns)))) 
     (t 
      (setf dy (fref d ns))
      (setf ns (1- ns))))
    (setf y (+ y dy))) 
   
  (return (values y dy))))


;----------------------------------------------------------------------------
(defun spline (x y yp1 ypn)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type double-float yp1 yp2))

 (prog* (
  (n (array-dimension x 0))
  (y2 (make-array n :element-type 'double-float :initial-element 0d0))
  (u (make-array n :element-type 'double-float :initial-element 0d0))
  (p 0d0) (qn 0d0) (un 0d0) (sig 0d0))

  (declare (type (simple-array double-float (*)) y2)) 
  (declare (type (simple-array double-float (*)) u)) 
  (declare (type integer n))
  (declare (type double-float p qn un sig))


  (cond 
   ((> yp1 9.9d29) 
    (setf (aref y2 0) 0d0)
    (setf (aref u 0) 0d0))
   (t 
    (setf (aref y2 0) (- 0.5d0))
    (setf (aref u 0) (* (/ 3 (+ (aref x 1) (- (aref x 0))))
                        (+ (/ (+ (aref y 1) (- (aref y 0)))
                              (+ (aref x 1) (- (aref x 0))))
                           (- yp1)))))) 

  (do ((i 1 (1+ i)))
      ((> i (2- n)) t)
      (declare (type integer i))
    (setf sig (/ (+ (aref x i) (- (aref x (1- i))))
                 (+ (aref x (+ i 1)) (- (aref x (1- i))))))
    (setf p (+ (* sig (aref y2 (1- i))) 2d0))
    (setf (aref y2 i) (/ (1- sig) p))
    (setf (aref u i) (/ (+ (/ (* 6d0
                                 (+ (/ (+ (aref y (1+ i)) (- (aref y i)))
                                       (+ (aref x (1+ i)) (- (aref x i))))
                                    (/ (-
                                          (+
                                           (aref y i)
                                           (- (aref y (1- i)))))
                                       (+ (aref x i)
                                          (- (aref x (1- i)))))))
                              (+ (aref x (+ i 1))
                                 (- (aref x (1- i)))))
                           (* (- sig) (aref u (1- i))))
                        p))) 

  (cond 
   ((> ypn 9.9d29) 
    (setf qn 0d0) 
    (setf un 0d0))
   (t 
    (setf qn 0.5d0)
    (setf un (* (/ 3d0 (+ (aref x (1- n)) (- (aref x (2- n)))))
                (+ ypn
                   (/ (- (+ (aref y (1- n)) (- (aref y (2- n)))))
                      (+ (aref x (1- n)) (- (aref x (2- n)))))))))) 

  (setf (aref y2 (1- n)) (/ (+ un (* (- qn) (aref u (2- n))))
                       (+ (* qn (aref y2 (2- n))) 1d0)))
 
  (do ((k (2- n) (1- k)))
      ((< k 0) t)
      (declare (type integer k))
    (setf (aref y2 k) (+ (* (aref y2 k) (aref y2 (+ k 1))) (aref u k)))) 
   
  (return y2)))

;------------------------------------------------------------------------------
(defun splint (xa ya y2a x)
 (declare (type (simple-array double-float (*)) xa)) 
 (declare (type (simple-array double-float (*)) ya)) 
 (declare (type (simple-array double-float (*)) y2a)) 
 (declare (type double-float x))

 (prog ((n 0) (y 0d0) (a 0d0) (b 0d0) (klo 0) (khi 0) (h 0d0) (k 0))
  (declare (type integer n klo khi k))
  (declare (type double-float y a b h))

  (setq n (array-dimension xa 0))
  (setf klo 1) 
  (setf khi n) 
  label1 

  (when (> (- khi klo) 1)
   (setf k (floor (/ (+ khi klo) 2)))
   (if 
     (> (aref xa (1- k)) x) 
     (setf khi k)
     (setf klo k))
   (go label1)) 

  (setq khi (1- khi) klo (1- klo))

  (setf h (- (aref xa khi) (aref xa klo))) 
  (if (= h 0d0) (error " bad xa input to splint ")) 
  (setf a (/ (- (aref xa khi) x) h)) 
  (setf b (/ (- x (aref xa klo)) h)) 
  (setf y (+ (+ (* a (aref ya klo)) (* b (aref ya khi)))
             (/ (* (+ (* (- (expt a 3) a) (aref y2a klo))
                      (* (- (expt b 3) b) (aref y2a khi)))
                   (expt h 2))
                6))) 
   
  (return (the double-float y))))
;-----------------------------------------------------------------------------
(defun locate (xx x)
 (declare (type (simple-array double-float (*)) xx)) 
 (declare (type double-float x))

 (prog ((j 0) (jl 0) (ju 0) (n 0) (jm 0))
  (declare (type integer j jl ju n jm))

  (setq n (array-dimension xx 0))
  (setf jl 0) 
  (setf ju (+ n 1)) 
label10 
  (when 
   (> (- ju jl) 1)
   (setf jm (floor (/ (+ ju jl) 2)))
   (if (eqv (> (aref xx (1- n)) (aref xx 0))
            (> x (aref xx (1- jm))))
       (setf jl jm)
       (setf ju jm))
  (go label10)) 
  (setf j jl) 
   
  (return (the integer j))))


;------------------------------------------------------------------------------

(defun hunt (xx x jlo)
 (declare (type (simple-array double-float (*)) xx)) 
 (declare (type double-float x)) 
 (declare (type integer jlo))

 (prog ((n 0) (ascnd nil) (inc 0) (jhi 0) (jm 0))
  (declare (type integer n inc jhi jm)) 
  (declare (type symbol ascnd))

  (setq n (array-dimension xx 0))
 
  (setf ascnd (> (aref xx (1- n)) (aref xx 0))) 

  (when 
   (or (<= jlo 0) (> jlo n)) 
   (setf jlo 0)
   (setf jhi (+ n 1))
   (go label3)) 

  (setf inc 1) 
  (cond 
   ((eqv (>= x (aref xx (1- jlo))) ascnd)
(tagbody
label1
    (setf jhi (+ jlo inc))
    (cond 
     ((> jhi n) 
      (setf jhi (+ n 1)))
    ((eqv (> x (aref xx (1- jhi))) ascnd)
     (setf jlo jhi) 
     (setf inc (+ inc inc))
     (go label1))))) 
   (t 
    (setf jhi jlo) 
(tagbody
label2 
    (setf jlo (- jhi inc))
    (cond 
      ((< jlo 1) 
       (setf jlo 0)) 
      ((eqv (< x (aref xx (1- jlo))) ascnd)
       (setf jhi jlo) 
       (setf inc (+ inc inc)) (go label2)))))) 
label3 
  
  (if (= (- jhi jlo) 1) (return (the integer jlo))) 
  (setf jm (floor (/ (+ jhi jlo) 2)))
 
  (if 
   (> x (aref xx (1- jm))) 
   (setf jlo jm)
   (setf jhi jm)) 
  
  (go label3)))

;-----------------------------------------------------------------------------
(defun polcoe (x y)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 

 (prog* (
  (n (array-dimension x 0))
  (cof (make-array n :element-type 'double-float :initial-element 0d0))
  (s (make-array n :element-type 'double-float :initial-element 0d0)) 
  (b 0d0) (ff 0d0) (phi 0d0))

  (declare (type (simple-array double-float (*)) cof)) 
  (declare (type (simple-array double-float (*)) s))
  (declare (type integer n))
  (declare (type double-float b ff phi))

  (setf (aref s (1- n)) (- (aref x 0))) 
  (do ((i 2 (+ i 1)))
      ((> i n) t)
      (declare (type integer i))
    (do ((j (- (1+ n) i) (+ j 1)))
        ((> j (1- n)) t)
        (declare (type integer j))
      (setf (aref s (1- j)) (- (aref s (1- j)) (* (aref x (1- i)) (aref s j)))))

    (setf (aref s (1- n)) (- (aref s (1- n)) (aref x (1- i))))) 

  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type integer j))
    (setf phi (dfloat n))
    (do ((k (1- n) (1- k)))
        ((< k 1) t)
        (declare (type integer k))
      (setf phi (+ (* (dfloat k) (aref s k)) (* (aref x (1- j)) phi))))

    (setf ff (/ (aref y (1- j)) phi))
    (setf b 1d0)

    (do ((k n (1- k)))
        ((< k 1) t)
        (declare (type integer k))
      (setf (aref cof (1- k)) (+ (aref cof (1- k)) (* b ff)))
      (setf b (+ (aref s (1- k)) (* (aref x (1- j)) b))))) 
   
  (return cof)))

;-----------------------------------------------------------------------------
(defun polcof (xa ya)
 (declare (type (simple-array double-float (*)) xa)) 
 (declare (type (simple-array double-float (*)) ya))


 (prog* (
  (n (array-dimension xa 0))
  (cof (make-array n :element-type 'double-float :initial-element 0d0))
  (x (make-array n :element-type 'double-float :initial-element 0d0))
  (y (make-array n :element-type 'double-float :initial-element 0d0)) 
  (xmin 0d0) (k 0) (cofj 0d0))

  (declare (type (simple-array double-float (*)) cof)) 
  (declare (type (simple-array double-float (*)) x)) 
  (declare (type (simple-array double-float (*)) y)) 
  (declare (type integer n k))
  (declare (type double-float xmin cofj))


  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type integer i))
    (setf (aref x i) (aref xa i))
    (setf (aref y i) (aref ya i))) 

  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type integer j))

    (setq cofj (polint x y (1+ (- n j)) 0d0))
    (setf (aref cof (1- j)) cofj)
    (setf xmin 1.0d38)
    (setf k 0)
    (do ((i 1 (+ i 1)))
        ((> i (1+ (- n j))) t)
        (declare (type integer i))
      (when (< (abs (aref x (1- i))) xmin)
       (setf xmin (abs (aref x (1- i)))) 
       (setf k i))
      (if (not (= (aref x (1- i)) 0d0))
        (setf (aref y (1- i)) 
              (/ (- (aref y (1- i)) (aref cof (1- j))) (aref x (1- i))))))
    (do ((i (1+ k) (+ i 1)))
        ((> i (1+ (- n j))) t)
        (declare (type integer i))
      (setf (aref y (2- i)) (aref y (1- i)))
      (setf (aref x (2- i)) (aref x (1- i))))) 
  
  (return cof)))

;-----------------------------------------------------------------------------
(defun polin2 (x1a x2a ya x1 x2)
 (declare (type (simple-array double-float (*)) x1a)) 
 (declare (type (simple-array double-float (*)) x2a)) 
 (declare (type (simple-array double-float (* *)) ya)) 

 (prog* (
  (m (array-dimension x1a 0))
  (n (array-dimension x2a 0))
  (yntmp 
    (make-array n :element-type 'double-float :initial-element 0d0))
  (ymtmp 
    (make-array m :element-type 'double-float :initial-element 0d0))  
  (y 0d0) (dy 0d0) (ymtmpj 0d0))

  (declare (type (simple-array double-float (*)) yntmp)) 
  (declare (type (simple-array double-float (*)) ymtmp)) 
  (declare (type integer m n))
  (declare (type double-float y dy ymtmpj))


  (do ((j 0 (+ j 1)))
      ((> j (1- m)) t)
    (do ((k 0 (+ k 1)))
        ((> k (1- n)) t)
      (setf (aref yntmp k) (aref ya j k)))
    (multiple-value-setq (ymtmpj dy) (polint x2a yntmp n x2))
    (setf (aref ymtmp j) ymtmpj)) 

  (multiple-value-setq (y dy) (polint x1a ymtmp m x1)) 
  
  (return (values y dy))))

;-----------------------------------------------------------------------------
 
  (fproclaim '(type (simple-array double-float (16 16)) bcucof-wt)) 
  (fproclaim '(special bcucof-wt))

  (setq bcucof-wt (make-array 
             (list 16 16) :element-type 'double-float :initial-contents

   (split-list (mapcar #'dfloat 
  '( 1 0 -3 2 0 0 0 0 -3 0 9 -6 2 0 -6 4 0 0 0 0 0 0 0 0
    3 0 -9 6 -2 0 6 -4 0 0 0 0 0 0 0 0 0 0 9 -6 0 0 -6 
   4 0 0 3 -2 0 0 0 0 0 0 -9 6 0 0 6 -4 0 0 0 0 1 0 
   -3 2 -2 0 6 -4 1 0 -3 2 0 0 0 0 0 0 0 0 -1 0 3 -2 1
   0 -3 2 0 0 0 0 0 0 0 0 0 0 -3 2 0 0 3 -2 0 0 0 0 0 0 3 -2 0 0
   -6 4 0 0 3 -2 0 1 -2 1 0 0 0 0 0 -3 6 -3 0 
   2 -4 2 0 0 0 0 0 0 0 0 0 3 -6 3 0 -2 4 -2 0 0 0 0 0 0 0 0 0 0 -3 3 
   0 0 2 -2 0 0 -1 1 0 0 0 0 0 0 3 -3 0 0 -2 2 0 0 0 0 0
   1 -2 1 0 -2 4 -2 0 1 -2 1 0 0 0 0 0 0 0 0 0 -1 2 -1
   0 1 -2 1 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 -1 1 0 0 0 0 0 0 -1 1 
   0 0  2 -2 0 0 -1 1)) 16)))


(defun bcucof (y y1 y2 y12 d1 d2)
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) y1)) 
 (declare (type (simple-array double-float (*)) y2)) 
 (declare (type (simple-array double-float (*)) y12)) 
 (declare (type double-float d1 d2))

 (prog (
  (c (make-array (list 4 4) 
                      :element-type 'double-float :initial-element 0d0))
  (x (make-array 16 :element-type 'double-float :initial-element 0d0))
  (cl (make-array 16 :element-type 'double-float :initial-element 0d0))
  (d1d2 0d0) (xx 0d0) (l 0))

  (declare (type (simple-array double-float (* *)) c)) 
  (declare (type (simple-array double-float (*)) cl)) 
  (declare (type (simple-array double-float (*)) x)) 
  (declare (type double-float d1d2 xx))
  (declare (type integer l))
  

  (setf d1d2 (* d1 d2)) 
  (do ((i 0 (+ i 1)))
      ((> i 3) t)
      (declare (type integer i))
    (setf (aref x i) (aref y i))
    (setf (aref x (+ i 4)) (* (aref y1 i) d1))
    (setf (aref x (+ i 8)) (* (aref y2 i) d2))
    (setf (aref x (+ i 12)) (* (aref y12 i) d1d2))) 

  (do ((i 0 (+ i 1)))
      ((> i 15) t)
      (declare (type integer i))
    (setf xx 0d0)
    (do ((k 0 (+ k 1)))
        ((> k 15) t)
        (declare (type integer k))
      (setf xx (+ xx (* (aref bcucof-wt k i) (aref x k)))))
    (setf (aref cl i) xx)) 

  (setf l 0) 
  (do ((i 1 (+ i 1)))
      ((> i 4) t)
      (declare (type integer i))
    (do ((j 1 (+ j 1)))
        ((> j 4) t)
        (declare (type integer j))
      (setf l (+ l 1))
      (setf (aref c (1- i) (1- j)) (aref cl (1- l))))) 
   
  (return c)))

;------------------------------------------------------------------------------
(defun bcuint (y y1 y2 y12 x1l x1u x2l x2u x1 x2)
 (declare (type (simple-array double-float (4)) y)) 
 (declare (type (simple-array double-float (4)) y1)) 
 (declare (type (simple-array double-float (4)) y2)) 
 (declare (type (simple-array double-float (4)) y12)) 
 (declare (type double-float x1l x1u x2l x2u x1 x2))

 (prog ( 
  (c (make-array (list 4 4) :element-type 'double-float :initial-element 0d0))
  (ansy 0d0) (ansy1 0d0) (ansy2 0d0) (t0 0d0) (u 0d0))
  (declare (type double-float ansy ansy1 ansy2 t0 u))
  (declare (type (simple-array double-float (4 4)) c)) 

  (setf c (bcucof y y1 y2 y12 (- x1u x1l) (- x2u x2l))) 
  (if (or (= x1u x1l) (= x2u x2l)) 
      (error "bad input for bcuint")) 
  (setf t0 (/ (- x1 x1l) (- x1u x1l))) 
  (setf u (/ (- x2 x2l) (- x2u x2l))) 
  (setf ansy 0d0) 
  (setf ansy2 0d0) 
  (setf ansy1 0d0) 
  (do ((i 3 (1- i)))
      ((< i 0) t)
      (declare (type integer i))
    (setf ansy (+ (+ (* t0 ansy)
                     (* (+ (* (+ (* (aref c i 3) u) (aref c i 2)) u)
                           (aref c i 1))
                        u))
                  (aref c i 0)))
    (setf ansy2 (+ (+ (* t0 ansy2)
                      (* (+ (* (* 3d0 (aref c i 3)) u) (* 2 (aref c i 2))) u))
                   (aref c i 1)))
    (setf ansy1 (+ (+ (* u ansy1)
                      (* (+ (* (* 3d0 (aref c 3 i)) t0) (* 2 (aref c 2 i))) t0))
                   (aref c 1 i)))) 
  (setf ansy1 (/ ansy1 (- x1u x1l))) 
  (setf ansy2 (/ ansy2 (- x2u x2l))) 
  (return (values ansy ansy1 ansy2))))

;------------------------------------------------------------------------------
(defun splie2 (x1a x2a ya &key (nn 100))
 (declare (type (simple-array double-float (*)) x1a)) 
 (declare (type (simple-array double-float (*)) x2a)) 
 (declare (type (simple-array double-float (* *)) ya)) 
 (declare (type integer nn))

 (prog* (
  (m (array-dimension x1a 0))
  (n (array-dimension x2a 0))
  (y2a  
    (make-array (list m n) :element-type 'double-float :initial-element 0d0))
  (ytmp  
    (make-array nn :element-type 'double-float :initial-element 0d0))
  (y2tmp  
    (make-array nn :element-type 'double-float :initial-element 0d0)))
  (declare (type (simple-array double-float (* *)) y2a)) 
  (declare (type (simple-array double-float (*)) ytmp)) 
  (declare (type (simple-array double-float (*)) y2tmp))
  (declare (type integer n m))

   
  (do ((j 0 (+ j 1)))
      ((> j (1- m)) t)
      (declare (type integer j))
    (do ((k 0 (+ k 1)))
        ((> k (1- n)) t)
        (declare (type integer k))
      (setf (aref ytmp k) (aref ya j k)))
    (setq y2tmp (spline x2a ytmp 1.0d30 1.0d30))
    (do ((k 0 (+ k 1)))
        ((> k (1- n)) t)
        (declare (type integer k))
      (setf (aref y2a j k) (aref y2tmp k)))) 
   
  (return y2a)))

;-----------------------------------------------------------------------------
(defun splin2 (x1a x2a ya y2a x1 x2)
 (declare (type (simple-array double-float (*)) x1a)) 
 (declare (type (simple-array double-float (*)) x2a)) 
 (declare (type (simple-array double-float (* *)) ya)) 
 (declare (type (simple-array double-float (* *)) y2a)) 
 (declare (type double-float x1 x2))

 (prog* ( 
  (m (array-dimension x1a 0))
  (n (array-dimension x2a 0))
  (ytmp  
    (make-array n :element-type 'double-float :initial-element 0d0))
  (y2tmp  
    (make-array n :element-type 'double-float :initial-element 0d0))
  (yytmp  
    (make-array n :element-type 'double-float :initial-element 0d0))
  (yytmpj 0d0) (y 0d0))


  (declare (type (simple-array double-float (*)) ytmp)) 
  (declare (type (simple-array double-float (*)) y2tmp)) 
  (declare (type (simple-array double-float (*)) yytmp)) 
  (declare (type integer m n))
  (declare (type double-float yytmpj y))


  (do ((j 0 (+ j 1)))
      ((> j (1- m)) t)
      (declare (type integer j))
    (do ((k 0 (+ k 1)))
        ((> k (1- n)) t)
        (declare (type integer k))
      (setf (aref ytmp k) (aref ya j k))
      (setf (aref y2tmp k) (aref y2a j k)))
    (setq yytmpj (splint x2a ytmp y2tmp x2))
    (setf (aref yytmp j) yytmpj)) 
  (setq y2tmp (spline x1a yytmp 1.0d30 1.0d30)) 
  (setq y (splint x1a yytmp y2tmp x1)) 
  
  (return (the double-float y))))

;----------------------------------------------------------------------------
; end of nr03.l
