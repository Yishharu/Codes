; nr10.l
; Minimization or Maximization of Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	mnbrak: bracket a minimum of a function
;	golden: find a minimum of a function by golden section
;	brent: find a minumum of a function by Brent's method
;	dbrent: find a minumum using derivative information
;	amoeba: minimum of a function, multidimensional downhill simplex

;	powell: minimum of a function, multidimensional Powel's method
;	 linmin: minumum of a function, along a ray in multidimensional
;	 f1dim: minimum of a function, used by linmin

;	frprmn: minimum of a function, multidimensional, conjugage gradient
;	dfpmin: minimum of a function, multidimensions, variable metric

;	simplex-tableau: load the tableau 
;	  simplx, simp1, simp2, simp3
;	anneal: travelling salesman by simulated annealing
;	 revcst: value of the cost funtion for a proposed path reversal
;	 revers: performs a path segment reversal
;	 trncst: value of the cost functions for a proposed path transport
;	 trnspt: performs the actual path transport
;-----------------------------------------------------------------------------
(defun mnbrak (ax bx func &key (glimit 100d0) (tiny 1.0d-20))
 (declare (type double-float ax bx tiny glimit))

 (prog ((cx 0d0) (fa 0d0) (fb 0d0) (fc 0d0) (fu 0d0) 
        (gold 0d0) (dum 0d0) (u 0d0) (ulim 0d0) (r 0d0) (q 0d0))
  (declare (type double-float cx fa fb fc gold dum u ulim r q fu))

  (setq gold 1.618034d0) 

  (setf fa (dfloat (funcall func ax))) 
  (setf fb (dfloat (funcall func bx)))
  (when 
   (> fb fa) 
   (setf dum ax) 
   (setf ax bx)
   (setf bx dum) 
   (setf dum fb) 
   (setf fb fa) 
   (setf fa dum)) 
  (setf cx (+ bx (* gold (- bx ax)))) 
  (setf fc (dfloat (funcall func cx))) 
label1 
  (when 
   (>= fb fc)
   (setf r (* (- bx ax) (- fb fc)))
   (setf q (* (- bx cx) (- fb fa)))

   (setf u (+ bx
              (/ (-
                    (+ (* (- bx cx) q) (* (- (- bx ax)) r)))
                 (* 2d0
                    (signp (max (abs (- q r)) tiny)
                    (+ q (- r)))))))

   (setf ulim (+ bx (* glimit (- cx bx))))
   (cond 
    ((> (* (- bx u) (- u cx)) 0d0)
     (setf fu (dfloat (funcall func u)))
     (cond 
      ((< fu fc)  
       (setf ax bx) 
       (setf fa fb)
       (setf bx u) 
       (setf fb fu) 
       (return (values ax bx cx fa fb fc)))
      ((> fu fb) 
       (setf cx u)
       (setf fc fu) 
       (return (values ax bx cx fa fb fc))))
     (setf u (+ cx (* gold (- cx bx)))) 
     (setf fu (dfloat (funcall func u))))
    ((> (* (- cx u) (- u ulim)) 0d0) 
     (setf fu (dfloat (funcall func u)))
     (when 
       (< fu fc) 
       (setf bx cx) 
       (setf cx u)
       (setf u (+ cx (* gold (- cx bx)))) 
       (setf fb fc) 
       (setf fc fu)
       (setf fu (dfloat (funcall func u)))))
    ((>= (* (- u ulim) (- ulim cx)) 0d0) 
     (setf u ulim) 
     (setf fu (dfloat (funcall func u))))
    (t
     (setf u (+ cx (* gold (- cx bx)))) 
     (setf fu (dfloat (funcall func u)))))
   (setf ax bx) 
   (setf bx cx) 
   (setf cx u) 
   (setf fa fb) 
   (setf fb fc) 
   (setf fc fu)
   (go label1)) 
   
  (return (values ax bx cx fa fb fc))))

;-----------------------------------------------------------------------------

(defun golden (ax bx cx f &key (tol 1.0d-5))
 (declare (type double-float ax bx cx tol))

 (prog ((r 0d0) (c 0d0) (x0 0d0) (x3 0d0) (xmin 0d0) 
        (f1 0d0) (f2 0d0) (x1 0d0) (x2 0d0) (golden 0d0))
  (declare (type double-float r c x0 x3 xmin f1 f2 x1 x2 golden))

  (setq r 0.618034d0
        c 0.381966d0) 
  (setf x0 ax) 
  (setf x3 cx) 
  (cond 
   ((> (abs (- cx bx)) (abs (- bx ax)))
    (setf x1 bx)
    (setf x2 (+ bx (* c (- cx bx)))))
   (t  
    (setf x2 bx)
    (setf x1 (- bx (* c (- bx ax)))))) 

  (setf f1 (dfloat (funcall f x1)) )
  (setf f2 (dfloat (funcall f x2))) 
  label1 
  (when 
   (> (abs (- x3 x0)) (* tol (+ (abs x1) (abs x2))))
   
   (cond 
    ((< f2 f1) 
     (setf x0 x1) 
     (setf x1 x2)
     (setf x2 (+ (* r x1) (* c x3))) 
     (setf f1 f2) 
     (setf f2 (dfloat (funcall f x2))))
    (t
     (setf x3 x2) 
     (setf x2 x1) 
     (setf x1 (+ (* r x2) (* c x0)))
     (setf f2 f1) 
     (setf f1 (dfloat (funcall f x1)))))
   (go label1)) 
  (cond 
   ((< f1 f2) 
    (setf golden f1) 
    (setf xmin x1))
   (t
    (setf golden f2) 
    (setf xmin x2))) 
   
  (return (values golden xmin))))

;-----------------------------------------------------------------------------

