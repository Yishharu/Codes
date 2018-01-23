; nr09.l
; Root finding and nonlinear sets of equations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;Modified by Ken Olum for Common Lisp, April 1996;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package "USER")
; functions:
;	scrsho: graph a function roughly 
;	zbrac: search for brackets on a root of a function
;	zbrak: search for brackets on a root of a function
;	rtbis: find a root by bisection
;	rtflsp: find a root by false position
;	rtsec: find a root by the secant method
;	zbrent: find a rooty by Brent's method
;	rtnewt: find a root by Newton-Raphson
;	rtsafe: find a root by Newton-Raphson and bisection
;	laguer: root of a polynomial by Laguerre's method
;	zroots: roots of a polynomial by Laguerre's method with deflation
;	qroot: root of a real or complex polynomial by Bairstow's method
;	mnewt: nonlinear system of equations by Newton-Raphson
;-----------------------------------------------------------------------------	

(defun scrsho (fx &key (iscr 60) (jscr 21))
 (declare (type fixnum iscr jscr))

 (prog (
  (x1 0d0) (x2 0d0) (xx #\-) (yy #\l) (blank #\space) (ff #\x) 
  (dx 0d0) (x 0d0) (ybig 0d0) (ysml 0d0) (dyj 0d0) (zero #\-) 
  (y (make-array iscr :element-type 'double-float :initial-element 0d0))
  (scr 
    (make-array (list iscr jscr) 
                :element-type 'character :initial-element #\space))
  (jz 0) (j 0))

  (declare (type double-float x1 x2 dx x ybig ysml dyj))
  (declare (type character xx yy blank ff zero))
  (declare (type (simple-array double-float (*)) y))
  (declare (type (simple-array character (* *)) scr))
  (declare (type fixnum jz j))



label1
  (princ "Enter x1: ")
  (setq x1 (read))
  (when (not (realp x1)) 
        (princ " x1 should be a double float in scrsho ")
        (terpri)
        (go label1))
  (terpri)
label2
  (princ "Enter x2 with x2 > x1 or x1 = x2 to stop: ")
  (setq x2 (read))
  (when (not (realp x2)) 
        (princ " x2 should be a double float in scrsho ")
        (terpri)
        (go label2))

  (if (= x1 x2) (return t))

  (do ((j 0 (1+ j)))
      ((> j (1- jscr)) t)
      (declare (type fixnum j))
    (setf (aref scr 0 j) yy)
    (setf (aref scr (1- iscr) j) yy))

  (do ((i 1 (1+ i)))
      ((> i (- iscr 2)) t)
      (declare (type fixnum i))
    (setf (aref scr i 0) xx)
    (setf (aref scr i (1- jscr)) xx)
    (do ((j 1 (1+ j)))
        ((> j (- jscr 2)) t)
        (declare (type fixnum j))
      (setf (aref scr i j) blank)))

  (setf dx (/ (- x2 x1) (dfloat (1- iscr))))
  (setf x x1)
  (setf ybig 0d0)
  (setf ysml ybig)

  (do ((i 0 (1+ i)))
      ((> i (1- iscr)) t)
      (declare (type fixnum i))
    (setf (aref y i) (dfloat-check (funcall fx x)))
    (if (< (aref y i) ysml) (setf ysml (aref y i)))
    (if (> (aref y i) ybig) (setf ybig (aref y i)))
    (setf x (+ x dx)))

   (if (= ybig ysml) (setf ybig (1+ ysml)))
   (setf dyj (/ (dfloat (1- jscr)) (- ybig ysml)))
   (setf jz (floor (- 1d0 (* ysml dyj))))

  (do ((i 1 (1+ i)))
      ((> i iscr) t)
      (declare (type fixnum i))
   (setf (aref scr (1- i) (1- jz)) zero)
   (setf j (floor (1+ (* (- (aref y (1- i)) ysml) dyj))))
   (setf (aref scr (1- i) (1- j)) ff))
  (format t " ~10,3,,,'dG " ybig)

  (do ((i 1 (1+ i)))
      ((> i iscr) t)
      (declare (type fixnum i))
      (format t "~a" (aref scr (1- i) (1- jscr))))
  (format t "~%")

    (do ((j jscr (1- j)))
        ((< j 2) t)
        (declare (type fixnum j))
        (format t "~%            ")
     (do ((i 1 (1+ i)))
         ((> i iscr) t)
         (declare (type fixnum i))
       (format t "~a" (aref scr (1- i) (1- j))))) 
  (format t "~%")

  (format t " ~10,3,,,'dG " ysml)
  (do ((i 1 (1+ i)))
      ((> i iscr) t)
      (declare (type fixnum i))
    (format t "~a" (aref scr (1- i) (1- jscr))))
  (format t "~%")
  (format t
 "           ~10,3,,,'dG                                        ~10,3,,,'dG~%" x1 x2) 
  (go label1)))

;-----------------------------------------------------------------------------

(defun zbrac (func x1 x2 &key (factor 1.6d0) (ntry 50))
 (declare (type double-float x1 x2 factor))
 (declare (type fixnum ntry))

 (prog ((succes nil) (f1 0d0) (f2 0d0))
  (declare (type symbol succes))
  (declare (type double-float f1 f2))
 
  (if (>= x1 x2) (error " initial range in zbrac must be non-empty. ")) 
  (setf f1 (dfloat-check (funcall func x1))) 
  (setf f2 (dfloat-check (funcall func x2))) 
  (setf succes t) 

  (do ((j 1 (+ j 1)))
      ((> j ntry) t)
      (declare (type fixnum j))
    (if (< (* f1 f2)  0d0) (go end))
    (cond 
     ((< (abs f1) (abs f2))
      (setf x1 (+ x1 (* factor (- x1 x2)))) 
      (setf f1 (aref func x1)))
     (t 
      (setf x2 (+ x2 (* factor (- x2 x1))))
      (setf f2 (dfloat-check (funcall func x2)))))) 

  (setf succes nil) 
end   
  (return (values x1 x2 succes))))
; check dimensions of xb1, xb2

;-------------------------------------------------------------------------

(defun zbrak (fx x1 x2 n nb)
 (declare (type double-float x1 x2))
 (declare (type fixnum n nb))

 (prog (
  (xb1 (make-array nb :element-type 'double-float :initial-element 0d0))
  (xb2 (make-array nb :element-type 'double-float :initial-element 0d0))
  (nbb 0) (x 0d0) (fp 0d0) (fc 0d0) (dx 0d0))

  (declare (type (simple-array double-float (*)) xb1)) 
  (declare (type (simple-array double-float (*)) xb2)) 
  (declare (type fixnum nbb))
  (declare (type double-float x fp fc dx))


  (setf nbb nb) 
  (setf nb 0) 
  (setf x x1) 
  (setf dx (/ (- x2 x1) (dfloat n))) 
  (setf fp (dfloat-check (funcall fx x))) 

  (do ((i 1 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))
    (setf x (+ x dx))
    (setf fc (funcall fx x))
    (when 
     (< (* fc fp) 0d0)
     (setf nb (1+ nb))
     (setf (aref xb1 (1- nb)) (- x dx)) 
     (setf (aref xb2 (1- nb)) x))
    (setf fp fc)
    (if (= nbb nb) (return (values xb1 xb2 nb)))) 
   
  (return (values xb1 xb2 nb))))

;-----------------------------------------------------------------------------


(defun rtbis (func x1 x2 xacc &key (jmax 40)) 
 (declare (type double-float x1 x2 xacc))
 (declare (type fixnum jmax))

 (prog ((rtbis 0d0) (dx 0d0) (fmid 0d0) (xmid 0d0) (f 0d0) (ret nil))
  (declare (type double-float dx fmid xmid f))
  (declare (type symbol ret))

  (setf fmid (funcall func x2)) 
  (setf f (dfloat-check (funcall func x1))) 
  (if (>= (* f fmid) 0d0) 
      (error " root must be bracketed for bisection in rtbis ")) 

  (cond 
   ((< f 0d0) 
    (setf rtbis x1)
    (setf dx (+ x2 (- x1))))
   (t 
    (setf rtbis x2)
    (setf dx (+ x1 (- x2))))) 

  (setq ret

   (do ((j 1 (+ j 1)))
      ((> j jmax) nil)
      (declare (type fixnum j))
    (setf dx (* dx 0.5d0))
    (setf xmid (+ rtbis dx))
    (setf fmid (funcall func xmid))
    (if (<= fmid 0d0) (setf rtbis xmid))
    (if (or (< (abs dx) xacc) (= fmid 0d0)) 
        (return (the double-float rtbis))))) 

  (if (null ret)  (error " too many bisections in rtbis "))

  (return ret)))
;-------------------------------------------------------------------------


(defun rtflsp (func x1 x2 xacc &key (maxit 30)) 
 (declare (type double-float x1 x2 xacc))
 (declare (type fixnum maxit))

 (prog ((f 0d0) (fl 0d0) (fh 0d0) (dx 0d0) (xh 0d0) (rtflsp 0d0)
        (del 0d0) (xl 0d0) (swap 0d0) (ret nil))
  (declare (type double-float f fl fh dx xh rtflsp del xl swap))
  (declare (type symbol ret))

  (setf fl (dfloat-check (funcall func x1))) 
  (setf fh (dfloat-check (funcall func x2)))
  (if (> (* fl fh) 0d0) 
      (error " root must be bracketed in rtflsp ")) 
  (cond 
   ((< fl 0d0)
    (setf xl x1) 
    (setf xh x2))
   (t 
    (setf xl x2) 
    (setf xh x1) 
    (setf swap fl) 
    (setf fl fh)
    (setf fh swap)))
 
  (setf dx (+ xh (- xl))) 
  (setq ret
  (do ((j 1 (+ j 1)))
      ((> j maxit) nil)
    (setf rtflsp (+ xl (/ (* dx fl) (+ fl (- fh)))))
    (setf f (dfloat-check (funcall func rtflsp)))
    (cond 
     ((< f 0d0) 
      (setf del (+ xl (- rtflsp)))
      (setf xl rtflsp) (setf fl f))
     (t
      (setf del (+ xh (- rtflsp))) 
      (setf xh rtflsp) 
      (setf fh f)))
    (setf dx (+ xh (- xl)))
    
    (if (or (< (abs del) xacc) (= f 0d0)) 
        (return (the double-float rtflsp)))
    (if (or (< (abs del) xacc) (= f 0d0)) (return (the double-float rtflsp))))) 
   (if (null ret) (error " rtflsp exceed maximum iterations "))
   (return ret)))

;-------------------------------------------------------------------------

(defun rtsec (func x1 x2 xacc &key (maxit 30))
 (declare (type double-float x1 x2 xacc))

 (prog ((rtsec 0d0) (fl 0d0) (f 0d0) (dx 0d0) (xl 0d0) (swap 0d0))
  (declare (type double-float rtsec fl f dx xl swap))

  (setf fl (dfloat-check (funcall func x1)) )
  (setf f (dfloat-check (funcall func x2))) 
  (cond 
   ((< (abs fl) (abs f)) 
    (setf rtsec x1)
    (setf xl x2) 
    (setf swap fl) 
    (setf fl f) 
    (setf f swap))
   (t
    (setf xl x1) 
    (setf rtsec x2))) 

  (do ((j 1 (+ j 1)))
      ((> j maxit) t)
      (declare (type fixnum j))
    (setf dx (/ (* (+ xl (- rtsec)) f) (+ f (- fl))))
    (setf xl rtsec)
    (setf fl f)
    (setf rtsec (+ rtsec dx))
    (setf f (dfloat-check (funcall func rtsec)))
    
    (if (or (< (abs dx) xacc) (= f 0d0)) (go end)) )
  
  (error " rtsec exceed maximum iterations ")
end
  (return (the double-float rtsec))))
;-------------------------------------------------------------------------


(defun zbrent (func x1 x2 tol &key (itmax 100) (eps 3.0d-8))
 (declare (type double-float x1 x2 eps))
 (declare (type fixnum itmax))

 (prog ((zbrent 0d0) (a 0d0) (b 0d0) (c 0d0) (fa 0d0)
        (fb 0d0) (fc 0d0) (r 0d0) (p 0d0) (q 0d0) (d 0d0) 
        (e 0d0) (s 0d0) (xm 0d0) (tol1 0d0))
  (declare (type double-float zbrent a b c fa fb fc r p q d e s xm tol1))

  (setf a x1) 
  (setf b x2) 
  (setf fa (dfloat-check (funcall func a))) 
  (setf fb (dfloat-check (funcall func b)))
  (if (> (* fb fa) 0d0) (error " root must be bracketed for zbrent ")) 
  (setf fc fb) 
  (do ((iter 1 (1+ iter)))
      ((> iter itmax) t)
      (declare (type fixnum iter))
    (when 
     (> (* fb fc) 0d0) 
     (setf c a) 
     (setf fc fa)
     (setf d (- b a)) 
     (setf e d))
    (when (< (abs fc) (abs fb)) 
     (setf a b)
     (setf b c) 
     (setf c a) 
     (setf fa fb) 
     (setf fb fc) 
     (setf fc fa))
    (setf tol1 (+ (* (* 2d0 eps) (abs b)) (* 0.5d0 tol)))
    (setf xm (* 0.5d0 (+ c (- b))))
    (when 
     (or (<= (abs xm) tol1) (= fb 0d0))
     (setf zbrent b) 
;     (return (the double-float zbrent)))
     (go end))
    (cond ((and (>= (abs e) tol1) (> (abs fa) (abs fb)))
      (setf s (/ fb fa))
     (cond 
      ((= a c) 
       (setf p (* (* 2d0 xm) s))
       (setf q (- 1 s)))
      (t (setf q (/ fa fc))
       (setf r (/ fb fc))
       (setf p (* s
                  (+ (* (* (* 2 xm) q) (- q r))
                     (* (- (+ b (- a))) (1- r)))))
       (setf q (* (* (1- q) (1- r)) (1- s)))))
     (if (> p 0d0) (setf q (- q))) (setf p (abs p))
     (cond
      ((< (* 2d0 p)
         (min (+ (* (* 3 xm) q) (- (abs (* tol1 q)))) (abs (* e q))))
       (setf e d) (setf d (/ p q)))
      (t
       (setf d xm) 
       (setf e d))))
    (t 
     (setf d xm) 
     (setf e d)))
    (setf a b)
    (setf fa fb)
    (if 
     (> (abs d) tol1) 
     (setf b (+ b d))
     (setf b (+ b (signp tol1 xm))))
    (setf fb (dfloat-check (funcall func b)))) 
   
  (error " zbrent exceeding maximum iterations. ") 
;  (setf zbrent b) 
end   
  (return (the double-float zbrent))))
;-------------------------------------------------------------------------


(defun rtnewt (func funcd x1 x2 xacc &key (jmax 20))
 (declare (type double-float x1 x2 xacc))
 (declare (type fixnum jmax))

 (prog ((rtnewt 0d0) (dx 0d0) (df 0d0) (f 0d0))
  (declare (type double-float dx df f rtnewt))

  (setf rtnewt (* 0.5d0 (+ x1 x2))) 
  (do ((j 1 (+ j 1)))
      ((> j jmax) t)
      (declare (type fixnum j))
    (setq f (dfloat-check (funcall func rtnewt))
          df (dfloat-check (funcall funcd rtnewt)))
    (setf dx (/ f df))
    (setf rtnewt (+ rtnewt (- dx)))
    (if (< (* (+ x1 (- rtnewt)) (+ rtnewt (- x2))) 0d0) 
        (error " rtnewt jumped out of brackets "))
    
    (if (< (abs dx) xacc) (go end))) 
  
  (error " rtnewt exceeding maximum iterations ")
end
  (return (the double-float rtnewt))))
;-------------------------------------------------------------------------


(defun rtsafe (func funcd x1 x2 xacc &key (maxit 100))
 (declare (type double-float x1 x2 xacc))
 (declare (type fixnum maxit))

 (prog ((fl 0d0) (fh 0d0) (rtsafe 0d0) (dx 0d0) (dxold 0d0) 
        (xh 0d0) (xl 0d0) (f 0d0) (df 0d0) (temp 0d0))
  (declare (type double-float fl fh rtsafe dx dxold xh f xl df temp))

  (setq fl (dfloat-check (funcall func x1)) 
        df (dfloat-check (funcall funcd x1)))
  (setq fh (dfloat-check (funcall func x2))
        df (dfloat-check (funcall funcd x2)))
  (if (>= (* fl fh) 0d0) (error " root must be bracketed for rtsafe ")) 

  (cond 
   ((< fl 0d0)
    (setf xl x1) 
    (setf xh x2))
   (t 
    (setf xh x1) 
    (setf xl x2))) 

  (setf rtsafe (* 0.5d0 (+ x1 x2))) 
  (setf dxold (abs (+ x2 (- x1)))) 
  (setf dx dxold) 
  (setq f (dfloat-check (funcall func rtsafe))
        df (dfloat-check (funcall funcd rtsafe)))
  (do ((j 1 (+ j 1)))
      ((> j maxit) t)
    (cond 
     ((or (>= (* (+ (* (+ rtsafe (- xh)) df) (- f))
                 (+ (* (+ rtsafe (- xl)) df) (- f)))
             0d0)
          (> (abs (* 2d0 f)) (abs (* dxold df))))
     (setf dxold dx)
     (setf dx (* 0.5d0 (+ xh (- xl)))) 
     (setf rtsafe (+ xl dx)) 
     (if (= xl rtsafe) (go end)))
    (t 
     (setf dxold dx)
     (setf dx (/ f df)) 
     (setf temp rtsafe) 
     (setf rtsafe (+ rtsafe (- dx)))
     (if (= temp rtsafe) (go end))))
    
    (if (< (abs dx) xacc) (go end))
    (setq f (dfloat-check (funcall func rtsafe))
          df (dfloat-check (funcall funcd rtsafe)))
    (if 
     (< f 0d0) 
     (setf xl rtsafe)
     (setf xh rtsafe))) 
   
  (error " rtsafe exceeding maximum iterations ")
end
  (return (the double-float rtsafe))))

;-------------------------------------------------------------------------

(defun laguer (a m x &key (eps 1.0d-6) (polish t) (epss 6.0d-8) (maxit 100))
 (declare (type (simple-array (complex double-float) (*)) a))
 (declare (type (complex double-float) x))
 (declare (type symbol polish))
 (declare (type double-float epss))
 (declare (type fixnum maxit m))

 (prog ((dx #c(0d0 0d0)) (x1 #c(0d0 0d0)) (b #c(0d0 0d0)) 
        (d #c(0d0 0d0)) (f #c(0d0 0d0)) (g #c(0d0 0d0))
        (h #c(0d0 0d0)) (sq #c(0d0 0d0)) (gp #c(0d0 0d0)) 
        (gm #c(0d0 0d0)) (g2 #c(0d0 0d0)) (zero #c(0d0 0d0)) 
        (err 0d0) (abx 0d0) (cdx 0d0));(dxold 0d0) 
  (declare (type (complex double-float) dx x1 b d f g h sq gp gm g2 zero))
  (declare (type double-float abx cdx err))

;  (setq mp1 (1+ m))
 
  (setq zero #c(0d0 0d0)) 
;  (setf dxold (abs x)) 
  (do ((iter 1 (+ iter 1)))
      ((> iter maxit) t)
      (declare (type fixnum iter))
    (setf b (aref a m))
    (setf err (abs b))
    (setf d zero)
    (setf f zero)
    (setf abx (abs x))

    (do ((j (1- m) (1- j)))
        ((< j 0) t)
        (declare (type fixnum j))
      (setf f (+ (* x f) d))
      (setf d (+ (* x d) b))
      (setf b (+ (* x b) (aref a j)))
      (setf err (+ (abs b) (* abx err))))

    (setf err (* epss err))
    (cond
     ((<= (abs b) err) 
      (go end))
     (t 
      (setf g (/ d b)) 
      (setf g2 (* g g))
      (setf h (+ g2 (/ (* -2d0 f) b)))
      (setf sq (sqrt (* (1- m) (- (* m h) g2))))
      (setf gp (+ g sq)) (setf gm (- g sq))
      (if (< (abs gp) (abs gm)) (setf gp gm)) 
      (setf dx (/ m gp))))

    (setf x1 (- x dx))
    
    (if (= x x1) (go end))
    (setf x x1)
    (setf cdx (abs dx))
;    (setf dxold cdx)
    (if (and (not polish) 
             (<= cdx (* eps (abs x)))) (go end))) 
   
  (error " too many iterations in laguer ")
end
  (return (the (complex double-float) x))))

;-------------------------------------------------------------------------

(defun zroots (a &key
         (polish nil) (eps 1.0d-6) (epss 1.0d-6) (maxit 100) (maxm 101)) 
 (declare (type (simple-array (complex double-float) (*)) a))
 (declare (type fixnum maxm maxit))
 (declare (ignore maxm))
 (declare (type double-float eps epss))
 (declare (type symbol polish))
 

 (prog* (
  (m (1- (array-dimension a 0)))
  (roots 
    (make-array m :element-type '(complex double-float) 
                  :initial-element #c(0d0 0d0)))
  (ad 
    (make-array (1+ m) :element-type '(complex double-float) 
                     :initial-element #c(0d0 0d0)))
  (x #c(0d0 0d0)) (b #c(0d0 0d0)) (c #c(0d0 0d0)) (isav 0))

  (declare (type (simple-array (complex double-float) (*)) roots ad))
  (declare (type (complex double-float) x b c))
  (declare (type fixnum m isav))

 

  (do ((j 0 (+ j 1)))
      ((> j m) t)
      (declare (type fixnum j))
    (setf (aref ad j) (aref a j)))
 
  (do ((j  m (1- j)))
      ((< j 1) t)
      (declare (type fixnum j))
    (setf x #c(0d0 0d0))
    (setq x (laguer ad j x :eps eps :polish nil)) 
    (if (<= (abs (imagpart x)) (* (* 2d0 (expt eps 2)) (abs (realpart x))))
      (setf x (complex (realpart x) 0d0)))
    (setf (aref roots (1- j)) x)
    (setf b (aref ad j))
    (do ((jj j (1- jj)))
        ((< jj 1) t)
        (declare (type fixnum jj))
      (setf c (aref ad (1- jj)))
      (setf (aref ad (1- jj)) b)
      (setf b (+ (* x b) c)))) 

  (when 
   polish
   (do ((j 0 (+ j 1)))
       ((> j (1- m)) t)
       (declare (type fixnum j))
     (setf (aref roots j) (laguer a m (aref roots j) 
               :eps eps :epss epss :polish t :maxit maxit))))

  (do ((j 2 (+ j 1)))
      ((> j m) t)
      (declare (type fixnum j))
    (setf x (aref roots (1- j)))
    (do ((i (1- j) (1- i)))
        ((< i 1) t)
        (declare (type fixnum i))
      (when (<= (realpart (aref roots (1- i))) (realpart x)) 
          (setq isav i) (go label10))
      (setf (aref roots i) (aref roots (1- i))))

    (setf isav 0)
    label10
    (setf (aref roots isav) x)) 
   
  (return roots)))

;-------------------------------------------------------------------------

(defun qroot (p b c eps &key (nmax 20) (itmax 20) (tiny 1.0d-6)) 
 (declare (type (simple-array double-float (*)) p))
 (declare (type double-float b c tiny))
 (declare (type fixnum nmax itmax))
 (declare (ignore nmax))

 (prog* (
  (n (array-dimension p 0))
  (q (make-array n :element-type 'double-float :initial-element 0d0))
  (d (make-array 3 :element-type 'double-float :initial-element 0d0))
  (rem (make-array n :element-type 'double-float :initial-element 0d0))
  (qq (make-array n :element-type 'double-float :initial-element 0d0))
  (s 0d0) (r 0d0)
  (sc 0d0) (rc 0d0) (sb 0d0) (rb 0d0) (div 0d0) (delb 0d0) (delc 0d0)) 

  (declare (type (simple-array double-float (*)) q)) 
  (declare (type (simple-array double-float (*)) d)) 
  (declare (type (simple-array double-float (*)) rem)) 
  (declare (type (simple-array double-float (*)) qq)) 
  (declare (type fixnum n))
  (declare (type double-float s r sc rc sb rb div delb delc))

  (progn qq)				;Ignorable

  (setf (aref d 2) 1d0) 
  (do ((iter 1 (+ iter 1)))
      ((> iter itmax) t)
      (declare (type fixnum iter))
    (setf (aref d 1) b)
    (setf (aref d 0) c)

    (multiple-value-setq (q rem) (poldiv p d))
    (setf s (aref rem 0))

    (setf r (aref rem 1))

    (multiple-value-setq (qq rem) (poldiv q d))

    (setf sc (- (aref rem 0)))
    (setf rc (- (aref rem 1)))

    (do ((i (- n 2) (1- i)))
        ((< i 0) t)
        (declare (type fixnum i))
      (setf (aref q (+ i 1)) (aref q i)))

    (setf (aref q 0) 0d0)
    (multiple-value-setq (qq rem) (poldiv q d))

    (setf sb (- (aref rem 0)))
    (setf rb (- (aref rem 1)))
    (setf div (/ 1d0 (- (* sb rc) (* sc rb))))
    (setf delb (* (- (* r sc) (* s rc)) div))
    (setf delc (* (+ (* (- r) sb) (* s rb)) div))
    (setf b (+ b delb))
    (setf c (+ c delc))

    (if (and (or (<= (abs delb) (* eps (abs b))) (< (abs b)  tiny))
             (or (<= (abs delc) (* eps (abs c))) (< (abs c)  tiny)))
       (go end))) 
   
  (error " too many iterations in qroot ")
end
 (return (values b c))))
;-------------------------------------------------------------------------

(defun mnewt (x usrfun 
              &key (ntrial 4) (tolx 1.0d-6) (tolf 1.0d-6))
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type double-float tolx tolf))
 (declare (type fixnum ntrial))

 (prog* (
  (n (array-dimension x 0))
  (alpha (make-array (list n n) :element-type 'double-float
                                       :initial-element 0d0))
  (beta (make-array n :element-type 'double-float :initial-element 0d0))
  (indx (make-array n :element-type 'fixnum :initial-element 0))
  (errf 0d0) (errx 0d0))

  (declare (type (simple-array double-float (* *)) alpha)) 
  (declare (type (simple-array double-float (*)) beta)) 
  (declare (type (simple-array fixnum (*)) indx)) 
  (declare (type double-float errf errx))
  (declare (type fixnum n))



  (do ((k 1 (+ k 1)))
      ((> k ntrial) t)
      (declare (type fixnum k))
    (multiple-value-setq (alpha beta) (funcall usrfun x))
    (setf errf 0d0)
    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
        (declare (type fixnum i))
      (setf errf (+ errf (abs (aref beta i)))))
    
    (if (<= errf tolf) (go end))
    (multiple-value-setq (alpha indx) (ludcmp alpha)) ; gives the transpose
    (setq beta (lubksb alpha indx beta))
    (setf errx 0d0)
    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
        (declare (type fixnum i))
      (setf errx (+ errx (abs (aref beta i))))
      (setf (aref x i) (+ (aref x i) (aref beta i))))
    
    (if (<= errx tolx) (go end))) 
end   
  (return x)))

;-----------------------------------------------------------------------------
; end of nr09.l

