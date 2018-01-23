; nr12.l
; Fourier Transform Spectral Methods
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;Modified by Ken Olum for Common Lisp, April 1996;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package "USER")
; functions:
;	four1: fourier transform (FFT) in one dimension
;	twofft: fourier transform of two real functions
;	realft: fourier transform of a real functions
;	sinft: sine transform using the FFT
;	cosft: cosine transform using the FFT
;	convlv: convolution or deconvolution of data using the FFT
;	correl: correlation or autocorrelation of data using the FFT
;	spctrm: power spectrum estimation using the FFT
;	memcof: power spectrum estimation, evaluate maximum entropy coefs
;	evlmem: power spectrum estimation using the maximum entropy coefs
;	fixrts: roots of a polynomial, reflects inside the unit circle
;	predic: linear prediction using the MEM coefficients
;	fourn: multidimensional FFT
;------------------------------------------------------------------------------

(defun four1 (data nn &key (isign 1))
 (declare (type (simple-array double-float (*)) data)) 
 (declare (type fixnum nn isign))

 (prog ((wr 0d0) (wi 0d0) (wpr 0d0) (wpi 0d0) (wtemp 0d0) 
        (theta 0d0) (tempr 0d0) (tempi 0d0) (j 0) (n 0) (m 0) 
        (mmax 0) (istep 0))
  (declare (type double-float wr wi wpr wpi wtemp theta tempr tempi)) 
  (declare (type fixnum j n m mmax istep))


  (setf n (* 2 nn)) 
  (setf j 1) 
  (do ((i 1 (+ i 2)))
      ((> i n) t)
      (declare (type fixnum i))
    (when (> j i) 
     (setf tempr (aref data (1- j)))
     (setf tempi (aref data j)) 
     (setf (aref data (1- j)) (aref data (1- i)))
     (setf (aref data j) (aref data i)) 
     (setf (aref data (1- i)) tempr)
     (setf (aref data i) tempi))
    (setf m (floor (/ n 2)))
    label1
    (when (and (>= m 2) (> j m))
     (setf j (- j m)) (setf m (floor (/ m 2)))
     (go label1))
    (setf j (+ j m))) 

  (setf mmax 2) 
  label2 
  (when (> n mmax)
   (setf istep (* 2 mmax))
   (setf theta (/ 6.28318530717959d0 (* isign mmax)))
   (setf wpr (* -2.0d0 (expt (sin (* 0.5d0 theta)) 2)))
   (setf wpi (sin theta)) (setf wr 1.0d0) (setf wi 0.0d0)
   (do ((m 1 (+ m 2)))
       ((> m mmax) t)
       (declare (type fixnum m))
     (do ((i m (+ i istep)))
         ((> i n) t)
         (declare (type fixnum i))
       (setf j (+ i mmax))
       (setf tempr (+ (* wr (aref data (1- j)))
                      (* (* -1d0 wi) (aref data j))))
       (setf tempi (+ (* wr (aref data j))
                      (* wi (aref data (1- j)))))
       (setf (aref data (1- j)) (+ (aref data (1- i)) (- tempr)))
       (setf (aref data j) (+ (aref data i) (* -1d0 tempi)))
       (setf (aref data (1- i)) (+ (aref data (1- i)) tempr))
       (setf (aref data i) (+ (aref data i) tempi)))
     (setf wtemp wr)
     (setf wr (+ (+ (* wr wpr) (* (- wi) wpi)) wr))
     (setf wi (+ (+ (* wi wpr) (* wtemp wpi)) wi)))
   (setf mmax istep)
   (go label2)) 
   
  (return data)))
;------------------------------------------------------------------------------