(defun brent (ax bx cx f &key (tol 1.0d-4) (itmax 100) (zeps 1.0d-10))
 (declare (type double-float ax bx cx  tol zeps))
 (declare (type fixnum itmax))

 (prog ((a 0d0) (b 0d0) (v 0d0) (w 0d0) (x 0d0) (brent 0d0) 
        (cgold 0d0) (fv 0d0) (fw 0d0) (e 0d0) (fx 0d0) (xm 0d0) 
        (tol1 0d0) (tol2 0d0) (r 0d0) (q 0d0) (p 0d0) (etemp 0d0) 
        (d 0d0) (u 0d0) (fu 0d0) (xmin 0d0))
  (declare (type double-float a b v w x brent
             cgold fv fw e fx xm tol1 tol2 r q p etemp d u fu xmin))

  (setq cgold 0.381966d0) 
  (setf a (min ax cx)) 
  (setf b (max ax cx)) 
  (setf v bx) 
  (setf w v) 
  (setf x v) 
  (setf e 0d0) 
  (setf fx (dfloat (funcall f x))) 
  (setf fv fx) 
  (setf fw fx) 
  (do ((iter 1 (+ iter 1)))
      ((> iter itmax) t)
      (declare (type fixnum iter))
    (setf xm (* 0.5d0 (+ a b)))
    (setf tol1 (+ (* tol (abs x)) zeps))
    (setf tol2 (* 2d0 tol1))
    (if (<= (abs (- x xm)) (- tol2 (* 0.5d0 (- b a)))) (go label3))
    (when 
     (> (abs e) tol1)
     (setf r (* (+ x (- w)) (+ fx (- fv))))
     (setf q (* (+ x (- v)) (+ fx (- fw))))
     (setf p (+ (* (+ x (- v)) q) (* (- (+ x (- w))) r)))
     (setf q (* 2d0 (+ q (- r)))) (if (> q 0d0) (setf p (- p)))
     (setf q (abs q)) (setf etemp e) (setf e d)
     (if (or (>= (abs p) (abs (* 0.5d0 q etemp)))
             (<= p (* q (- a x)))
             (>= p (* q (- b x))))
       (go label1))
     (setf d (/ p q)) (setf u (+ x d))
     (if (or (< (+ u (- a)) tol2) (< (+ b (- u)) tol2))
       (setf d (signp tol1 (+ xm (- x)))))
     (go label2))
label1
    (if 
     (>= x xm) 
     (setf e (+ a (- x)))
     (setf e (+ b (- x))))

    (setf d (* cgold e))
label2
    (if 
     (>= (abs d) tol1)
     (setf u (+ x d))
     (setf u (+ x (signp tol1 d))))

    (setf fu (dfloat (funcall f u)))
    (cond 
     ((<= fu fx)
      (if 
       (>= u x) 
       (setf a x)
       (setf b x))
      (setf v w) 
      (setf fv fw) (setf w x) (setf fw fx) (setf x u) (setf fx fu))
     (t
      (if 
       (< u x)  
       (setf a u) 
       (setf b u))
      (cond 
       ((or (<= fu fw) (= w x)) 
        (setf v w)
        (setf fv fw) 
        (setf w u) 
        (setf fw fu))
       ((or (<= fu fv) (= v x) (= v w)) 
        (setf v u)
        (setf fv fu)))))) 
   
  (error " brent exceed maximum iterations. ") 
  label3 
  (setf xmin x) 
  (setf brent fx) 
   
  (return (values brent xmin))))

;-----------------------------------------------------------------------------

(defun dbrent (ax bx cx f df &key (tol 1.0d-4) (itmax 100) (zeps 1.0d-10))
 (declare (type double-float ax bx cx  tol zeps))
 (declare (type fixnum itmax))

 (prog ((a 0d0) (b 0d0) (v 0d0) (w 0d0) (x 0d0) (dbrent 0d0) 
        (cgold 0d0) (fv 0d0) (fw 0d0) (dx 0d0) (dv 0d0) (dw 0d0)
        (u1 0d0) (u2 0d0) (ok1 nil) (ok2 nil) (e 0d0) (fx 0d0) 
        (xm 0d0) (tol1 0d0) (tol2 0d0) (d1 0d0) (d2 0d0) (xmin 0d0)
        (olde 0d0) (d 0d0) (u 0d0) (fu 0d0) (du 0d0))
  (declare (type double-float a b v w x brent fv fw dx dv dw xmin
              u1 u2 e fx xm tol1 tol2 d1 d2 olde d u fu du cgold))
  (declare (type symbol ok1 ok2))
  (declare (ignore cgold))

  (setf a (min ax cx)) 
  (setf b (max ax cx)) 
  (setf v bx) 
  (setf w v) 
  (setf x v) 
  (setf e 0d0) 
  (setf fx (dfloat (funcall f x)) )
  (setf fv fx) 
  (setf fw fx) 
  (setf dx (dfloat (funcall df x)))
  (setf dv dx)
  (setf dw dx)
  (do ((iter 1 (+ iter 1)))
      ((> iter itmax) t)
      (declare (type fixnum iter))
    (setf xm (* 0.5d0 (+ a b)))
    (setf tol1 (+ (* tol (abs x)) zeps))
    (setf tol2 (* 2d0 tol1))
    (if (<= (abs (- x xm)) (- tol2 (* 0.5d0 (- b a)))) (go label3))
    (when 
     (> (abs e) tol1)
     (setq d1 (* 2d0 (- b a)))
     (setq d2 d1)
     (if (not (= dw dx)) (setq d1 (/ (* (- w x) dx) (- dx dw))))
     (if (not (= dv dx)) (setq d2 (/ (* (- v x) dx) (- dx dv))))
     (setq u1 (+ x d1))
     (setq u2 (+ x d2))
     (setq ok1 (and (> (* (- a u1) (- u1 b)) 0d0) (<= (* dx d1) 0d0)))
     (setq ok2 (and (> (* (- a u2) (- u2 b)) 0d0) (<= (* dx d2) 0d0)))
     (setq olde e)
     (setq e d)
     (cond
       ((not (or ok1 ok2)) (go label1))
       ((and ok1 ok2)
        (if (< (abs d1) (abs d2)) (setq d d1) (setq d d2)))
       (ok1 (setq d d1))
       (t (setq d d2)))
     (if (> (abs d) (abs (* 0.5d0 olde))) (go label1))
     (setq u (+ x d))
     (if (or (< (- u a) tol2) (< (- b u) tol2)) 
         (setq d (signp tol1 (- xm x))))
     (go label2))
    label1
    (if (>= dx 0d0) 
        (setq e (- a x)) 
        (setq e (- b x)))
    (setq d (* 0.5d0 e))
    label2
    (cond
     ((>= (abs d) tol1)
       (setq u (+ x d))
       (setq fu (dfloat (funcall f u))))
     (t 
       (setq u (signp tol1 d))
       (setq fu (dfloat (funcall f u)))
       (if (> fu fx) (go label3))))
    (setq du (dfloat (funcall df u)))
    (cond 
     ((<= fu fx)
      (if 
       (>= u x) 
       (setf a x)
       (setf b x))
      (setf v w) 
      (setf fv fw) (setf dv dw) (setf w x) (setf fw fx) 
      (setf dw dx) (setf x u) (setf fx fu) (setf dx du))
     (t
      (if 
       (< u x)  
       (setf a u) 
       (setf b u))
      (cond 
       ((or (<= fu fw) (= w x)) 
        (setf v w)
        (setf fv fw) 
        (setf dv dw)
        (setf w u) 
        (setf fw fu)
        (setf dw du))
       ((or (<= fu fv) (= v x) (= v w)) 
        (setf v u)
        (setf fv fu) (setf dv du)))))) 
   
  (error " dbrent exceed maximum iterations. ") 
  label3 
  (setf xmin x) 
  (setf dbrent fx) 
   
  (return (values dbrent xmin))))

