; nr04.lfuncall
; Integration of functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	trapzd: integrate a function using the trapezoidal rule
;	qtrap: use the trapezoidal rule to desired accuracy
;	qsimp: use Simpson's rule to desired accuracy
;	qromb: use Romberg adaptive quadrature to desired accuracy
;	midpnt: the extended midpoint rule
;	qromo: use open Romberg to desired accuracy
;	midinf: function on a semi infinite interval
;	midsql: function with a square root singularity
;	midsqu: inverse square root singularity
;	midexp: increased exponentially
;	qgaus: Gaussian quadratures
;	gauleg: compute Gauss-Legrendre weights and abscissas
;	qgausf: integrate a function of n variables returning a function
;	        of all but the last variable
;	quad2d: two dimensional integrals
;	quad3d, quad4d: 3 and 4 dimensional integrals
;-----------------------------------------------------------------------------

(defvar trapzd 
 (let ((it 0) (s 0d0))
  (declare (type fixnum it))
  (declare (type double-float s))

  #'(lambda (func a b n)
      (declare (type double-float a b))
      (declare (type fixnum n))

(prog ((sum 0d0) (tnm 0) (del 0d0) (x 0d0))
 (declare (type double-float sum del x))
 (declare (type fixnum tnm))

  (cond 
   ((= n 1) 
    (setf s (* (* 0.5d0 (- b a)) 
       (+ (dfloat (funcall func a)) 
          (dfloat (funcall func b)))))
    (setf it 1))
   (t 
    (setf tnm it)
    (setf del (/ (- b a) tnm)) 
    (setf x (+ a (* 0.5d0 del))) 
    (setf sum 0d0)
    (do ((j 1 (+ j 1)))
        ((> j it) t)
        (declare (type fixnum j))
      (setf sum (+ sum (dfloat (funcall func x))))
      (setf x (+ x del)))
    (setf s (* 0.5d0 (+ s (/ (* (- b a) sum) tnm)))) 
    (setf it (* 2 it)))) 
   
  (return (the double-float s))))))

;=============================================================================


(defun qtrap (func a b &key (eps 1.0d-6) (jmax 20)) 
 (declare (type double-float a b eps))
 (declare (type fixnum jmax))

 (prog ((olds 0d0) (s 0d0))
  (declare (type double-float s olds))
  (declare (special trapzd))

  (setf olds -1.0d30) 
  (do ((j 1 (+ j 1)))
       ((> j jmax) t)
       (declare (type fixnum j))
     (setq s (dfloat (funcall trapzd func a b j)))
    
     (if (< (abs (- s olds)) (* eps (abs olds))) (go end))
     (setf olds s))

 (error " too many steps in qtrap. ")
end
(return (the double-float s))
))

;-----------------------------------------------------------------------------
(defun qsimp (func a b &key (eps 1.0d-6) (jmax 20))
 (declare (type double-float eps a b))
 (declare (type fixnum jmax))

 (prog ((ost 0d0) (os 0d0) (s 0d0) (st 0d0))
  (declare (type double-float ost os s st))
 
  (setf ost -1.0d30) 
  (setf os -1.0d30) 
  (do ((j 1 (+ j 1)))
      ((> j jmax) t)
      (declare (type fixnum j))
    (setq st (dfloat (funcall trapzd func a b j)))
    (setf s (/ (- (* 4d0 st) ost) 3d0))
    
    (if (< (abs (- s os)) (* eps (abs os))) 
        (go end))
    (setf os s)
    (setf ost st))
   
  (error " too many steps in qsimp. ")
 end
 (return (the double-float s))
))