(defun twofft (data1 data2 n)
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2))
 (declare (type fixnum n))

 (prog ((fft1 nil) (fft2 nil) (fft1-real nil) 
        (h1 #c(0d0 0d0)) (h2 #c(0d0 0d0)) 
        (c1 #c(0d0 0d0)) (c2 #c(0d0 0d0)) (n2 0)) 
  (declare (type (complex double-float) h1 h2 c1 c2))
;  (declare (type (simple-array (complex double-float) (*)) fft1 fft2))
  (declare (type fixnum  n2))

  (setq fft2 (make-array n :element-type '(complex double-float)
                           :initial-element (complex 0d0 0d0)))
   


  (setf c1 (complex 0.5d0 0d0)) 
  (setf c2 (complex 0d0 -0.5d0)) 


  
  (setq fft1-real (make-array (* 2 n) :element-type 'double-float))
  (dotimes (i n)
    (setf (aref fft1-real (* i 2)) (aref data1 i)
	  (aref fft1-real (1+ (* i 2))) (aref data2 i)))
 
  (setq fft1-real (four1 fft1-real n :isign 1)) 

  (setq fft1 (make-array n :element-type '(complex double-float)))
  (dotimes (i n)
    (setf (aref fft1 i)
	  (complex (aref fft1-real (* i 2))
		   (aref fft1-real (1+ (* i 2))))))n

  (setf (aref fft2 0) (complex (imagpart (aref fft1 0)) 0d0)) 
  (setf (aref fft1 0) (complex (realpart (aref fft1 0)) 0d0)) 
  (setf n2 (+ n 2)) 
  (do ((j 2 (+ j 1)))
      ((> j (+ (/ n 2) 1)) t)
      (declare (type fixnum j))
    (setf h1 (* c1 (+ (aref fft1 (1- j)) 
                      (conjugate (aref fft1 (1- (- n2 j)))))))
    (setf h2 (* c2
                (- (aref fft1 (1- j))
                   (conjugate (aref fft1 (1- (- n2 j)))))))
    (setf (aref fft1 (1- j)) h1)
    (setf (aref fft1 (1- (- n2 j))) (conjugate h1))
    (setf (aref fft2 (1- j)) h2)
    (setf (aref fft2 (1- (- n2 j))) (conjugate h2)))
  (return (values fft1 fft2))))
;------------------------------------------------------------------------------

(defun realft (data n &key (isign 1))
 (declare (type (simple-array double-float (*)) data)) 
 (declare (type fixnum n isign))

 (prog ((wr 0d0) (wi 0d0) (wpr 0d0) (wpi 0d0) (wtemp 0d0) 
        (theta 0d0) (c1 0d0) (n2p3 0) (c2 0d0) (i1 0) (i2 0) (i3 0) (i4 0)
        (wrs 0d0) (wis 0d0) (h1r 0d0) (h1i 0d0) (h2r 0d0) (h2i 0d0))
  (declare (type double-float wr wi wpr wpi wtemp theta c1 c2
                              wrs wis h1r h1i h2r h2i))
  (declare (type fixnum  n2p3 i1 i2 i3 i4))

;  (setq n (/ (array-dimension data 0) 2))
 
  (setf theta (/ 3.141592653589793d0 (dfloat n))) 
  (setf c1 0.5d0) 
  (cond 
   ((= isign 1) 
    (setf c2 -0.5d0)
    (setq data (four1 data n :isign 1)))
   (t 
    (setf c2 0.5d0)
    (setf theta (- theta)))) 
  (setf wpr (* (- 2.0d0) (expt (sin (* 0.5d0 theta)) 2)))
 
  (setf wpi (sin theta)) 
  (setf wr (1+ wpr)) 
  (setf wi wpi) 
  (setf n2p3 (+ (* 2 n) 3)) 

  (do ((i 2 (+ i 1)))
      ((> i (/ n 2)) t)
      (declare (type fixnum i))
    (setf i1 (1- (* 2 i)))
    (setf i2 (+ i1 1))
    (setf i3 (+ n2p3 (- i2)))
    (setf i4 (1+ i3))

    (setf wrs wr)
    (setf wis wi)
    (setf h1r (* c1 (+ (fref data i1) (fref data i3))))
    (setf h1i (* c1 (- (fref data i2) (fref data i4))))
    (setf h2r (* (- c2) (+ (fref data i2) (fref data i4))))
    (setf h2i (* c2 (- (fref data i1) (fref data i3))))
    (setf (fref data i1) (- (+ h1r (* wrs h2r)) (* wis h2i)))
    (setf (fref data i2) (+ (+ h1i (* wrs h2i)) (* wis h2r)))
    (setf (fref data i3) (+ (- h1r (* wrs h2r)) (* wis h2i)))
    (setf (fref data i4) (+ (+ (- h1i) (* wrs h2i)) (* wis h2r)))
    (setf wtemp wr)
    (setf wr (+ (+ (* wr wpr) (* (- wi) wpi)) wr))
    (setf wi (+ (+ (* wi wpr) (* wtemp wpi)) wi))) 

  (cond 
   ((= isign 1) 
    (setf h1r (fref data 1))
    (setf (fref data 1) (+ h1r (fref data 2)))
    (setf (fref data 2) (+ h1r (- (fref data 2)))))
   (t
    (setf h1r (fref data 1)) 
    (setf (fref data 1) (* c1 (+ h1r (fref data 2))))
    (setf (fref data 2) (* c1 (+ h1r (- (fref data 2)))))
    (setq data (four1 data n :isign -1)))) 
   
  (return data)))

;-------------------------------------------------------------------------------
(defun sinft (y)
 (declare (type (simple-array double-float (*)) y)) 

 (prog ((n 0) (wr 0d0) (wi 0d0) (wpr 0d0) (wpi 0d0) 
        (wtemp 0d0) (theta 0d0) (sum 0d0) (y1 0d0) (y2 0d0) (m 0))
  (declare (type double-float wr wi wpr wpi wtemp theta sum y2 y1)) 
  (declare (type fixnum n m))

  (setq n (array-dimension y 0))
  (setf theta (/ 3.141592653589793d0 (dfloat n))) 
  (setf wr 1.0d0) 
  (setf wi 0.0d0) 
  (setf wpr (* -2.0d0 (expt (sin (* 0.5d0 theta)) 2))) 
  (setf wpi (sin theta)) 
  (setf (aref y 0) 0d0) 
  (setf m (floor (/ n 2))) 

  (do ((j 1 (+ j 1)))
      ((> j m) t)
      (declare (type fixnum j))
    (setf wtemp wr)
    (setf wr (+ (+ (* wr wpr) (* (- wi) wpi)) wr))
    (setf wi (+ (+ (* wi wpr) (* wtemp wpi)) wi))
    (setf y1 (* wi (+ (fref y (+ j 1)) (fref y (1+ (- n j))))))
    (setf y2 (* 0.5d0 (+ (fref y (+ j 1)) (- (fref y (1+ (- n j)))))))
    (setf (fref y (+ j 1)) (+ y1 y2))
    (setf (fref y (+ (+ n (- j)) 1)) (+ y1 (- y2))))
 
  (setq y (realft y (/ n 2) :isign 1)) 
  (setf sum 0d0) 
  (setf (fref y 1) (* 0.5d0 (fref y 1))) 
  (setf (fref y 2) 0d0) 

  (do ((j 1 (+ j 2)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf sum (+ sum (fref y j)))
    (setf (fref y j) (fref y (+ j 1)))
    (setf (fref y (+ j 1)) sum)) 
   
  (return y)))

;-----------------------------------------------------------------------------

(defun cosft (y &key (isign 1))
 (declare (type (simple-array double-float (*)) y))
 (declare (type fixnum isign))
 
 (prog ((n 0) (wr 0d0) (wi 0d0) (wpr 0d0) (wpi 0d0) (wtemp 0d0)
        (theta 0d0) (sum 0d0) (m 0d0) (y1 0d0) (y2 0d0) (even 0d0) 
        (odd 0d0) (enf0 0d0) (sumo 0d0) (sume 0d0))
  (declare (type double-float wr wi wpr wpi wtemp theta 
                              y1 y2 even odd enf0 sumo sume))
  (declare (type fixnum n)) 

  (setq n (array-dimension y 0))

  (setf theta (/ 3.141592653589793d0 (dfloat n))) 
  (setf wr 1.0d0) 
  (setf wi 0.0d0) 
  (setf wpr (* -2.0d0 (expt (sin (* 0.5d0 theta)) 2))) 
  (setf wpi (sin theta)) 
  (setf sum (fref y 1)) 
  (setf m (floor (/ n 2))) 
  (do ((j 1 (+ j 1)))
      ((> j (- m 1)) t)
      (declare (type fixnum j))
    (setf wtemp wr)
    (setf wr (+ (+ (* wr wpr) (* (- wi) wpi)) wr))
    (setf wi (+ (+ (* wi wpr) (* wtemp wpi)) wi))
    (setf y1 (* 0.5d0 (+ (fref y (+ j 1)) (fref y (+ (- n j) 1)))))
    (setf y2 (+ (fref y (+ j 1)) (- (fref y (+ (- n j) 1)))))
    (setf (fref y (+ j 1)) (+ y1 (* (- wi) y2)))
    (setf (fref y (+ (- n j) 1)) (+ y1 (* wi y2)))
    (setf sum (+ sum (* wr y2)))) 

  (setq y (realft y (/ n 2) :isign 1)) 
  (setf (fref y 2) sum) 

  (do ((j 4 (+ j 2)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf sum (+ sum (fref y j)))
    (setf (fref y j) sum)) 

  (when (= isign -1)
   (setf even (fref y 1)) 
   (setf odd (fref y 2))

   (do ((i 3 (+ i 2)))
       ((> i (- n 1)) t)
      (declare (type fixnum i))
     (setf even (+ even (fref y i)))
     (setf odd (+ odd (fref y (+ i 1)))))

   (setf enf0 (* 2d0 (- even odd)))
   (setf sumo (- (fref y 1) enf0))
   (setf sume (- (/ (* 2d0 odd) (dfloat n)) sumo))
   (setf (fref y 1) (* 0.5d0 enf0)) 
   (setf (fref y 2) (- (fref y 2) sume))

   (do ((i 3 (+ i 2)))
       ((> i (- n 1)) t)
       (declare (type fixnum i))
     (setf (fref y i) (- (fref y i) sumo))
     (setf (fref y (+ i 1)) (- (fref y (+ i 1)) sume)))) 

  (return y)))

;------------------------------------------------------------------------------
;;This is used by the following two functions
;;It takes an array of complex double-floats and returns an array of
;;real double floats with the parts of the complex numbers in the order
;;Re(c_1), Im(c_1), Re(c_2), Im(c_2), ...
(defun complex-to-real-array (ar)
  (let* ((n (array-dimension ar 0))
	 (rar (make-array (* n 2) :element-type 'double-float)))
    (dotimes (i n)
      (setf (aref rar (* i 2)) (realpart (aref ar i))
	    (aref rar (1+ (* i 2))) (imagpart (aref ar i))))
    rar))

(defun convlv (data n respns m &key (isign 1))
  (declare (type (simple-array double-float (*)) data)) 
  (declare (type (simple-array double-float (*)) respns)) 
  (declare (type fixnum m n isign))

 (prog ((no2 0)
  (fft (make-array n :element-type '(complex double-float) 
                             :initial-element  #c(0d0 0d0)))
  (ans (make-array n :element-type '(complex double-float) 
                             :initial-element  #c(0d0 0d0)))
  (ansr (make-array (* 2 n) :element-type 'double-float 
                             :initial-element  0d0)))


  (declare (type (simple-array (complex  double-float) (*)) fft)) 
  (declare (type (simple-array (complex  double-float) (*)) ans)) 
  (declare (type (simple-array double-float (*)) ansr)) 
  (declare (type fixnum no2))


  (do ((i 1 (+ i 1)))
      ((> i (floor (/ (1- m) 2))) t)
      (declare (type fixnum i))
    (setf (aref respns (- n i)) 
          (aref respns (- m i))))
 
  (do ((i (floor (/ (+ m 3) 2)) (+ i 1)))
      ((> i (+ n (floor (/ (- (1- m)) 2)))) t)
      (declare (type fixnum i))
    (setf (aref respns (1- i)) 0d0)) 

  (multiple-value-setq (fft ans) (twofft data respns n))

  (setf no2 (floor (/ n 2))) 
  (do ((i 0 (+ i 1)))
      ((> i no2) t)
      (declare (type fixnum i))
    (cond 
     ((= isign 1)
      (setf (aref ans i) (/ (* (aref fft i) (aref ans i)) no2)))
     ((= isign -1)
      (if (= (abs (aref ans i)) 0d0) 
          (error "deconvolving at a response zero"))
      (setf (aref ans i) (/ (/ (aref fft i) (aref ans i)) no2)))
     (t
       (error "no meaning for isign in convlv")))) 

  (setf (aref ans 0) (complex (realpart (aref ans 0))
                           (realpart (aref ans no2)))) 
  (setq ansr (realft (complex-to-real-array ans) no2 :isign -1)) 
  (return ansr)))

;------------------------------------------------------------------------------
(defun correl (data1 data2 n)
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2)) 
 (declare (type fixnum n))

 (prog ((no2 0)
  (fft (make-array n :element-type '(complex double-float) 
                             :initial-element  #c(0d0 0d0)))
  (ans (make-array n :element-type '(complex double-float) 
                             :initial-element  #c(0d0 0d0)))
  (ansr (make-array (* 2 n) :element-type 'double-float 
                             :initial-element  0d0)))


  (declare (type (simple-array (complex  double-float) (*)) fft)) 
  (declare (type (simple-array (complex  double-float) (*)) ans)) 
  (declare (type (simple-array double-float (*)) ansr)) 
  (declare (type fixnum  no2))


  (multiple-value-setq (fft ans) (twofft data1 data2 n)) 
  (setf no2 (floor (/ n 2)))

  (do ((i 0 (+ i 1)))
      ((> i no2) t)
      (declare (type fixnum i))
    (setf (aref ans i) (/ (* (aref fft i) (conjugate (aref ans i)))
                          (dfloat no2)))) 

  (setf (aref ans 0) (complex (realpart (aref ans 0))
                           (realpart (aref ans no2)))) 
  (setq ansr (realft (complex-to-real-array ans) no2 :isign -1)) 
  (return ansr)))

;-----------------------------------------------------------------------------

(defun spctrm (data m k &key (window "parzen") (ovrlap t))
 (declare (type fixnum m k))
 (declare (type symbol ovrlap))
 (declare (type string window))
 (declare (type  string data))

 (prog (
  (p (make-array m :element-type 'double-float :initial-element 0d0))
  (w1 
    (make-array (* 4 m) :element-type 'double-float :initial-element 0d0))
  (w2 (make-array m :element-type 'double-float :initial-element 0d0))
  (den 0d0) (facm 0d0) (facp 0d0) 
  (sumw 0d0) (mm 0) (m4 0) (m44 0) (m43 0) (window-fun 0d0) 
  (iunit nil) (joffn 0) (j2 0) (w 0d0))

  (declare (type (simple-array double-float (*)) p)) 
  (declare (type (simple-array double-float (*)) w1)) 
  (declare (type (simple-array double-float (*)) w2)) 
  (declare (type fixnum mm m4 m44 m43 joffn j2))
  (declare (type double-float facm facp sumw den w))
  (declare (type stream iunit))

  (setq iunit (open data :direction :input))


  (setq window-fun 
   (cond 
     ((equal window "parzen")
      #'(lambda (j)
          (declare (type fixnum j))
          (- 1d0 (abs (* (+ (dfloat (1- j)) (- facm)) facp))))) 
     ((equal window "square")
         #'(lambda (j) (declare (ignore j))
                      1d0)) 
     ((equal window "welch")
         #'(lambda (j) 
             (declare (type fixnum j))

             (- 1d0 (expt (* (+ (dfloat (1- j)) (- facm)) facp)
                                    2)))))) 

  (setf mm (+ m m)) 
  (setf m4 (+ mm mm)) 
  (setf m44 (+ m4 4)) 
  (setf m43 (+ m4 3)) 
  (setf den 0d0) 
  (setf facm (+ m (- 0.5d0))) 
  (setf facp (/ 1d0 (+ m 0.5d0))) 
  (setf sumw 0d0) 

  (do ((j 1 (+ j 1)))
      ((> j mm) t)
      (declare (type fixnum j))
    (setf sumw (+ sumw (expt (funcall window-fun j) 2))))
 
  (do ((j 1 (+ j 1)))
      ((> j m) t)
      (declare (type fixnum j))
    (setf (fref p j) 0d0)) 

  (if ovrlap 
   (do ((j 1 (1+ j)))
       ((> j m) t)
       (declare (type fixnum j))
    (setf (fref w2 j) (dfloat (read iunit))))) 

  (do ((kk 1 (+ kk 1)))
      ((> kk k) t)
      (declare (type fixnum kk))
    (do ((joff (- 1) (+ joff 1)))
        ((> joff 0) t)
      (cond 
       (ovrlap 
         (do ((j 1 (+ j 1)))
             ((> j m) t)
             (declare (type fixnum j)) 
          (setf (fref w1 (+ (+ joff j) j)) (fref w2 j)))

         (do ((j 1 (1+ j)))
             ((> j m) t)
             (declare (type fixnum j))
          (setf (fref w2 j) (dfloat (read iunit)))) 
         (setf joffn (+ joff mm))
         (do ((j 1 (+ j 1)))
             ((> j m) t)
             (declare (type fixnum j))
           (setf (fref w1 (+ (+ joffn j) j)) (fref w2 j))))
        (t 
         (do ((j (+ joff 2) (+ j 2)))
             ((> j  m4) t)
             (declare (type fixnum j))
          (setf (fref w1 j) (dfloat (read iunit))))))) 

    (do ((j 1 (+ j 1)))
        ((> j mm) t)
        (declare (type fixnum j))
      (setf j2 (+ j j))
      (setf w (funcall window-fun j))
      (setf (fref w1 j2) (* (fref w1 j2) w))
      (setf (fref w1 (1- j2)) (* (fref w1 (1- j2)) w)))


    (setq w1 (four1 w1 mm :isign 1))  
    (setf (fref p 1) (+ (+ (fref p 1) (expt (fref w1 1) 2))
                        (expt (fref w1 2) 2)))
    (do ((j 2 (+ j 1)))
        ((> j m) t)
        (declare (type fixnum j))
      (setf j2 (+ j j))
      (setf (fref p j) (+ (+ (+ (+ (fref p j) (expt (fref w1 j2) 2))
                                (expt (fref w1 (1- j2)) 2))
                             (expt (fref w1 (+ m44 (- j2))) 2))
                          (expt (fref w1 (+ m43 (- j2))) 2))))
    (setf den (+ den sumw)))
 
  (setf den (* m4 den)) 
  (do ((j 1 (+ j 1)))
      ((> j m) t)
      (declare (type fixnum j))
    (setf (fref p j) (/ (fref p j) den))) 

  (close iunit)
  
  (return p)))

;-------------------------------------------------------------------------------

(defun memcof (data m)
 (declare (type (simple-array double-float (*)) data))
 (declare (type fixnum m))

 (prog* ((pm 0d0)  (p 0d0)
  (n (array-dimension data 0)) 
  (cof (make-array m :element-type 'double-float :initial-element 0d0))
  (wk1 (make-array n :element-type 'double-float :initial-element 0d0))
  (wk2 (make-array n
 :element-type 'double-float :initial-element 0d0))
  (wkm (make-array m :element-type 'double-float :initial-element 0d0))
  (pneum 0d0) (denom 0d0)) 

  (declare (type (simple-array double-float (*)) cof wk1 wk2 wkm))
  (declare (type fixnum n))
  (declare (type double-float p pm pneum denom))

  (setf p 0d0) 

  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf p (+ p (expt (fref data j) 2)))) 

  (setf pm (/ p (dfloat n))) 
  (setf (fref wk1 1) (fref data 1)) 
  (setf (fref wk2 (1- n)) (fref data n)) 

  (do ((j 2 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (fref wk1 j) (fref data j))
    (setf (fref wk2 (1- j)) (fref data j))) 

  (do ((k 1 (+ k 1)))
      ((> k m) t)
      (declare (type fixnum k))
    (setf pneum 0d0)
    (setf denom 0d0)
    (do ((j 1 (+ j 1)))
        ((> j (- n k)) t)
        (declare (type fixnum j))
      (setf pneum (+ pneum (* (fref wk1 j) (fref wk2 j))))
      (setf denom (+ (+ denom (expt (fref wk1 j) 2)) (expt (fref wk2 j) 2))))

    (setf (fref cof k) (/ (* 2 pneum) denom))
    (setf pm (* pm (- 1d0 (expt (fref cof k) 2))))
    (do ((i 1 (+ i 1)))
        ((> i (1- k)) t)
        (declare (type fixnum i))
      (setf (fref cof i) (- (fref wkm i)
                            (* (fref cof k) (fref wkm (- k i))))))
    
    (if (= k m) (go end))

    (do ((i 1 (+ i 1)))
        ((> i k) t)
        (declare (type fixnum k))
      (setf (fref wkm i) (fref cof i)))

    (do ((j 1 (+ j 1)))
        ((> j (1- (- n k))) t)
        (declare (type fixnum j))
      (setf (fref wk1 j) (- (fref wk1 j) (* (fref wkm k) (fref wk2 j))))
      (setf (fref wk2 j) (- (fref wk2 (+ j 1))
                            (* (fref wkm k) (fref wk1 (+ j 1))))))) 
   
  (error " should never reach here in memcof")
end
(return (values pm cof))
))

;-------------------------------------------------------------------------------

(defun evlmem (fdt cof pm)
 (declare (type (simple-array double-float (*)) cof)) 
 (declare (type double-float fdt pm))
 
 (prog ((evlmem 0d0) (m 0) (theta 0d0) (wpr 0d0) (wpi 0d0) 
        (wr 0d0) (wi 0d0) (sumr 0d0) (sumi 0d0) (wtemp 0d0))
  (declare (type double-float evlmem wr wi wpr wtemp theta sumr wpi)) 
  (declare (type fixnum m))

  (setq m (array-dimension cof 0)) 
  (setf theta (* 6.28318530717959d0 fdt)) 
  (setf wpr (cos theta)) 
  (setf wpi (sin theta)) 
  (setf wr 1.0d0) 
  (setf wi 0.0d0) 
  (setf sumr 1d0) 
  (setf sumi 0d0) 
  (do ((i 0 (+ i 1)))
      ((> i (1- m)) t)
      (declare (type fixnum i))
    (setf wtemp wr)
    (setf wr (+ (* wr wpr) (* (- wi) wpi)))
    (setf wi (+ (* wi wpr) (* wtemp wpi)))
    (setf sumr (+ sumr (* (* -1d0 (aref cof i)) wr)))
    (setf sumi (+ sumi (* (* -1d0 (aref cof i)) wi)))) 
  (setf evlmem (/ pm (+ (expt sumr 2) (expt sumi 2)))) 
  
  (return (the double-float evlmem))))

;------------------------------------------------------------------------------

(defun fixrts (d &key (npmax 100))
 (declare (type (simple-array double-float (*)) d)) 
 (declare (type fixnum npmax))
 (declare (ignore npmax))

 (prog* (
  (npoles (array-dimension d 0))
  (a (make-array (1+ npoles) :element-type '(complex double-float) 
                            :initial-element #c(0d0 0d0)))
  (roots (make-array (1+ npoles) :element-type '(complex double-float) 
                            :initial-element #c(0d0 0d0)))
  (n 0))

  (declare (type fixnum n npoles))
  (declare (type (simple-array (complex double-float) (*)) a))
  (declare (type (simple-array  (complex double-float) (*)) roots))
  (declare (ignore n))


  (setf (aref a npoles) #c(1d0 0d0)) 

  (do ((j npoles (1- j)))
      ((< j 1) t)
      (declare (type fixnum j))
    (setf (aref a (1- j)) 
          (complex (- (aref d (- npoles j))) 0d0))) 


  (setq roots (zroots a :polish t)) 


  (do ((j 0 (+ j 1)))
      ((> j (1- npoles)) t)
      (declare (type fixnum j))
    (if (> (abs (aref roots j)) 1d0)
     (setf (aref roots j) (/ 1d0 (conjugate (aref roots j)))))) 

  (setf (aref a 0) (- (aref roots 0))) 
  (setf (aref a 1) #c(1d0 0d0)) 
  (do ((j 2 (+ j 1)))
      ((> j npoles) t)
      (declare (type fixnum j))
    (setf (aref a j) #c(1d0 0d0))
    (do ((i j (1- i)))
        ((< i 2) t)
        (declare (type fixnum i))
      (setf (aref a (1- i)) (+ (aref a (- i 2))
                          (* (- (aref roots (1- j))) (aref a (1- i))))))
    (setf (aref a 0) (* (- (aref roots (1- j))) (aref a 0)))) 

  (do ((j 1 (+ j 1)))
      ((> j npoles) t)
      (declare (type fixnum j))
    (setf (aref d (- npoles j)) (- (realpart (aref a (1- j)))))) 
  
  (return d)))

;------------------------------------------------------------------------------

(defun predic (data d nfut &key (npmax 100))
 (declare (type (simple-array double-float (*)) data)) 
 (declare (type (simple-array double-float (*)) d)) 
 (declare (type fixnum npmax))
 (declare (ignore npmax))

 (prog* ((ndata 0) 
  (npoles (array-dimension d 0))
  (future 
     (make-array nfut :element-type 'double-float :initial-element 0d0))
  (reg 
     (make-array npoles :element-type 'double-float :initial-element 0d0))
  (discrp 0d0) (sum 0d0))

  (declare (type (simple-array double-float (*)) future)) 
  (declare (type (simple-array double-float (*)) reg)) 
  (declare (type fixnum ndataa npoles))
  (declare (type double-float discrp sum))

  (setq ndata (array-dimension data 0))

  (do ((j 1 (+ j 1)))
      ((> j npoles) t)
    (setf (aref reg (1- j)) (aref data (- ndata j)))) 

  (do ((j 1 (+ j 1)))
      ((> j nfut) t)
    (setf discrp 0d0)
    (setf sum discrp)
    (do ((k 0 (+ k 1)))
        ((> k (1- npoles)) t)
      (setf sum (+ sum (* (aref d k) (aref reg k)))))
    (do ((k (1- npoles) (1- k)))
        ((< k 1) t)
      (setf (aref reg k) (aref reg (1- k))))

    (setf (aref reg 0) sum)
    (setf (aref future (1- j)) sum)) 
  
  (return future)))

;------------------------------------------------------------------------------

(defun fourn (data nn &key (isign 1))
 (declare (type (simple-array double-float (*)) data)) 
 (declare (type (simple-array fixnum (*)) nn))
 (declare (type fixnum isign))
 
 (prog ((ndim 0) (wr 0d0) (wi 0d0) (wpr 0d0) (wpi 0d0) (wtemp 0d0) 
        (theta 0d0) (ntot 0) (nprev 0) (n 0) (nrem 0)
        (ip1 0) (ip2 0) (ip3 0) (i2rev 0) (i3rev 0) 
        (tempr 0d0) (tempi 0d0) (ibit 0) (ifp1 0) (ifp2 0) (k1 0) (k2 0))
  (declare (type double-float wr wi wpr wpi wtemp theta)) 
  (declare (type fixnum ndim ntot nprev n nrem ip1 ip2 i2rev ip3
                          i3rev ibit ifp1 ifp2 k1 k2)) 

  (setq ndim (array-dimension nn 0))
  (setf ntot 1) 
  (do ((idim 1 (+ idim 1)))
      ((> idim ndim) t)
      (declare (type fixnum idim))
    (setf ntot (* ntot (fref nn idim))))
  (setf nprev 1) 
  (do ((idim 1 (+ idim 1)))
      ((> idim ndim) t)
      (declare (type fixnum idim))
    (setf n (fref nn idim))
    (setf nrem (floor (/ ntot (* n nprev))))
    (setf ip1 (* 2 nprev))
    (setf ip2 (* ip1 n))
    (setf ip3 (* ip2 nrem))
    (setf i2rev 1)
    (do ((i2 1 (+ i2 ip1)))
        ((> i2 ip2) t)
        (declare (type fixnum i2))
      (when (< i2 i2rev)
       (do ((i1 i2 (+ i1 2)))
           ((> i1 (- (+ i2 ip1) 2)) t)
           (declare (type fixnum i1))
         (do ((i3 i1 (+ i3 ip2)))
             ((> i3 ip3) t)
             (declare (type fixnum i3))

           (setf i3rev (- (+ i2rev i3) i2))
           (setf tempr (fref data i3))
           (setf tempi (fref data (+ i3 1)))
           (setf (fref data i3) (fref data i3rev))
           (setf (fref data (+ i3 1)) (fref data (+ i3rev 1)))
           (setf (fref data i3rev) tempr)
           (setf (fref data (+ i3rev 1)) tempi))))
      (setf ibit (floor (/ ip2 2)))
      label1
      (when (and (>= ibit ip1) (> i2rev ibit))
       (setf i2rev (- i2rev ibit)) (setf ibit (floor (/ ibit 2)))
       (go label1))

      (setf i2rev (+ i2rev ibit)))
    (setf ifp1 ip1)
    label2
    (when (< ifp1 ip2)  
     (setf ifp2 (* 2 ifp1))
     (setf theta (/ (* isign 6.28318530717959d0) (/ ifp2 ip1)))
     (setf wpr (* -2.0d0 (expt (sin (* 0.5d0 theta)) 2)))
     (setf wpi (sin theta)) 
     (setf wr 1.0d0) 
     (setf wi 0.0d0)
     (do ((i3 1 (+ i3 ip1)))
         ((> i3 ifp1) t)
         (declare (type fixnum i3))
       (do ((i1 i3 (+ i1 2)))
           ((> i1 (- (+ i3 ip1) 2)) t)
           (declare (type fixnum i1))
         (do ((i2 i1 (+ i2 ifp2)))
             ((> i2 ip3) t)
             (declare (type fixnum i2))
           (setf k1 i2)
           (setf k2 (+ k1 ifp1))
           (setf tempr (+ (* wr (fref data k2))
                          (* (- wi) (fref data (+ k2 1)))))
           (setf tempi (+ (* wr (fref data (+ k2 1)))
                          (* wi (fref data k2))))
           (setf (fref data k2) (- (fref data k1) tempr))
           (setf (fref data (+ k2 1)) (- (fref data (+ k1 1)) tempi))
           (setf (fref data k1) (+ (fref data k1) tempr))
           (setf (fref data (+ k1 1)) (+ (fref data (+ k1 1)) tempi))))
       (setf wtemp wr)
       (setf wr (+ (+ (* wr wpr) (* (- wi) wpi)) wr))
       (setf wi (+ (+ (* wi wpr) (* wtemp wpi)) wi)))
     (setf ifp1 ifp2)
     (go label2))
    (setf nprev (* n nprev))) 
   
  (return data)))
;------------------------------------------------------------------------------
;end of nr12.l

