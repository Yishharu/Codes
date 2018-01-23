; nr05.l
; Evaluation of functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;Modified by Ken Olum for Common Lisp, April 1996;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package "USER")
; functions:
;	eulsum: sum a series Euler van Wijngaarden algorithm
;	ddpoly: fast evaluation of specified derivatives
;	poldiv: polynomials divide one by another
;	chebft: fit a Chebyshev polynomial to a function
;	chebev: Chebyshev polynomial evaluation
;	chint: integrate a function already Chebyshev fitted
;	chder: integrate a function already Chebyshev fitted
;	chebpc: polynomial coefficients from a Chebyshev fit
;	pcshft: polynomial coefficients of a shifted polynomial
;-----------------------------------------------------------------------------


(declaim (special nterm))
(declaim (type fixnum nterm))
(declaim (special wksp))
(declaim (type (simple-array double-float (*)) wksp))

(defun eulsum (sum term jterm &key (jmax 100))
 (declare (type double-float sum term))
 (declare (type fixnum jterm jmax))

 (prog ((tmp 0d0) (dum 0d0))
  (declare (type double-float tmp dum))
 
  (cond 
     ((= jterm 1) 
      (setf nterm 1)
      (setq wksp 
        (make-array jmax :element-type 'double-float :initial-element 0d0))
      (setf (aref wksp 0) term) 
      (setf sum (* 0.5d0 term)))
     (t
      (setf tmp (aref wksp 0)) 
      (setf (aref wksp 0) term)
      (do ((j 1 (+ j 1)))
          ((> j (1- nterm)) t)
          (declare (type fixnum j))
        (setf dum (aref wksp j))
        (setf (aref wksp j) (* 0.5d0 (+ (aref wksp (1- j)) tmp)))
        (setf tmp dum))
      (setf (aref wksp nterm) 
            (* 0.5d0 (+ (aref wksp (1- nterm)) tmp)))
      (cond 
       ((<= (abs (aref wksp nterm)) (abs (aref wksp (1- nterm))))
        (setf sum (+ sum (* 0.5d0 (aref wksp nterm)))) 
        (setf nterm (+ nterm 1)))
       (t 
        (setf sum (+ sum (aref wksp nterm)))))
   )) 
  (return (the double-float sum))))

;-----------------------------------------------------------------------------
(defun ddpoly (c x nd)
 (declare (type (simple-array double-float (*)) c))
 (declare (type double-float x))
 (declare (type fixnum nd)) 

 (prog* (
  (nc (array-dimension c 0)) 
  (pd (make-array nd  :element-type 'double-float :initial-element 0d0)) 
  (nnd 0) (const 0d0))

  (declare (type (simple-array double-float (*)) pd))
  (declare (type fixnum nc nnd))
  (declare (type double-float const))


  (setf (aref pd 0) (aref c (1- nc))) 

  (do ((i (1- nc) (1- i)))
      ((< i 1) t)
      (declare (type fixnum i))
    (setf nnd (min nd (- (+ nc 1) i)))
    (do ((j nnd (1- j)))
        ((< j 2) t)
        (declare (type fixnum j))
      (setf (aref pd (1- j)) (+ (* (aref pd (1- j)) x) (aref pd (- j 2)))))
    (setf (aref pd 0) (+ (* (aref pd 0) x) (aref c (1- i))))) 

  (setf const 2d0) 
  (do ((i 3 (+ i 1)))
      ((> i nd) t)
      (declare (type fixnum i))
    (setf (aref pd (1- i)) (* const (aref pd (1- i))))
    (setf const (* const i))) 
 
  (return pd)))

;-----------------------------------------------------------------------------
(defun poldiv (u v)
 (declare (type (simple-array double-float (*)) u)) 
 (declare (type (simple-array double-float (*)) v)) 

 (prog* (
  (n (array-dimension u 0))
  (nv (array-dimension v 0))
  (q (make-array n :element-type 'double-float :initial-element 0d0))
  (r (make-array n :element-type 'double-float :initial-element 0d0)))


  (declare (type (simple-array double-float (*)) q)) 
  (declare (type (simple-array double-float (*)) r)) 
  (declare (type fixnum n nv))


  (do ((j 1 (+ j 1)))
      ((> j n) t)
    (setf (fref r j) (fref u j))
    (setf (fref q j) 0d0)) 

  (do ((k (- n nv) (1- k)))
      ((< k 0) t)
    (setf (aref q k) (/ (fref r (+ nv k)) (fref v nv)))
    (do ((j (1- (+ nv k)) (1- j)))
        ((< j (1+ k)) t)
      (setf (aref r (1- j)) (- (fref r j)
                          (* (fref q (+ k 1)) (fref v (- j k))))))) 
  (do ((j nv (+ j 1)))
      ((> j n) t)
    (setf (aref r (1- j)) 0d0)) 
   
  (return (values q r))))

;-----------------------------------------------------------------------------

(defun chebft (a b n func)
 (declare (type fixnum n))
 (declare (type double-float a b))

 (prog (
  (sum 0d0) 
  (c (make-array n :element-type 'double-float :initial-element 0d0)) 
  (f (make-array n :element-type 'double-float :initial-element 0d0)) 
  (bma 0d0) (bpa 0d0) (fac 0d0) (y 0d0))

  (declare (type double-float pi)) 
  (declare (type double-float sum bms bpa fac y)) 
  (declare (type (simple-array double-float (*)) c)) 
  (declare (type (simple-array double-float (*)) f)) 


  (setf bma (* 0.5d0 (- b a))) 
  (setf bpa (* 0.5d0 (+ b a))) 
  (do ((k 1 (1+ k)))
      ((> k n) t)
      (declare (type fixnum k))
    (setf y (cos (dfloat (/ (* pi (- k 0.5d0))  n))))
    (setf (aref f (1- k)) (funcall func (+ (* y bma) bpa)))) 

  (setf fac (/ 2d0 (dfloat n))) 
  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf sum 0.0d0)
    (do ((k 1 (+ k 1)))
        ((> k n) t)
        (declare (type fixnum k))
      (setf sum (+ sum
                   (* (aref f (1- k))
                      (cos (dfloat (* (* pi (1- j))
                              (/ (- k 0.5d0) n))))))))
    (setf (aref c (1- j)) (* fac sum))) 
  (return c)))

;-----------------------------------------------------------------------------
(defun chebev (a b c x)
 (declare (type double-float a b x))
 (declare (type (simple-array double-float (*)) c)) 

 (prog ((m 0) (d 0d0) (dd 0d0) (y 0d0) (y2 0d0) (chebev 0d0) (sv 0d0))
  (declare (type fixnum m))
  (declare (type double-float d dd y y2 chebev sv))
  (setq m (array-dimension c 0))

  (if (> (* (- x a) (- x b)) 0d0) (error "x not in range")) 
  (setf d 0d0) 
  (setf dd 0d0) 
  (setf y (/ (- (- (* 2d0 x) a) b) (- b a))) 
  (setf y2 (* 2d0 y)) 
  (do ((j (1- m) (1- j)))
      ((< j 1) t)
      (declare (type fixnum j))
    (setf sv d)
    (setf d (+ (- (* y2 d) dd) (aref c j)))
    (setf dd sv)) 

  (setf chebev (+ (+ (* y d) (- dd)) (* 0.5d0 (aref c 0)))) 
  (return (the double-float chebev))))

;------------------------------------------------------------------------------
(defun chint (a b c)
 (declare (type (simple-array double-float (*)) c)) 
 (declare (type double-float a b))

 (prog* (
  (n (array-dimension c 0)) 
  (cint (make-array n :element-type 'double-float :initial-element 0d0)) 
  (con 0d0) (sum 0d0) (fac 0d0))

  (declare (type (simple-array double-float (*)) cint))
  (declare (type fixnum n))
  (declare (type double-float con sum fac))
 
  (setf con (* 0.25d0 (- b a))) 
  (setf sum 0d0) 
  (setf fac 1d0) 
  (do ((j 1 (+ j 1)))
      ((> j (- n 2)) t)
      (declare (type fixnum j))
    (setf (aref cint j) (/ (* con
                              (- (aref c (1- j))
                                 (aref c (1+ j))))
                           (dfloat j)))
    (setf sum (+ sum (* fac (aref cint j))))
    (setf fac (- fac))) 

  (setf (aref cint (1- n)) (/ (* con (aref c (- n 2))) (dfloat (1- n)))) 
  (setf sum (+ sum (* fac (aref cint (1- n))))) 
  (setf (aref cint 0) (* 2d0 sum)) 
  (return cint)))

;-----------------------------------------------------------------------------
(defun chder (a b c n)
 (declare (type (simple-array double-float (*)) c))
 (declare (type double-float a b) (type fixnum n))

 (prog
  ((cder (make-array n :element-type 'double-float :initial-element 0d0))
   (con 0d0)) 
  (declare (type (simple-array double-float (*)) cder)) 
  (declare (type double-float con))


  (setf (aref cder (1- n)) 0d0) 
  (setf (aref cder (- n 2)) (* (dfloat (* 2 (1- n))) (aref c (1- n)))) 
  (when (>= n 3) 
   (do ((j (- n 3) (1- j)))
       ((< j 0) t)
       (declare (type fixnum j))
     (setf (aref cder j) (+ (aref cder (+ j 2))
                            (* (dfloat (* 2 (1+ j))) (aref c (1+ j))))))) 

  (setf con (/ 2d0 (- b a))) 
  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref cder j) (* (aref cder j) con))) 
  (return cder)))

;-----------------------------------------------------------------------------
(defun chebpc (c)
 (declare (type (simple-array double-float (*)) c)) 

 (prog* (
  (n (array-dimension c 0))
  (d (make-array n :element-type 'double-float :initial-element 0d0))
  (dd (make-array n :element-type 'double-float :initial-element 0d0))
  (sv 0d0))

  (declare (type fixnum n))
  (declare (type (simple-array double-float (*)) d)) 
  (declare (type (simple-array double-float (*)) dd)) 
  (declare (type double-float sv))


  (setf (aref d 0) (aref c (1- n))) 
  (do ((j (- n 2) (1- j)))
      ((< j 1) t)
      (declare (type fixnum j))
    (do ((k (- n j) (1- k)))
        ((< k 1) t)
        (declare (type fixnum k))
      (setf sv (aref d k))
      (setf (aref d k) (- (* 2 (aref d (1- k))) (aref dd k)))
      (setf (aref dd k) sv))
    (setf sv (aref d 0))
    (setf (aref d 0) (+ (* -1 (aref dd 0)) (aref c j)))
    (setf (aref dd 0) sv)) 

  (do ((j (1- n) (1- j)))
      ((< j 1) t)
      (declare (type fixnum j))
    (setf (aref d j) (- (aref d (1- j)) (aref dd j)))) 

  (setf (aref d 0) (+ (* -1 (aref dd 0)) (* 0.5d0 (aref c 0)))) 
  (return d)))

;-----------------------------------------------------------------------------
(defun pcshft (a b d)
 (declare (type (simple-array double-float (*)) d)) 
 (declare (type double-float a b))

 (prog ((n 0) (const 0d0) (fac 0d0))
  (declare (type fixnum n))
  (declare (type double-float const fac))

  (setq n (array-dimension d 0))

  (setf const (/ 2d0 (- b a))) 
  (setf fac const) 
  (do ((j 1 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref d j) (* (aref d j) fac))
    (setf fac (* fac const)))
 
  (setf const (* 0.5d0 (+ a b))) 
  (do ((j 0 (+ j 1)))
      ((> j (- n 2)) t)
      (declare (type fixnum j))
    (do ((k (- n 2) (1- k)))
        ((> k (1- j)) t)
        (declare (type fixnum k))
      (setf (aref d k) (- (aref d k) (* const (aref d (+ k 1))))))) 
   
  (return (the (simple-array double-float (*)) d))))

;-----------------------------------------------------------------------------
; end of nr05.l