;-----------------------------------------------------------------------------
(defun amoeba (p y funk &key (itmax 500) (ftol 1.0d-5))
 (declare (type double-float ftol))
 (declare (type (simple-array double-float (* *)) p))
 (declare (type (simple-array double-float (*)) y))

 (prog* 
  ((ndim (array-dimension p 1)) (ihi 0) (inhi 0)
  (alpha 1.0d0)
  (beta 0.5d0)
  (gamma 2.0d0)
  (mpts 0) (iter 0) (ilo 0) (rtol 0d0) (ypr 0d0) (yprr 0d0) 
  (pr (make-array ndim :element-type 'double-float :initial-element 0d0))
  (prr (make-array ndim :element-type 'double-float :initial-element 0d0))
  (pbar (make-array ndim :element-type 'double-float :initial-element 0d0)))

  (declare (type (simple-array double-float (*)) pr)) 
  (declare (type (simple-array double-float (*)) prr)) 
  (declare (type (simple-array double-float (*)) pbar))
  (declare (type double-float alpha beta gamma rtol ypr yprr))
  (declare (type fixnum mpts iter ilo))

  
  (setf mpts (+ ndim 1)) 
  (setf iter 0) 
  label1 
  (setf ilo 1) 
  (cond 
   ((> (fref y 1) (fref y 2)) 
    (setf ihi 1)
    (setf inhi 2))
   (t 
    (setf ihi 2) 
    (setf inhi 1))) 

  (do ((i 1 (+ i 1)))
      ((> i mpts) t)
      (declare (type fixnum i))
    (if (< (fref y i) (fref y ilo)) (setf ilo i))
    (cond 
      ((> (fref y i) (fref y ihi))
       (setf inhi ihi) (setf ihi i))
      (t
       (if (not (= i ihi)) (setf inhi i))))) 

  (setf rtol (/ (* 2 (abs (+ (fref y ihi) (- (fref y ilo)))))
                (+ (abs (fref y ihi)) (abs (fref y ilo))))) 
  
  (if (< rtol ftol) (return (values p y iter))) 
  (if (= iter itmax) 
      (error "amoeba exceeding the maximum number of iterations")) 
  (setf iter (+ iter 1)) 
    
  (do ((i 1 (+ i 1)))
      ((> i mpts) t)
      (declare (type fixnum i))
    (if (not (= i ihi))
     (do ((j 1 (+ j 1)))
         ((> j ndim) t)
         (declare (type fixnum j))
       (fset (fref pbar j) (+ (fref pbar j) (fref p i j)))))) 

  (do ((j 1 (+ j 1)))
      ((> j ndim) t)
      (declare (type fixnum j))
    (fset (fref pbar j) (/ (fref pbar j) (dfloat ndim)))
    (fset (fref pr j) (+ (* (1+ alpha) (fref pbar j))
                         (* (- alpha) (fref p ihi j)))))
 
  (setf ypr (dfloat (apply funk (list-array pr))) )
  (cond 
   ((<= ypr (fref y ilo))
    (do ((j 1 (+ j 1)))
        ((> j ndim) t)
        (declare (type fixnum j))
      (fset (fref prr j) (+ (* gamma (fref pr j))
                            (* (+ 1 (- gamma)) (fref pbar j)))))

    (setf yprr (dfloat (apply funk (list-array prr))))
    (cond 
     ((< yprr (fref y ilo))
      (do ((j 1 (+ j 1)))
          ((> j ndim) t)
          (declare (type fixnum j))
        (fset (fref p ihi j) (fref prr j)))
      (fset (fref y ihi) yprr))
     (t
      (do ((j 1 (+ j 1)))
          ((> j ndim) t)
          (declare (type fixnum j))
        (fset (fref p ihi j) (fref pr j)))
      (fset (fref y ihi) ypr))))

   ((>= ypr (fref y inhi))
    (when 
     (< ypr (fref y ihi))
     (do ((j 1 (+ j 1)))
         ((> j ndim) t)
         (declare (type fixnum j))
       (fset (fref p ihi j) (fref pr j)))
     (fset (fref y ihi) ypr))
    (do ((j 1 (+ j 1)))
        ((> j ndim) t)
        (declare (type fixnum j))
      (fset (fref prr j) (+ (* beta (fref p ihi j))
                            (* (+ 1 (- beta)) (fref pbar j)))))

    (setf yprr (dfloat (apply funk (list-array prr))))
    (cond 
     ((< yprr (fref y ihi)) 
      (do ((j 1 (+ j 1)))
          ((> j ndim) t)
          (declare (type fixnum j))
        (fset (fref p ihi j) (fref prr j)))
      (fset (fref y ihi) yprr))
     (t
      (do ((i 1 (+ i 1)))
          ((> i mpts) t)
          (declare (type fixnum i))
        (when (not (= i ilo))
         (do ((j 1 (+ j 1)))
             ((> j ndim) t)
             (declare (type fixnum j))
           (fset (fref pr j) (* 0.5d0 (+ (fref p i j) (fref p ilo j))))
           (fset (fref p i j) (fref pr j)))
         (fset (fref y i) (dfloat (apply funk (list-array pr)))))))))

   (t
    (do ((j 1 (+ j 1)))
        ((> j ndim) t)
        (declare (type fixnum j))
      (fset (fref p ihi j) (fref pr j)))
    (fset (fref y ihi) ypr))) 
   
  (go label1)))
;------------------------------------------------------------------------------

(defun powell (p xi func &key (ftol 1.0d-5) (itmax 200))
 (declare (type (simple-array double-float (*)) p)) 
 (declare (type (simple-array double-float (* *)) xi))
 (declare (type double-float p xi ftol))
 (declare (type fixnum itmax))

 (prog* (
  (n (array-dimension p 0))
  (pt (make-array n :element-type 'double-float :initial-element 0d0))
  (ptt (make-array n :element-type 'double-float :initial-element 0d0))
  (xit (make-array n :element-type 'double-float :initial-element 0d0))
  (iter 0) (fret 0d0)  
  (ibig 0) (t0 0d0) (fp 0d0) (del 0d0) (fptt 0d0)) 

  (declare (type (simple-array double-float (*)) pt)) 
  (declare (type (simple-array double-float (*)) ptt)) 
  (declare (type (simple-array double-float (*)) xit)) 
  (declare (type fixnum n itmax nmax iter ibig))
  (declare (type double-float fret t0 fp del fptt))


  (setf fret (dfloat (apply func (list-array p))) )


  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref pt j) (aref p j))) 

  (setf iter 0) 
label1 
  (setf iter (+ iter 1)) 
  (setf fp fret) 
  (setf ibig 0) 
  (setf del 0d0) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf (aref xit j) (aref xi j i)))

    (setf fptt fret)


    (multiple-value-setq (p xit fret) (linmin p xit func))
    (when 
     (> (abs (- fptt fret)) del)
     (setf del (abs (- fptt fret))) 
     (setf ibig i))) 

  (if (<= (* 2d0 (abs (- fp fret))) (* ftol (+ (abs fp) (abs fret))))
      (return (values p xi iter fret)))
 
  (if (= iter itmax) (error " powell exceeding maximum iterations ")) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref ptt j) (- (* 2 (aref p j)) (aref pt j)))
    (setf (aref xit j) (- (aref p j) (aref pt j)))
    (setf (aref pt j) (aref p j))) 
  (setf fptt (dfloat (apply func (list-array ptt)))) 
 
  (if (>= fptt fp) (go label1)) 
  (setf t0 (- (* (* 2d0 (+ (- fp (* 2d0 fret)) fptt))
                (expt (- (- fp fret) del) 2))
             (* del (expt (- fp fptt) 2)))) 
  (if (>= t0 0d0) (go label1)) 
  (multiple-value-setq (p xit fret)  (linmin p xit func)) 
  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref xi j ibig) (aref xit j))) 

  (go label1)))

;-----------------------------------------------------------------------------


(defun linmin (p xi func &key (tol 1.0d-4))
 (declare (type (simple-array double-float (*)) p)) 
 (declare (type (simple-array double-float (*)) xi)) 
 (declare (type double-float tol))

 (prog* (
  (n (array-dimension p 0))
;  (setf ncom n) 
  (pcom (make-array n :element-type 'double-float :initial-element 0d0))
  (xicom (make-array n :element-type 'double-float :initial-element 0d0))
  (fret 0d0) (ncom 0)
  (ax 0d0) (xx 0d0) (bx 0d0) 
  (f1dim 0d0) (xmin 0d0))
  (declare (type fixnum n ncom))
  (declare (type double-float ax xx bx xx fret xmin))
  (declare (type (simple-array double-float (*)) pcom xicom)) 
  (declare (ignore ncom))

;----
    (setq f1dim #'(lambda (x)
      (let 
   ((xt (make-array n :element-type 'double-float :initial-element 0d0)))
      (do ((j 0 (1+ j))) ((> j (1- n)) t)
       (setf (aref xt j) (+ (aref pcom j) (* x (aref xicom j)))))
      (dfloat (apply func (list-array xt))))))
;----

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref pcom j) (aref p j))
    (setf (aref xicom j) (aref xi j))) 

  (setf ax 0d0) 
  (setf xx 1d0) 
  (multiple-value-setq (ax xx bx) (mnbrak ax xx f1dim)) 
  (multiple-value-setq (fret xmin) (brent ax xx bx f1dim :tol tol)) 
  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref xi j) (* xmin (aref xi j)))
    (setf (aref p j) (+ (aref p j) (aref xi j)))) 
   
  (return (values p xi fret))))

;------------------------------------------------------------------------------
(defun frprmn (p func dfunc 
                   &key (ftol 1.0d-4) (eps 1.0d-10) (itmax 200))
 (declare (type double-float ftol eps))
 (declare (type (simple-array double-float (*)) p)) 
 (declare (type fixnum itmax))

 (prog* (
  (n (array-dimension p 0))
  (g (make-array n :element-type 'double-float :initial-element 0d0))
  (h (make-array n :element-type 'double-float :initial-element 0d0))
  (xi (make-array n :element-type 'double-float :initial-element 0d0))
  (iter 0) (ffret 0d0) 
  (fp 0d0) (gg 0d0) (dgg 0d0) (gam 0d0))

  (declare (type fixnum iter n))
  (declare (type double-float ffret fp dgg gam))
  (declare (type (simple-array double-float (*)) g)) 
  (declare (type (simple-array double-float (*)) h)) 
  (declare (type (simple-array double-float (*)) xi)) 


  (setf fp (dfloat (apply func (list-array p)))) 

  (fill-array xi 
        (mapcar #'(lambda (h) (dfloat (apply h (list-array p)))) dfunc))

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref g j) (- (aref xi j)))
    (setf (aref h j) (aref g j))
    (setf (aref xi j) (aref h j)))
 
  (do ((its 1 (1+ its)))
      ((> its itmax) t)
      (declare (type fixnum its))
    (setf iter its)

    (multiple-value-setq (p xi ffret) (dlinmin p xi func dfunc))

    (if (<= (* 2d0 (abs (- ffret fp))) (* ftol (+ (abs ffret) (abs fp) eps)))
         (go end))

    (setf fp (dfloat (apply func (list-array p))) )
    (fill-array xi 
     (mapcar #'(lambda (h) (dfloat (apply h (list-array p)))) dfunc))
    (setf gg 0d0)
    (setf dgg 0d0)
    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf gg (+ gg (expt (aref g j) 2)))
;     (setf dgg (+ dgg (expt (aref xi j) 2)))
      (setf dgg (+ dgg (* (+ (aref xi j) (aref g j)) (aref xi j)))))

    (if (= gg 0d0) (go end))
    (setf gam (/ dgg gg))

    (do ((j 0 (+ j 1)))
        ((> j (1- n)) t)
        (declare (type fixnum j))
      (setf (aref g j) (- (aref xi j)))
      (setf (aref h j) (+ (aref g j) (* gam (aref h j))))
      (setf (aref xi j) (aref h j)))) 

  (error " frpr maximum iterations exceeded ")
end 
(return (values p iter ffret))))

;------------------------------------------------------------------------------

(defun dlinmin (p xi func dfunc &key (tol 1.0d-4))
 (declare (type (simple-array double-float (*)) p)) 
 (declare (type (simple-array double-float (*)) xi)) 
 (declare (type double-float tol))

 (prog* (
  (n (array-dimension p 0))
  (fret 0d0) (ncom n)
  (pcom (make-array n :element-type 'double-float :initial-element 0d0))
  (xicom (make-array n :element-type 'double-float :initial-element 0d0))
  (f1dim 0d0) (df1dim 0d0) (ax 0d0) (xx 0d0) (bx 0d0)
  (xmin 0d0))

  (declare (type fixnum n ncom))
  (declare (type double-float ax xx bx fret xmin))
  (declare (type (simple-array double-float (*)) pcom xicom)) 
  (declare (ignore ncom))

    (setq f1dim #'(lambda (x)
      (let 
   ((xt (make-array n :element-type 'double-float :initial-element 0d0)))
      (do ((j 0 (1+ j))) ((> j (1- n)) t)
       (setf (aref xt j) (+ (aref pcom j) (* x (aref xicom j)))))
      (dfloat (apply func (list-array xt))))))

    (setq df1dim #'(lambda (x)
      (let 
   ((xt (make-array n :element-type 'double-float :initial-element 0d0))
    (df (make-array n :element-type 'double-float :initial-element 0d0))
    (df1dim 0d0) xt-list)
      (do ((j 0 (1+ j))) ((> j (1- n)) t)
       (setf (aref xt j) (+ (aref pcom j) (* x (aref xicom j)))))
      (setq xt-list (list-array xt))
      (fill-array df (mapcar 
                       #'(lambda (h) (dfloat (apply h xt-list))) dfunc))
      (do ((j 0 (1+ j))) ((> j (1- n)) t)
       (setf df1dim (+ df1dim (* (aref df j) (aref xicom j)))))
      df1dim)))


  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref pcom j) (aref p j))
    (setf (aref xicom j) (aref xi j))) 

  (setf ax 0d0) 
  (setf xx 1d0) 

  (multiple-value-setq (ax xx bx) (mnbrak ax xx f1dim)) 

  (multiple-value-setq (fret xmin) (dbrent ax xx bx f1dim df1dim :tol tol)) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref xi j) (* xmin (aref xi j)))
    (setf (aref p j) (+ (aref p j) (aref xi j)))) 
   
  (return (values p xi fret))))

;------------------------------------------------------------------------------

(defun dfpmin (p func dfunc 
                 &key (ftol 1.0d-5) (itmax 200) (eps 1.0d-20))
 (declare (type (simple-array double-float (*)) p))
 (declare (type double-float ftol eps))
 (declare (type fixnum nmax itmax))
 
 (prog* (
  (n (array-dimension p 0))
  (hessin (make-array (list n n) :element-type 'double-float
                 :initial-element 0d0)) 
  (xi (make-array n :element-type 'double-float
                 :initial-element 0d0)) 
  (g (make-array n :element-type 'double-float
                 :initial-element 0d0)) 
  (dg (make-array n :element-type 'double-float
                 :initial-element 0d0)) 
  (hdg (make-array n :element-type 'double-float
                 :initial-element 0d0))  
  (f 0d0) (fret 0d0) 
  (fp 0d0) (iter 0) (fac 0d0) (fae 0d0) (fad 0d0))

  (declare (type fixnum itmax n))
  (declare (type (simple-array double-float (* *)) hessin)) 
  (declare (type (simple-array double-float (*)) xi)) 
  (declare (type (simple-array double-float (*)) g)) 
  (declare (type (simple-array double-float (*)) dg)) 
  (declare (type (simple-array double-float (*)) hdg))
  (declare (type double-float fret fp fax fae fad))
  (declare (ignore f))



  (setf fp (dfloat (apply func (list-array p))))
  (fill-array g 
     (mapcar #'(lambda (h) (dfloat (apply h (list-array p)))) dfunc))
  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref hessin i i) 1d0)
    (setf (aref xi i) (- (aref g i)))) 

  (do ((its 1 (+ its 1)))
      ((> its itmax) t)
      (declare (type fixnum its))
    (setf iter its)

    (multiple-value-setq (p xi fret) (linmin p xi func))

    (if (<= (* 2d0 (abs (- fret fp))) (* ftol (+ (abs fret) (abs fp) eps)))
        (go end))
    (setf fp fret)

    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
      (declare (type fixnum i))
      (setf (aref dg i) (aref g i)))

  (setf fp (apply func (list-array p))) 
  (fill-array g 
          (mapcar #'(lambda (h) (dfloat (apply h (list-array p)))) dfunc))

    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
      (declare (type fixnum i))
      (setf (aref dg i) (+ (aref g i) (- (aref dg i)))))

    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
      (declare (type fixnum i))
      (setf (aref hdg i) 0d0)
      (do ((j 0 (+ j 1)))
          ((> j (1- n)) t)
          (declare (type fixnum j))
        (setf (aref hdg i) 
              (+ (aref hdg i) (* (aref hessin i j) (aref dg j))))))

    (setf fac 0d0)
    (setf fae 0d0)
    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
        (declare (type fixnum i))
      (setf fac (+ fac (* (aref dg i) (aref xi i))))
      (setf fae (+ fae (* (aref dg i) (aref hdg i)))))

    (setf fac (/ 1d0 fac))
    (setf fad (/ 1d0 fae))
    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
        (declare (type fixnum i))
      (setf (aref dg i) (+ (* fac (aref xi i)) (* (- fad) (aref hdg i)))))

    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
      (declare (type fixnum i))
      (do ((j 0 (+ j 1)))
          ((> j (1- n)) t)
          (declare (type fixnum j))
        (setf (aref hessin i j) (+ (+ (+ (aref hessin i j)
                                         (* (* fac (aref xi i)) (aref xi j)))
                                      (* (* (- fad) (aref hdg i))
                                         (aref hdg j)))
                                   (* (* fae (aref dg i)) (aref dg j))))))

    (do ((i 0 (+ i 1)))
        ((> i (1- n)) t)
        (declare (type fixnum i))
      (setf (aref xi i) 0d0)
      (do ((j 0 (+ j 1)))
          ((> j (1- n)) t)
          (declare (type fixnum j))
        (setf (aref xi i) (+ (aref xi i)
                             (* (- (aref hessin i j)) (aref g j))))))) 

  (error "too many iterations in dfpmin")
end
(return (values p iter fret))))
;------------------------------------------------------------------------------

(defun simplex-tableau (objective ub-constraints lb-constraints eq-constraints
                                 &key (simplex-eps 1.0d-6) (simplex-nmax 100))
 (declare (type (simple-array double-float *) objective)
          (type (simple-array double-float (* *)) ub-constraints)
          (type (simple-array double-float (* *)) lb-constraints)
          (type (simple-array double-float (* *)) eq-constraints))
 (declare (type double-float simplex-eps))
 (declare (type fixnum simplex-nmax))
 (declare (special simplex-eps simplex-nmax))

 (prog ((n 0) (m 0) (np 0) (mp 0) (m1 0) (m2 0) (m3 0) 
        (a nil) (b nil) (dims nil) (izrov nil) (iposv nil) 
        (sign 0d0) (icase 0))
  (declare (type fixnum n m m1 m2 m3 icase)
           (type cons dims))
           ;(type (simple-array double-float (* *)) a)
           ;(type (simple-array double-float (*)) b))
  (declare (type double-float sign))
  (setq n (array-dimension objective 0))

(if (arrayp ub-constraints)
    (setq dims (array-dimensions ub-constraints)
          m1 (first dims))
    (setq m1 0))
(if (arrayp lb-constraints)
    (setq dims (array-dimensions lb-constraints)
          m2 (first dims))
    (setq m2 0))
(if (arrayp eq-constraints)
    (setq dims (array-dimensions eq-constraints)
          m3 (first dims))
    (setq m3 0))
  (setq m (+ m1 m2 m3))
(if (= 0 m) (error "no constraints"))

  (setq a (make-array (list (+ m 2) (1+ n)) 
                    :element-type 'double-float
                    :initial-element 0d0))

  (setq b (make-array (+ m 1) 
                    :element-type 'double-float
                    :initial-element 0d0))

; load a:
; load the objective
  (do ((j 1 (1+ j))) ((> j n) 0)
    (fset (fref a 1 (1+ j)) (fref objective j)))
; load the upper bound constraints
(if (arrayp ub-constraints)
  (do ((i 1 (1+ i))) ((> i m1) 0)
    (do ((j 1 (1+ j))) ((> j (1+ n)) 0)
        (setq sign (if (= j 1) 1d0 -1d0))
        (fset (fref a (1+ i) j) (* sign (fref ub-constraints i j))))))
; load the lower bound constraints
(if (arrayp lb-constraints)
  (do ((i 1 (1+ i))) ((> i m2) 0)
    (do ((j 1 (1+ j))) ((> j (1+ n)) 0)
        (setq sign (if (= j 1) 1d0 -1d0))
        (fset (fref a (+ i m1 1) j) (* sign (fref lb-constraints i j))))))

; load the equality constraints
(if (arrayp eq-constraints)
  (do ((i 1 (1+ i))) ((> i m3) 0)
    (do ((j 1 (1+ j))) ((> j (1+ n)) 0)
        (setq sign (if (= j 1) 1d0 -1d0))
        (fset (fref a (+ 1 m1 m2 i) j) (* sign (fref eq-constraints  i j))))))

; test:
(setq mp (+ m 2) np (1+ n))

 (multiple-value-setq (a izrov iposv icase) 
                       (simplx a m n mp np m1 m2 m3))

; load the solution
  (do ((j 0 (1+ j))) ((> j m) 0)
     (setf (aref b j) (aref a j 0)))
(return (values b izrov iposv icase))
))

;-------------------------------------------------------------------------------
;(defvar simplex-eps 1.0d-6)
;(defvar simplex-nmax 100)

; simp1 determines the maximum of those elements whose index in contained in
; the array ll, eith with or without taking absolute value, as flagged by iabf.

(defun simp1 (a mm ll nll iabf)
 (declare (type (simple-array double-float (* *)) a)
          (type (simple-array fixnum (*)) ll)
          (type fixnum mm nll iabf))

 (prog ((kp 0) (bmax 0d0) (test 0d0))
  (declare (type double-float bmax test) (type fixnum kp))

  (setq kp (aref ll 0)
        bmax (aref a mm kp))
  (if (< nll 2) (go end))
  (do ((k 2 (1+ k)))
      ((> k nll))
      (declare (type fixnum k))
      (if (= iabf 0)
          (setq test (- (aref a mm (aref ll (1- k))) bmax))
          (setq test (- (abs (aref a mm (aref ll (1- k)))) (abs bmax))))
      (when (> test 0d0)
            (setq bmax (aref a mm (aref ll (1- k)))
                  kp (aref ll (1- k)))))
end
(return (values kp bmax))
))

;-----------------------------------------------------------------------------
; simp2 locates a pivot elemement, taking degeneracy into account
(defun simp2 (a l2 nl2 kp)
 (declare (type (simple-array double-float (* *)) a)
          (type (simple-array fixnum (*)) l2)
          (type fixnum nl2 kp))

 (prog ((ip 0) (i0 0) (ii 0) (q1 0d0) (q 0d0) (qp 0d0) (q0 0d0) (n 0))
  (declare (type fixnum ip i0 ii n))
  (declare (type double-float q1 q qp q0 simplex-eps))
  (declare (special simplex-eps))

  (setq ip 0)
;  (if (< nl2 1) (go end))
  (do ((i 1 (1+ i))) ((> i nl2))
      (setq i0 i)
      (if (< (aref a (aref l2 (1- i)) kp) (- simplex-eps)) (go tag2)))

; no possible pivots so return with message:
  (princ " no pivots in simplex ") (go end)

tag2
  (setq q1 (- (/ (aref a (aref l2 (1- i0)) 0) (aref a (aref l2 (1- i0)) kp))))
  (setq ip (aref l2 (1- i0)))
;  (if (> (1+ i0) nl2) (go end))
  
  (do ((i (1+ i0) (1+ i))) ((> i nl2))
      (setq ii (aref l2 (1- i)))
      (when (< (aref a ii kp) (- simplex-eps))
            (setq q (- (/ (aref a ii 0) (aref a ii kp))))
            (if (< q q1)
                (setq ip ii q1 q)
          
                (when (= q q1)  ; we have a degeneracy
                  (tagbody
                      (do ((k 1 (1+ k))) ((> k n))
                          (setq qp (- (/ (aref a ip k) (aref a ip kp))))
                          (setq q0 (- (/ (aref a ii k) (aref a ii kp))))
                          (if (neq q0 qp) (go tag6))) ; jump out of the loop
tag6)
                      (if (< q0 qp) (setq ip ii))))))
end
  (return (values ip kp q1))))

;------------------------------------------------------------------------------
; matrix operations to exchange a left-hand and right-hand variable
(defun simp3 (a i1 k1 ip kp)
 (declare (type (simple-array double-float (* *)) a)
          (type fixnum i1 k1 ip kp))

 (prog ((piv 0d0))
   (declare (type double-float piv))

   (setq piv (/ 1d0 (aref a ip kp)))
;   (if (>= i1 0)
       (do ((ii 1 (1+ ii))) ((> ii (1+ i1)) 0)
          (when (neq (1- ii) ip)
             (setf (aref a (1- ii) kp) (* (aref a (1- ii) kp) piv))
             (do ((kk 1 (1+ kk))) ((> kk (1+ k1)) 0)
               (if (neq (1- kk) kp)
                 (setf (aref a (1- ii) (1- kk)) (- (aref a  (1- ii) (1- kk)) 
                                      (* (aref a ip (1- kk))
                                         (aref a (1- ii) kp))))))))
;)

   (do ((kk 1 (1+ kk))) ((> kk (1+ k1)) 0)
         (if (neq (1- kk) kp)
             (setf (aref a ip (1- kk)) (- (* (aref a ip (1- kk)) piv)))))
   (setf (aref a ip kp) piv)
   (return a)))
;-----------------------------------------------------------------------------

;Input parameters: a mp m1 m2 m3
; (array a mp np)
;Output parameters: a izrov iposv icase 

(defun simplx (a m n mp np m1 m2 m3)
 (declare (ignore mp np))

 (prog* (
        (izrov (make-array n :element-type 'fixnum :initial-element 0))
        (iposv (make-array m :element-type 'fixnum :initial-element 0))
        (l1 (make-array m :element-type 'fixnum :initial-element 0))
        (l2 (make-array m :element-type 'fixnum :initial-element 0))
        (l3 (make-array m :element-type 'fixnum :initial-element 0))
        (icase 0) 
        (nl1 0) (nl2 0) (ir 0) (q1 0d0) (bmax 0d0) (kh 0)
        (kp 0) (m12 0) (ip 0) (k0 0) (is 0))

   (declare (special simplex-eps))
   (declare (type double-float simplex-eps bmax q1))
   (declare (type fixnum icase nl2 ir kp m12 ip k0 is kh))
   (declare (type (simple-array fixnum (*)) izrov iposv l1 l2 l3))



;initially make all variables right handed
  (setq nl1 n)

;initialize index lists
 (do ((k 1 (1+ k))) ((> k n) 0)
          (setf (aref l1 (1- k)) k)
          (setf (aref izrov (1- k)) k))


;make all artifical variables left-handed
  (setq nl2 m)
  (do ((i 1 (1+ i))) ((> i m) 0)
           (if (< (aref a i 0) 0d0) (error "all bi must be non-negative"))
           (setf (aref l2 (1- i)) i)
           (setf (aref iposv (1- i)) (+ n i)))

;initialize
  (do ((i 1 (1+ i))) ((> i m2) 0)
           (setf (aref l3 (1- i)) 1))
  (setq ir 0) ; means we are in phase two - have a feasible starting solution.
  
;go to tag30 if origin is a feasible solution
  (if (= 0 (+ m2 m3)) (go tag30))

; flag means we must start out in phase one
 (setq ir 1)

;compute the auxiliary objective function
 (do ((k 1 (1+ k))) ((> k (1+ n)) 0)
          (setq q1 0d0)
          (do ((i (1+ m1) (1+ i))) ((> i m) 1)
              (setq q1 (+ q1 (aref a i (1- k)))))
          (setf (aref a (1+ m) (1- k)) (- q1)))

;find max. coeff of the auxilliary objective function
tag10
 (multiple-value-setq (kp bmax)  (simp1 a (1+ m) l1 nl1 0))

 (cond ((and (<= bmax simplex-eps) (< (aref a (1+ m) 0) (- simplex-eps)))
        (setq icase -1)
        (go end)) ; no feasible solution exists

; Auxilliary objective function is zero and cannot be improved. This
; signals sthat we have a feasible starting vector. Clean out the 
; artificial variables by go 1 and move on to phase two by go 30

       ((and (<= bmax simplex-eps) (<= (aref a (+ m 1) 0) simplex-eps))
        
        (setq m12 (+ m1 m2 1))
        (when (<= m12 m)
              (do ((ip m12 (1+ ip))) ((> ip m) 0)
                (when (= (aref iposv (1- ip)) (+ ip n))
                      (multiple-value-setq (kp bmax) 
                                         (simp1 a ip l1 nl1 1))
                      (if (> bmax 0d0) (go tag1)))))

; phase two starts
       
       (setq ir 0)
       (setq m12 (1- m12))
       (if (> (1+ m1) m12) (go tag30))
       (do ((i (1+ m1) (1+ i))) ((> i m12) 0)
           (if (= (aref l3 (- i m1 1)) 1)
           (do ((k 1 (1+ k))) ((> k (1+ n)) 0)
               (setf (aref a i (1- k)) (- (aref a i (1- k)))))))
      (go tag30))) ; endif

; locate a pivot element

(multiple-value-setq (ip kp q1) (simp2 a l2 nl2 kp))

(when (= ip 0)
      (setq icase -1)
      (go end))

tag1
;exchange left and right hand varibles (phase one) then update lists

(setq a (simp3 a (1+ m) n ip kp))

;update lists
(if (>= (aref iposv (1- ip)) (+ n m1 m2 1))
     (let ()
      (tagbody
       (do ((k 1 (1+ k))) ((> k nl1) 0) 
           (setq k0 k)
           (if (= (aref l1 (1- k)) kp) (go tag2)))
tag2 ); not nice !
       (setq nl1 (1- nl1))
       (do ((is k0 (1+ is))) ((> is nl1) 0)
           (setf (aref l1 (1- is)) (aref l1 is))))
     (let ()
      (if (< (aref iposv (1- ip)) (+ n m1 1)) (go tag20))
      (setq kh (- (aref iposv (1- ip)) (+ m1 n)))
      (if (= (aref l3 (1- kh)) 0) (go tag20))
      (setf (aref l3 (1- kh)) 0)))

(setf (aref a (1+ m) kp) (1+ (aref a (1+ m) kp)))

(do ((i 1 (1+ i))) ((> i (+ m 2)) 0)
         (setf (aref a (1- i) kp) (- (aref a (1- i) kp))))

tag20

(setq is (aref izrov (1- kp)))
(setf (aref izrov (1- kp)) (aref iposv (1- ip)))
(setf (aref iposv (1- ip)) is)

; if still in phase one go back to 10
(if (neq ir 0) (go tag10))

;End of phase one code for finding an initial feasible solution
;Now in phase two, optimize it

tag30
;test the z-row for doneness
(multiple-value-setq (kp bmax) (simp1 a 0 l1 nl1 0))

;done, solution found, return with good news
(when (<= bmax 0d0) (setq icase 0) (go end))

;locate a pivot element (phase two)
(multiple-value-setq (ip kp q1) (simp2 a l2 nl2 kp))

; objective function is unbounded - report and return
(when (= ip 0) (setq icase 1) (go end))

; exchange left and right hand variables (phase two)
; and return for another iteration
(setq a (simp3 a m n ip kp))
(go tag20)
end
(return (values a izrov iposv icase ))
))
;-----------------------------------------------------------------------------
(fproclaim '(special $verbose $anneal_jdum $anneal_maxcit))
   
(defun anneal (x y iorder)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array fixnum (*)) iorder)) 

 (prog 
        ((ans nil) (ncity 0) (nlimit 0) (nover 0) 
        (tfactr 0.9d0) (path 0d0) (t0 0.5d0) 
        (i1 0) (i2 0) (idum 0) (nsucc 0)  
        (idec 0) (nn 0) (de 0d0)
        (n (make-array 6 :element-type 'fixnum :initial-element 0)))
  (declare (type symbol ans))
  (declare (type fixnum ncity nlimit nover))
  (declare (type double-float tfactr path t0))
  (declare (type (simple-array fixnum (6)) n))
  (declare (special irbit1 ran3))


  (setq ncity (array-dimension iorder 0)) 

  (setf nover (* 100 ncity)) 
  (setf nlimit (* 10 ncity)) 
  (do ((i 1 (+ i 1)))
      ((> i (+ ncity (- 1))) t)
    (setf i1 (fref iorder i))
    (setf i2 (fref iorder (+ i 1)))
    (setf path (+ path
                  (alen (fref x i1) (fref x i2) (fref y i1) (fref y i2))))) 
  (setf i1 (fref iorder ncity)) 
  (setf i2 (fref iorder 1)) 
  (setf path (+ path
                (alen (fref x i1) (fref x i2) (fref y i1) (fref y i2)))) 
  (setf idum -1) 
 ; (setf iseed 111) 
  (do ((j 1 (+ j 1)))
      ((> j 100) t)
    (setf nsucc 0)
    (do ((k 1 (+ k 1)))
        ((> k nover) t)
        (declare (type fixnum k))
      label12
      (when $verbose (princ ".") (force-output))
      (fset (fref n 1) (+ 1 (floor (* ncity (funcall ran3 idum)))))
      (fset (fref n 2) (+ 1 (floor (* (+ ncity (- 1)) (funcall ran3 idum)))))
      (if (>= (fref n 2) (fref n 1)) (fset (fref n 2) (+ (fref n 2) 1)))
      (setf idec (funcall irbit1))
      (setf nn (+ 1
                  (rem
                        (+ (+ (+ (fref n 1) (- (fref n 2))) ncity) (- 1))
                        ncity)))
      (if (< nn 3) (go label12))
      (cond
       ((= idec 0) 
        (fset (fref n 3) (+ (+ (fref n 2)
                               (floor
                                     (* (abs (+ nn (- 2)))
                                        (funcall ran3 idum))))
                            1))

        (fset (fref n 3) (1+ (mod (1- (fref n 3)) ncity)))
        (setq de (trncst x y iorder n))
        (setq ans (metrop de t0 :jdum $anneal_jdum))
        (when 
         ans 
         (setf nsucc (+ nsucc 1))
         (setf path (+ path de)) 
         (setq iorder (trnspt iorder n :maxcit $anneal_maxcit))))
       (t 
        (multiple-value-setq (n de) (revcst x y iorder n))
        (setq ans (metrop de t0 :jdum $anneal_jdum))
        (when 
          ans  
          (setf nsucc (+ nsucc 1))
          (setf path (+ path de)) 
          (setq iorder (revers iorder n)))))
      (if (>= nsucc nlimit) (go label14)))
    label14
    (format t " t = ~a, path length = ~a" t0 path)
    (format t " successful moves = ~a" nsucc)

    (setf t0 (* t0 tfactr))
   (if (= nsucc 0) (go end))) 
end
  (return iorder)))
;------------------------------------------------------------------------------


(defun alen (x y z w) (sqrt (+ (expt (- y x) 2) (expt (- w z) 2))))

(defun revcst (x y iorder n)
 (declare (type (simple-array double-float (*)) x y))
 (declare (type (simple-array fixnum (*)) iorder n))

 (prog ((ncity 0) (ii 0) (de 0d0)
        (xx (make-array 4 :element-type 'double-float :initial-element 0d0))
        (yy (make-array 4 :element-type 'double-float :initial-element 0d0)))
  (declare (type (simple-array double-float (4)) xx yy))
  (declare (type fixnum ncity ii))
  (declare (type double-float de))

  (setq ncity (array-dimension x 0))

  (fset (fref n 3) (+ 1 (rem (+ (+ (fref n 1) ncity) (- 2)) ncity)))
  (fset (fref n 4) (+ 1 (rem (fref n 2) ncity)))
  (do ((j 1 (+ j 1)))
      ((> j 4) t)
      (declare (type fixnum j))
    (setf ii (fref iorder (fref n j)))
    (fset (fref xx j) (fref x ii))
    (fset (fref yy j) (fref y ii)))
  (setf de
        (+
         (+
          (+ (- (alen  (fref xx 1) (fref xx 3) (fref yy 1) (fref yy 3)))
             (- (alen  (fref xx 2) (fref xx 4) (fref yy 2) (fref yy 4))))
          (alen  (fref xx 1) (fref xx 4) (fref yy 1) (fref yy 4)))
         (alen  (fref xx 2) (fref xx 3) (fref yy 2) (fref yy 3))))
  (return (values n de))))

;----------------------------------------------------------------------------

(defun revers (iorder n)
 (declare (type (simple-array fixnum (*)) iorder n))

 (prog ((ncity 0) (ii 0) (de 0d0) (nn 0) (k 0) (l 0) (itmp 0))
  (declare (type fixnum ncity ii k l itmp))
  (declare (type double-float de))
  (declare (ignore de ii))

  (setq ncity (array-dimension iorder 0))
  (setf nn
        (/ (+ 1 (mod (+ (+ (fref n 2) (- (fref n 1))) ncity) ncity)) 2))
  (do ((j 1 (+ j 1)))
      ((> j nn)  t)
      (declare (type fixnum j))
    (setf k (+ 1 (mod (+ (+ (fref n 1) j) (- 2)) ncity)))
    (setf l (+ 1 (mod (+ (+ (fref n 2) (- j)) ncity) ncity)))
    (setf itmp (fref iorder k))
    (fset (fref iorder k) (fref iorder l))
    (fset (fref iorder l) itmp))
  (return iorder)))
;----------------------------------------------------------------------------

(defun trncst (x y iorder n)
 (declare (type (simple-array double-float (*)) x y))
 (declare (type (simple-array fixnum (*)) iorder n))

 (prog ((ncity 0) 
  (xx (make-array 6 :element-type 'double-float :initial-element 0d0))
  (yy (make-array 6 :element-type 'double-float :initial-element 0d0))
  (ii 0) (de 0d0))

  (declare (type (simple-array double-float (*)) xx yy))
  (declare (type fixnum ncity ii))
  (declare (type double-float de))

  (setq ncity (array-dimension x 0))
  

  (fset (fref n 4) (+ 1 (mod (fref n 3) ncity)))
  (fset (fref n 5) (+ 1 (mod (+ (+ (fref n 1) ncity) (- 2)) ncity)))
  (fset (fref n 6) (+ 1 (mod (fref n 2) ncity)))
  (do ((j 1 (+ j 1)))
      ((> j 6) t)
      (declare (type fixnum j))
    (setf ii (fref iorder (fref n j)))
    (fset (fref xx j) (fref x ii))
    (fset (fref yy j) (fref y ii)))
  (setf de
        (+
         (+
          (+
           (+
            (+
             (- (alen  (fref xx 2) (fref xx 6) (fref yy 2) (fref yy 6)))
             (- (alen  (fref xx 1) (fref xx 5) (fref yy 1) (fref yy 5))))
            (- (alen  (fref xx 3) (fref xx 4) (fref yy 3) (fref yy 4))))
           (alen  (fref xx 1) (fref xx 3) (fref yy 1) (fref yy 3)))
          (alen  (fref xx 2) (fref xx 4) (fref yy 2) (fref yy 4)))
         (alen  (fref xx 5) (fref xx 6) (fref yy 5) (fref yy 6))))
  (return (the double-float de))))

;------------------------------------------------------------------------------


(defun trnspt (iorder n &key (maxcit 1000))
 (declare (type (simple-array fixnum (*)) iorder))
 (declare (type (simple-array fixnum (6)) n))
 (declare (type fixnum maxcit))
 (declare (ignore maxcit))


 (prog* ((ncity (array-dimension iorder 0)) 
        (jorder (make-array ncity :element-type 'fixnum :initial-element 0)) 
        (m1 0) (m2 0) (m3 0) (nn 0) (jj 0))

  (declare (type fixnum ncity m1 m2 m3 nn jj))
  (declare (type (simple-array fixnum (*)) jorder)) 

  (setf m1 (+ 1 (mod (+ (+ (fref n 2) (- (fref n 1))) ncity) ncity)))
  (setf m2 (+ 1 (mod (+ (+ (fref n 5) (- (fref n 4))) ncity) ncity)))
  (setf m3 (+ 1 (mod (+ (+ (fref n 3) (- (fref n 6))) ncity) ncity)))
  (setf nn 1)
  (do ((j 1 (+ j 1)))
      ((> j m1) t)
      (declare (type fixnum j))
    (setf jj (+ 1 (mod (+ (+ j (fref n 1)) (- 2)) ncity)))
    (fset (fref jorder nn) (fref iorder jj))
    (setf nn (+ nn 1)))
  (when (> m2 0)
   (do ((j 1 (+ j 1)))
       ((> j m2) t)
       (declare (type fixnum j))
     (setf jj (+ 1 (mod (+ (+ j (fref n 4)) (- 2)) ncity)))
     (fset (fref jorder nn) (fref iorder jj))
     (setf nn (+ nn 1))))
  (when (> m3 0)
   (do ((j 1 (+ j 1)))
       ((> j m3) t)
       (declare (type fixnum j))
     (setf jj (+ 1 (mod (+ (+ j (fref n 6)) (- 2)) ncity)))
     (fset (fref jorder nn) (fref iorder jj))
     (setf nn (+ nn 1))))
  (do ((j 1 (+ j 1)))
      ((> j ncity) t)
      (declare (type fixnum j))
    (fset (fref iorder j) (fref jorder j)))
  (return iorder)))
;----------------------------------------------------------------------------

(defun metrop (de t0 &key (jdum 1))
 (declare (type double-float t0 de))
 (declare (type fixnum jdum))

  (prog 
   ((ans nil))
   (declare (type symbol ans))
   (declare (special ran3))

   (setq ans (or (<= de 0d0) 
                 (< (funcall ran3 jdum) (exp (/ (- de) t0)))))

  (return (the symbol ans))))

;------------------------------------------------------------------------------
; end of nr10.l