;-----------------------------------------------------------------------------
(defun qromb (func a b
             &key (eps 1.0d-6) (jmax 20) (jmaxp 21) (k 5) (km (1- k)))
 (declare (type double-float a b eps))
 (declare (type fixnum jmax jmaxp k km))

 (prog* (
  (s (make-array jmaxp :element-type 'double-float :initial-element 0d0))
  (h (make-array jmaxp :element-type 'double-float :initial-element 0d0))
  (hj 
      (make-array  k :element-type 'double-float :initial-element 0d0))
  (sj 
      (make-array k :element-type 'double-float :initial-element 0d0))
  (ss 0d0) (dss 0d0))


  (declare (type (simple-array double-float (*)) s)) 
  (declare (type (simple-array double-float (*)) h)) 
  (declare (type (simple-array double-float (*)) sj)) 
  (declare (type (simple-array double-float (*)) hj)) 
  (declare (type double-float ss dss))


  (setf (aref h 0) 1d0)

  (do ((j 1 (+ j 1)))
      ((> j jmax) t)
      (declare (type fixnum j))
    (setf (aref s (1- j)) (dfloat (funcall trapzd func a b j)))
    (when 
     (>= j k)
     (do ((i 1 (1+ i)))
         ((> i k) t)
         (declare (type fixnum i))
       (setf (aref sj (1- i)) (aref s (2- (+ i (- j km)))))
       (setf (aref hj (1- i)) (aref h (2- (+ i (- j km))))))


     (multiple-value-setq (ss dss) (polint hj sj k 0d0)) 
     (if (< (abs dss) (* eps (abs ss)))
         (go end)))
    (setf (aref s j) ss); (aref s (1- j)))
    (setf (aref h j) (* 0.25d0 (aref h (1- j))))) 

 (error " too many steps in qromb. ")
end
      (return (the double-float ss))))
;=============================================================================

(defvar midpnt 
 (let ((it 0) (s 0d0))
  (declare (type fixnum it))
  (declare (type double-float s))

  #'(lambda (func a b n)
      (declare (type double-float a b))
      (declare (type fixnum n))

 (prog ((tnm 0d0) (del 0d0) (ddel 0d0) (sum 0d0) (x 0d0))
  (declare (type double-float tnm del ddel sum x))
  (cond 
   ((= n 1)
    (setf s (* (- b a) (dfloat (funcall func (* 0.5d0 (+ a b)))))) 
    (setf it 1))
   (t  
    (setf tnm (dfloat it)) 
    (setf del (/ (- b a) (* 3d0 tnm)))
    (setf ddel (+ del del)) 
    (setf x (+ a (* 0.5d0 del))) 
    (setf sum 0d0)

    (do ((j 1 (+ j 1)))
        ((> j it) t)
        (declare (type fixnum j))
      (setf sum (+ sum (dfloat (funcall func x))))
      (setf x (+ x ddel))
      (setf sum (+ sum (dfloat (funcall func x))))
      (setf x (+ x del)))

   (setf s (/ (+ s (/ (* (- b a) sum) tnm)) 3d0)) 
   (setf it (* 3 it)))) 
   
  (return (the double-float s))))))

;------------------------------------------------------------------------------
(defun qromo (func a b 
             &key (choose midpnt)
        (eps 1.0d-6) (jmax 14) (jmaxp (1+ jmax)) (k 5) (km (1- k)))
 (declare (type double-float a b eps))
 (declare (type fixnum jmax jmaxp k km))

 (prog* (
  (s (make-array jmaxp :element-type 'double-float :initial-element 0d0))
  (h (make-array jmaxp :element-type 'double-float :initial-element 0d0))
  (hj 
      (make-array  k :element-type 'double-float :initial-element 0d0))
  (sj 
      (make-array k :element-type 'double-float :initial-element 0d0))
  (ss 0d0) (dss 0d0))

  (declare (type (simple-array double-float (*)) s)) 
  (declare (type (simple-array double-float (*)) h)) 
  (declare (type (simple-array double-float (*)) sj)) 
  (declare (type (simple-array double-float (*)) hj)) 
  (declare (type double-float ss dss))


  (setf (aref h 0) 1d0) 

  (do ((j 1 (+ j 1)))
      ((> j jmax) t)
      (declare (type fixnum j))
    (setf (aref s (1- j)) (dfloat (funcall choose func a b j)))
    (when 
     (>= j k)
     (do ((i 1 (1+ i)))
         ((> i k) t)
         (declare (type fixnum i))
       (setf (aref sj (1- i)) (aref s (2- (+ i (- j km)))))
       (setf (aref hj (1- i)) (aref h (2- (+ i (- j km))))))


     (multiple-value-setq (ss dss) (polint hj sj k 0d0)) 

     (if (< (abs dss) (* eps (abs ss))) (go end)))
    (setf (aref s j ) ss);(aref s (1- j)))
    (setf (aref h j) (/ (aref h (1- j)) 9d0)))
   
      (error " too many steps in qromo. ")
end
      (return (the double-float ss))))

;-----------------------------------------------------------------------------
(defvar midinf 
 (let ((it 0) (sss 0d0))
  (declare (type fixnum it))
  (declare (type double-float sss))

  #'(lambda (funk aa bb n)
      (declare (type double-float aa bb))
      (declare (type fixnum n))

 (prog (fun (b 0d0) (a 0d0) (tnm 0d0) (sum 0d0) (del 0d0) (ddel 0d0) (x 0d0))
  (declare (type double-float a b tnm sum del ddel x))
 
  (setq fun #'(lambda (x) 
                  (/ (dfloat (funcall funk (/ 1d0 x))) (expt x 2))))

  (setf b (/ 1d0 aa)) 
  (setf a (/ 1d0 bb)) 

  (cond 
   ((= n 1)
    (setf sss (* (- b a) (funcall fun (* 0.5d0 (+ a b))))) 
    (setf it 1)) 
   (t 
    (setf tnm (dfloat it)) 
    (setf del (/ (- b a) (* 3 tnm)))
    (setf ddel (+ del del)) 
    (setf x (+ a (* 0.5d0 del))) 
    (setf sum 0d0)

    (do ((j 1 (+ j 1)))
        ((> j it) t)
        (declare (type fixnum j))
      (setf sum (+ sum (funcall fun x)))
      (setf x (+ x ddel))
      (setf sum (+ sum (funcall fun x)))
      (setf x (+ x del)))

    (setf sss (/ (+ sss (/ (* (- b a) sum) tnm)) 3d0)) 
    (setf it (* 3 it)))) 
   
  (return (the double-float sss))))))

;-----------------------------------------------------------------------------
(defvar midsql 
 (let ((it 0) (s 0d0))
  (declare (type fixnum it))
  (declare (type double-float s))

  #'(lambda (funk aa bb n)
      (declare (type double-float aa bb))
      (declare (type fixnum n))

 (prog ((a 0d0) (b 0d0) (tnm 0d0) (del 0d0) (ddel 0d0) (sum 0d0) (x 0d0) func)
  (declare (type double-float a b tnm del ddel sum x))

  (setq func #'(lambda (x) 
            (* (* 2 x) (dfloat (funcall funk (+ aa (expt x 2))))))) 

  (setf b (sqrt (- bb aa))) 
  (setf a 0d0) 
  (cond 
   ((= n 1)
    (setf s (* (- b a) (funcall func (* 0.5d0 (+ a b))))) 
    (setf it 1))
   (t 
    (setf tnm (dfloat it)) 
    (setf del (/ (- b a) (* 3d0 tnm)))
    (setf ddel (+ del del)) (setf x (+ a (* 0.5d0 del))) 
    (setf sum 0d0)
    (do ((j 1 (+ j 1)))
        ((> j it) t)
        (declare (type fixnum j))
      (setf sum (+ sum (funcall func x)))
      (setf x (+ x ddel))
      (setf sum (+ sum (funcall func x)))
      (setf x (+ x del)))

   (setf s (/ (+ s (/ (* (- b a) sum) tnm)) 3d0)) 
   (setf it (* 3 it))))
   
  (return (the double-float s))))))

;-----------------------------------------------------------------------------
(defvar midsqu 
 (let ((it 0) (s 0d0))
  (declare (type fixnum it))
  (declare (type double-float s))

  #'(lambda (funk aa bb n)
      (declare (type double-float aa bb))
      (declare (type fixnum n))

 (prog ((a 0d0) (b 0d0) (tnm 0d0) (del 0d0) (ddel 0d0) (sum 0d0) (x 0d0) func)
  (declare (type double-float a b tnm del ddel sum x))

  (setq func #'(lambda (x)
     (* (* 2d0 x) (dfloat (funcall funk (- bb (expt x 2))))))) 

  (setf b (sqrt (- bb aa))) 
  (setf a 0d0) 
  (cond 
   ((= n 1)
    (setf s (* (- b a) (funcall func (* 0.5d0 (+ a b))))) 
    (setf it 1))
   (t
    (setf tnm (dfloat it)) 
    (setf del (/ (- b a) (* 3d0 tnm)))
    (setf ddel (+ del del)) 
    (setf x (+ a (* 0.5d0 del))) 
    (setf sum 0d0)
    (do ((j 1 (+ j 1)))
        ((> j it) t)
        (declare (type fixnum j))
      (setf sum (+ sum (funcall func x)))
      (setf x (+ x ddel))
      (setf sum (+ sum (funcall func x)))
      (setf x (+ x del)))
    (setf s (/ (+ s (/ (* (- b a) sum) tnm)) 3d0)) 
    (setf it (* 3 it))))

  (return (the double-float s))))))

;-----------------------------------------------------------------------------
(defvar midexp 
 (let ((it 0) (s 0d0))
  (declare (type fixnum it))
  (declare (type double-float s))

  #'(lambda (funk aa bb n)
      (declare (type double-float aa bb))
      (declare (type fixnum n))
      (declare (ignore bb))


 (prog (func (b 0d0) (a 0d0) (tnm 0d0) (sum 0d0) (del 0d0) (ddel 0d0) (x 0d0))
  (declare (type double-float a b tnm sum del ddel x))
 
  (setq func #'(lambda (x) 
        (dfloat (/ (funcall funk (* -1d0 (log x))) x))))

  (setf b (exp (* -1d0 aa))) 
  (setf a 0d0) 
  (cond 
   ((= n 1)
    (setf s (* (- b a) (funcall func (* 0.5d0 (+ a b))))) 
    (setf it 1)) 
  (t 
   (setf tnm (dfloat it) )
   (setf del (/ (- b a) (* 3d0 tnm)))
   (setf ddel (+ del del)) 
   (setf x (+ a (* 0.5d0 del))) 
   (setf sum 0d0)

   (do ((j 1 (+ j 1)))
       ((> j it) t)
       (declare (type fixnum j))
     (setf sum (+ sum (funcall func x)))
     (setf x (+ x ddel))
     (setf sum (+ sum (funcall func x)))
     (setf x (+ x del)))

   (setf s (/ (+ s (/ (* (- b a) sum) tnm)) 3d0)) 
   (setf it (* 3 it))))
   
  (return (the double-float s))))))

;------------------------------------------------------------------------------
(defun qgaus (func a b)
 (declare (type double-float a b))

 (prog (
  (x (make-array 5 :element-type 'double-float 
    :initial-contents 
    '( 0.148874d0 0.433395d0 0.67941d0 0.865063d0 0.973907d0))) 
  (w (make-array 5 :element-type 'double-float 
   :initial-contents
  '(0.295524d0 0.269267d0 0.219086d0 0.149451d0 0.066671d0)))
  (xm 0d0) (xr 0d0) (ss 0d0) (dx 0d0))

  (declare (type double-float xm xr ss dx))
  (declare (type (simple-array double-float (*)) x)) 
  (declare (type (simple-array double-float (*)) w)) 
  (declare (type double-float xm xr ss dx))


  (setf xm (* 0.5d0 (+ b a))) 
  (setf xr (* 0.5d0 (- b a))) 
  (setf ss 0d0) 

  (do ((j 0 (+ j 1)))
      ((> j 4) t)
    (setf dx (* xr (aref x j)))
    (setf ss (+ ss
                (* (aref w j)
                   (dfloat (+ (funcall func (+ xm dx)) 
                                    (funcall func (- xm dx)))))))) 
  (setf ss (* xr ss)) 
   
  (return (the double-float ss))))

;------------------------------------------------------------------------------
(defun gauleg (x1 x2 n)
 (declare (type double-float x1 x2))
 (declare (type fixnum n))

 (prog (
  (x (make-array n :element-type 'double-float :initial-element 0d0))
  (w (make-array n :element-type 'double-float :initial-element 0d0))
  (eps 0d0) (m 0) (xm 0d0) (xl 0d0) 
  (p1 0d0) (p2 0d0) (p3 0d0) (pp 0d0) (z1 0d0) (z 0d0))

  (declare (type (simple-array double-float (*)) x w))
  (declare (type double-float eps xm xl z p1 p2 p3 pp z1))
  (declare (type fixnum m))

  

  (setq eps 3.d-14) 
  (setf m (/ (1+ n) 2)) 
  (setf xm (* 0.5d0 (+ x2 x1))) 
  (setf xl (* 0.5d0 (- x2 x1))) 
  (do ((i 1 (+ i 1)))
      ((> i m) t)
      (declare (type fixnum i))
    (setf z (cos (/ (* 3.141592654d0 (- i 0.25d0)) (+ n 0.5d0)))) 
  label1 
    (setf p1 1.0d0) 
    (setf p2 0.0d0) 

    (do ((j 1 (+ j 1)))
        ((> j n) t)
        (declare (type fixnum j))
      (setf p3 p2) 
      (setf p2 p1) 
      (setf p1 (/ (- (* (* (1- (* 2.0d0 j)) z) p2)
                     (* (1- j) p3))
                  j))) 

    (setf pp (/ (* n (- (* z p1) p2)) (1- (* z z)))) 
    (setf z1 z) 
    (setf z (+ z1 (/ (* -1d0 p1) pp))) 
      (if (> (abs (- z z1)) eps) (go label1)) 
    (setf (aref x (1- i)) (- xm (* xl z))) 
    (setf (aref x (1- (- (+ n 1) i))) (+ xm (* xl z))) 
    (setf (aref w (1- i)) (/ (* 2.0d0 xl) (* (* (- 1.0d0 (* z z)) pp) pp))) 
    (setf (aref w (- n i)) (aref w (1- i))))

  (return (values x w))))

;------------------------------------------------------------------------------
; this returns of function of all but the last variable of func
; func is a function of more than one variable, af and bf are functions of
; all but the last variable

(defun qgausf (func af bf) 
  
 #'(lambda (&rest args)

 (prog (
  (x (make-array 5 :element-type 'double-float 
    :initial-contents 
    '(0.148874d0 0.433395d0 0.67941d0 0.865063d0 0.973907d0))) 
  (w (make-array 5 :element-type 'double-float 
   :initial-contents
  '(0.295524d0 0.269267d0 0.219086d0 0.149451d0 0.066671d0))) 
  (xm  0d0) (xr  0d0) (ss  0d0) 
  (dx  0d0) (a  0d0) (b 0d0))

  (declare (type double-float xm xr ss dx))
  (declare (type (simple-array double-float (*)) x)) 
  (declare (type (simple-array double-float (*)) w)) 
  (declare (type double-float xm xr ss dx a b))


  (setq a (apply af args))
  (setq b (apply bf args))

  (setf xm (* 0.5d0 (+ b a))) 
  (setf xr (* 0.5d0 (- b a))) 
  (setf ss 0d0) 

  (do ((j 0 (+ j 1)))
      ((> j 4) t)
    (setf dx (* xr (aref x j)))
    (setf ss (+ ss
                (* (aref w j)
                   (dfloat
                    (+ (apply func (append args (list (+ xm dx)))) 
                       (apply func (append args (list (- xm dx))))))))))
  (setf ss (* xr ss)) 
   
  (return (the double-float ss)))))

(defun qgaus2d (f x1 x2 y1 y2)
 (qgaus (qgausf f y1 y2) x1 x2))

(defun qgaus3d (f x1 x2 y1 y2 z1 z2)
 (qgaus (qgausf (qgausf f z1 z2) y1 y2) x1 x2))

(defun qgaus4d (f x1 x2 y1 y2 z1 z2 w1 w2)
 (qgaus (qgausf (qgausf (qgausf f w1 w2) z1 z2) y1 y2) x1 x2))

;------------------------------------------------------------------------------
; end of nr04.l
