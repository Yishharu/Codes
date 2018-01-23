; nr15.l
; Integration of ordinary differential equations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	rk4: integrate one step of ode's by 4th order Runge-Kutta
;	rkdumb: integrate ode's by 4th order Runge-Kutta
;	rkqc: integrate one step of ode's with accuracy monitoring
;	odeint: integrate ode's with accuracy monitoring - rk or bs
;	mmid: integrate ode's with the modified midpoint method
;	bsstep: integrate ode's Bulirsch-Stoer method
;	rzextr: rational function extrapolation, for bsstep
;	pzextr: polynomial extrapolation, for bsstep
;------------------------------------------------------------------------------


(defun rk4 (y dydx x h derivs &key (nmax 10)) 
 (declare (type fixnum nmax))
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) dydx)) 
 (declare (type double-float x h))
 (declare (ignore nmax))

 (prog* (
  (n (array-dimension y 0))
  (yout (make-array n :element-type 'double-float :initial-element 0d0))
  (yt (make-array n :element-type 'double-float :initial-element 0d0))
  (dyt (make-array n :element-type 'double-float :initial-element 0d0))
  (dym (make-array n :element-type 'double-float :initial-element 0d0))
  (hh 0d0) (h6 0d0) (xh 0d0))

  (declare (type (simple-array double-float (*)) yout)) 
  (declare (type (simple-array double-float (*)) yt)) 
  (declare (type (simple-array double-float (*)) dyt)) 
  (declare (type (simple-array double-float (*)) dym)) 
  (declare (type fixnum n))


  (setf hh (* h 0.5d0)) 
  (setf h6 (/ h 6d0)) 
  (setf xh (+ x hh)) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref yt i) (+ (aref y i) (* hh (aref dydx i))))) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref dyt i)
          (dfloat (apply (nth i derivs) (cons xh (list-array yt)))))) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref yt i) (+ (aref y i) (* hh (aref dyt i))))) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref dym i) 
          (dfloat (apply (nth i derivs) (cons xh (list-array yt)))))) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref yt i) (+ (aref y i) (* h (aref dym i))))
    (setf (aref dym i) (+ (aref dyt i) (aref dym i))))
 
  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref dyt i) 
          (dfloat (apply (nth i derivs) (cons (+ x h) (list-array yt)))))) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref yout i) (+ (aref y i)
                           (* h6
                              (+ (+ (aref dydx i) (aref dyt i))
                                 (* 2d0 (aref dym i))))))) 
   
  (return yout)))

;-----------------------------------------------------------------------------

(defun rkdumb (vstart x1 x2 nstep derivs &key (nmax 10) (nstpmx 200)) 
 (declare (type (simple-array double-float (*)) vstart)) 
 (declare (type fixnum nstep nmax nstpmx))
 (declare (type double-float x1 x2))
 (declare (ignore nmax nstpmx))

 (prog* (
  (nvar (array-dimension vstart 0))
  (v (make-array nvar :element-type 'double-float :initial-element 0d0))
  (dv (make-array nvar :element-type 'double-float :initial-element 0d0))
  (xx (make-array (1+ nstep) :element-type 'double-float :initial-element 0d0))
  (y 
       (make-array (list nvar (1+ nstep)) 
                   :element-type 'double-float :initial-element 0d0))
  (x 0d0) (h 0d0))

  (declare (type fixnum nvar))
  (declare (type double-float x h))
  (declare (type (simple-array double-float (*)) v)) 
  (declare (type (simple-array double-float (*)) dv)) 
  (declare (type (simple-array double-float (*)) xx)) 
  (declare (type (simple-array double-float (* *)) y)) 


  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref v i) (aref vstart i))
    (setf (aref y i 0) (aref v i))) 

  (setf (aref xx 0) x1) 
  (setf x x1) 
  (setf h (/ (+ x2 (- x1)) nstep))
 
  (do ((k 0 (+ k 1)))
      ((> k (1- nstep)) t)
      (declare (type fixnum k))
    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
     (setf (aref dv i) 
            (dfloat (apply (nth i derivs) (cons x (list-array v))))))

    (setq v (rk4 v dv x h derivs))
    (if (= (+ x h) x) (error " stepsize not significant in rkdumb "))
    (setf x (+ x h))
    (setf (aref xx (1+ k)) x)
    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref y i (1+ k)) (aref v i)))) 
   
  (return (values xx y))))

;-----------------------------------------------------------------------------
(defun rkqc (y dydx x htry eps yscal derivs &key 
        (nmax 10)
        (fcor 0.066667d0)
        (one 1d0)
        (safety 0.9d0)
        (errcon 6.0d-4)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) dydx)) 
 (declare (type (simple-array double-float (*)) yscal))
 (declare (type fixnum nmax))
 (declare (type double-float fcor one safety errcon))
 (declare (ignore nmax))

 (prog* (
  (n (array-dimension y 0))
  (ytemp 
   (make-array n :element-type 'double-float :initial-element 0d0))
  (ysav 
   (make-array n :element-type 'double-float :initial-element 0d0))
  (dysav 
   (make-array n :element-type 'double-float :initial-element 0d0))
  (hdid 0d0) (hnext 0d0)
  (errmax 0d0) (pgrow 0d0) (pshrnk 0d0) (xsav 0d0)
  (hh 0d0) (h 0d0)) 

  (declare (type (simple-array double-float (*)) ytemp)) 
  (declare (type (simple-array double-float (*)) ysav)) 
  (declare (type (simple-array double-float (*)) dysav)) 
  (declare (type double-float errmax pgrow pshrnk xsav hh h hdid))


  (setf pgrow -0.2d0) 
  (setf pshrnk -0.25d0) 
  (setf xsav x) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref ysav i) (aref y i))
    (setf (aref dysav i) (aref dydx i))) 

  (setf h htry) 
label1 
  (setf hh (* 0.5d0 h)) 
  (setq ytemp (rk4 ysav dysav xsav hh derivs)) 
  (setf x (+ xsav hh)) 
  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
   (setf (aref dydx i) 
        (dfloat (apply (nth i derivs) (cons x (list-array ytemp)))))) 

  (setq y (rk4 ytemp dydx x hh derivs)) 
  (setf x (+ xsav h)) 
  (if (= x xsav) (error " stepsize not significant in rkqc ")) 
  (setq ytemp (rk4 ysav dysav xsav h derivs)) 
  (setf errmax 0d0) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref ytemp i) (+ (aref y i) (- (aref ytemp i))))
    (setf errmax (max errmax (abs (/ (aref ytemp i) (aref yscal i)))))) 

  (setf errmax (/ errmax eps)) 

  (cond 
   ((> errmax one)
    (setf h (* (* safety h) (expt errmax pshrnk))) 
    (go label1))
   (t
    (setf hdid h)
    (if (> errmax errcon)
     (setf hnext (* (* safety h) (expt errmax pgrow)))
     (setf hnext (* 4d0 h))))) 

  (do ((i 0 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf (aref y i) (+ (aref y i) (* (aref ytemp i) fcor)))) 
   
  (return (values y x hdid hnext))))

;------------------------------------------------------------------------------

(defun odeint (ystart x1 x2 eps h1 hmin derivs &key
        (maxstp 10000)
        (nmax 10)
        (step "rkqc")
        (tiny 1.0d-30) 
        (kmax 200)
        (dxsav 1.0d-2))
 (declare (type (simple-array double-float (*)) ystart)) 
 (declare (type double-float x1 x2 eps h1 hmin tiny dxsav))
 (declare (type fixnum maxstp nmax))
 (declare (type string step))
 (declare (ignore nmax))

 (prog* (
  (nvar (array-dimension ystart 0))
  (yscal 
    (make-array nvar :element-type 'double-float :initial-element 0d0))
  (y 
    (make-array nvar :element-type 'double-float :initial-element 0d0))
  (dydx 
    (make-array nvar :element-type 'double-float :initial-element 0d0))
  (xp 
    (make-array kmax :element-type 'double-float :initial-element 0d0))
  (yp 
    (make-array (list nvar kmax)
         :element-type 'double-float :initial-element 0d0))
  (x 0d0) (two 0d0) (zero 0d0) 
  (kount 0) (xo nil) (yo nil) (h 0d0)
  (nok 0) (nbad 0) (xsav 0d0) (hnext 0d0) (hdid 0d0))

  (declare (type (simple-array double-float (*)) yscal)) 
  (declare (type (simple-array double-float (*)) y)) 
  (declare (type (simple-array double-float (*)) dydx)) 
  (declare (type (simple-array double-float (*)) xp)) 
  (declare (type (simple-array double-float (* *)) yp)) 
;  (declare (type (simple-array double-float (*)) xo)) 
;  (declare (type (simple-array double-float (* *)) yo)) 
  (declare (type double-float two zero x h xsav hnext hdid))
  (declare (type fixnum nvar kount nok nbad))


  (setq two 2d0 zero 0d0)
  (setf x x1) 
  (setf h (signp h1 (+ x2 (- x1)))) 
  (setf nok 0) 
  (setf nbad 0) 
  (setf kount 0)
 
  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
    (setf (aref y i) (aref ystart i))) 

  (if (> kmax 0) (setf xsav (+ x (* (- dxsav) two)))) 
  (do ((nstp 1 (+ nstp 1)))
      ((> nstp maxstp) t)
;    (setq dydx (funcall derivs x y))
    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
     (setf (aref dydx i) 
           (dfloat (apply (nth i derivs) (cons x (list-array y)))))) 

    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
      (setf (aref yscal i) (+ (+ (abs (aref y i)) (abs (* h (aref dydx i))))
                              tiny)))

    (if 
     (> kmax 0)
     (if 
      (> (abs (+ x (- xsav))) (abs dxsav)) 
      (when (< kount (1- kmax)) 
       (setf kount (+ kount 1)) (setf (aref xp kount) x)
       (do ((i 0 (+ i 1)))
           ((> i (1- nvar)) t)
         (setf (aref yp i kount) (aref y i)))
       (setf xsav x))))

    (if (> (* (+ (+ x h) (- x2)) (+ (+ x h) (- x1))) zero)
      (setf h (+ x2 (- x))))

(cond
   ((equal step "rkqc")
    (multiple-value-setq (y x hdid hnext) (rkqc y dydx x h eps yscal derivs)))
   ((equal step "bsstep")
    (multiple-value-setq (y x hdid hnext) (bsstep y dydx x h eps yscal derivs)))
   (t (error " invalid step for odeint. ")))

    (if 
     (= hdid h)
     (setf nok (1+ nok))
     (setf nbad (1+ nbad)))
    (when 
     (>= (* (+ x (- x2)) (+ x2 (- x1))) zero)
     (do ((i 0 (+ i 1)))
         ((> i (1- nvar)) t)
       (setf (aref ystart i) (aref y i)))

     (when 
      (not (= kmax 0))
      (setf kount (+ kount 1)) (setf (aref xp (1- kount)) x)
      (do ((i 0 (+ i 1)))
          ((> i (1- nvar)) t)
        (setf (aref yp i (1- kount)) (aref y i))))
     (go end))
    (if (< (abs hnext) hmin) 
        (error " Stepsize smaller than the minimum in odeint "))
    (setf h hnext)) 
   
  (error " too many steps in odeint. ") 
end 
  (setq xo (make-array kount :element-type 'double-float 
  :initial-element 0d0))
  (setq yo (make-array (list nvar kount) :element-type 'double-float 
  :initial-element 0d0))

(do ((i 0 (1+ i))) ((> i (1- nvar)) t) (declare (type fixnum i))
 (do ((j 0 (1+ j))) ((> j (1- kount)) t) (declare (type fixnum j))
  (setf (aref xo j) (aref xp j))
  (setf (aref yo i j) (aref yp i j))))

  
  (return (values ystart xo yo kount nok nbad))))

;------------------------------------------------------------------------------

(defun mmid (y dydx xs htot nstep derivs &key (nmax 10))
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) dydx))
 (declare (type double-float xs htot))
 (declare (type fixnum nstep nmax))
 (declare (ignore nmax))
 
 (prog* (
  (nvar (array-dimension y 0))
  (yout (make-array nvar :element-type 'double-float :initial-element 0d0))
  (ym (make-array nvar :element-type 'double-float :initial-element 0d0))
  (yn (make-array nvar :element-type 'double-float :initial-element 0d0))
  (h 0d0) (x 0d0)
  (h2 0d0) (swap 0d0))

  (declare (type (simple-array double-float (*)) yout)) 
  (declare (type (simple-array double-float (*)) ym)) 
  (declare (type (simple-array double-float (*)) yn)) 
  (declare (type fixnum nvar))
  (declare (type double-float h h2 x swap))

  (setf h (/ htot nstep)) 

  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref ym i) (aref y i))
    (setf (aref yn i) (+ (aref y i) (* h (aref dydx i))))) 

  (setf x (+ xs h)) 
  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
     (setf (aref yout i) 
           (dfloat (apply (nth i derivs) (cons x (list-array yn))))) )

  (setf h2 (* 2d0 h)) 

  (do ((n 2 (+ n 1)))
      ((> n nstep) t)
      (declare (type fixnum n))
    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf swap (+ (aref ym i) (* h2 (aref yout i))))
      (setf (aref ym i) (aref yn i))
      (setf (aref yn i) swap))
    (setf x (+ x h))

    (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
     (setf (aref yout i) 
           (dfloat (apply (nth i derivs) (cons x (list-array yn))))) ))

  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref yout i) 
          (* 0.5d0
             (+ (+ (aref ym i) (aref yn i)) (* h (aref yout i)))))) 
  
  (return yout)))

;------------------------------------------------------------------------------

(defun bsstep (y dydx x htry eps yscal derivs &key
       (nmax 10)
       (imax 11)
       (ncol 7)
       (nuse 7)
       (shrink 0.95d0)
       (grow 1.2d0)
       (interp "rzextr"))
  (declare (type (simple-array double-float (*)) y)) 
  (declare (type (simple-array double-float (*)) dydx)) 
  (declare (type (simple-array double-float (*)) yscal)) 
  (declare (type fixnum nmax imax nuse ncol))
  (declare (type double-float shrink grow x))
  (declare (type string interp))

 (prog* (
  (nv (array-dimension y 0))
  (nseq 
      (make-array 11 :element-type 'fixnum 
         :initial-contents '(2 4 6 8 12 16 24 32 48 64 96 ))) 
  (yerr
    (make-array nv :element-type 'double-float :initial-element 0d0))
  (ysav
    (make-array nv :element-type 'double-float :initial-element 0d0))
  (dysav
    (make-array nv :element-type 'double-float :initial-element 0d0))
  (yseq
    (make-array nv :element-type 'double-float :initial-element 0d0))
  (one 1d0) interpfun
  (yz 0d0) (dy 0d0) (h 0d0) (xsav 0d0) 
  (xest 0d0) (errmax 0d0) (hdid 0d0) (hnext 0d0))

  (declare (type (simple-array double-float (*)) yerr)) 
  (declare (type (simple-array double-float (*)) ysav)) 
  (declare (type (simple-array double-float (*)) dysav)) 
  (declare (type (simple-array double-float (*)) yseq)) 
  (declare (type (simple-array fixnum (*)) nseq)) 
  (declare (type double-float one h xsav xest errmax hdid hnext))
  (declare (type fixnum nv))
  (declare (ignore dy yz))
  (if (/= imax 11) (error " imax is currently fixed with value 11"))

  (if (equal interp "pzextr")
      (setq interpfun #'pzextr)
      (setq interpfun #'rzextr))

  (setf h htry) 
  (setf xsav x) 
  (do ((i 0 (+ i 1)))
      ((> i (1- nv)) t)
      (declare (type fixnum i))
    (setf (aref ysav i) (aref y i))
    (setf (aref dysav i) (aref dydx i))) 

  label1 
  (do ((i 1 (+ i 1)))
      ((> i imax) t)
      (declare (type fixnum i))

    (setq yseq (mmid ysav dysav xsav h (aref nseq (1- i)) derivs))
    (setf xest (expt (/ h (aref nseq (1- i))) 2))
    (multiple-value-setq (y yerr) 
            (funcall interpfun i xest yseq nuse 
                                :nmax nmax :imax imax :ncol ncol))
    (when (> i 3)  
     (setf errmax 0d0)
     (do ((j 0 (+ j 1)))
         ((> j (1- nv)) t)
         (declare (type fixnum j))
       (setf errmax (max errmax (abs (/ (aref yerr j) (aref yscal j))))))
     (setf errmax (/ errmax eps))
     (when (< errmax one) 
       (setf x (+ x h))
       (setf hdid h)
       (cond 
        ((= i nuse) 
         (setf hnext (* h shrink)))
        ((= i (1- nuse))
         (setf hnext (* h grow)))
        (t
         (setf hnext (/ (* h (aref nseq (2- nuse))) (aref nseq (1- i))))))
     (go end)))) 


  (setf h (/ (* 0.25d0 h) (dfloat (expt 2 (/ (- imax nuse) 2))))) 
  (if (= (+ x h) x) (error "step size underflow in bsstep ")) 
  (go label1)
end
(return (values y x hdid hnext))))
;------------------------------------------------------------------------------
(fproclaim '(special $bsstep_ncol $bsstep_nmax $bsstep_imax))
(fproclaim '(special x-rzextr d-rzextr))
(fproclaim '(type (simple-array double-float (*)) x-rzextr))
(fproclaim '(type (simple-array double-float (* *)) d-rzextr))
#-aclpc (setq x-rzextr (make-array $bsstep_imax :element-type 'double-float :initial-element 0d0))
#-aclpc (setq d-rzextr 
   (make-array (list $bsstep_nmax $bsstep_ncol)
             :element-type 'double-float :initial-element 0d0))

(defun rzextr 
 (iest xest yest nuse &key (imax 11) (nmax 10) (ncol 7)) 
 (declare (type (simple-array double-float (*)) yest))
 (declare (type double-float xest))
 (declare (type fixnum iest nuse imax nmax ncol))
 (declare (ignore nmax imax))

 (prog* (
  (nv (array-dimension yest 0))
  (yz (make-array nv :element-type 'double-float :initial-element 0d0))
  (dy (make-array nv :element-type 'double-float :initial-element 0d0))
  (fx (make-array ncol :element-type 'double-float :initial-element 0d0))
  (b 0d0) (b1 0d0) (m1 0)
  (c 0d0) (v 0d0) (ddy 0d0) (yy 0d0))

  (declare (type (simple-array double-float (*)) yz)) 
  (declare (type (simple-array double-float (*)) dy)) 
  (declare (type (simple-array double-float (*)) fx)) 
  (declare (type fixnum nv m1))
  (declare (type double-float b b1 c v ddy yy))


  (setf (aref x-rzextr (1- iest)) xest) 
  (cond 
   ((= iest 1)
    (do ((j 0 (1+ j)))
        ((> j (1- nv)) t)
        (declare (type fixnum j))
      (setf (aref yz j) (aref yest j))
      (setf (aref d-rzextr j 0) (aref yest j))
      (setf (aref dy j) (aref yest j))))
   (t 
    (setf m1 (min iest nuse))
    (do ((k 1 (1+ k)))
        ((> k (1- m1)) t)
        (declare (type fixnum k))
      (setf (aref fx k) (/ (aref x-rzextr (1- (+ iest (- k)))) xest)))
    (do ((j 1 (1+ j)))
        ((> j nv) t)
        (declare (type fixnum j))
      (setf yy (aref yest (1- j)))
      (setf v (aref d-rzextr (1- j) 0))
      (setf c yy)
      (setf (aref d-rzextr (1- j) 0) yy)
      (do ((k 2 (1+ k)))
          ((> k m1) t)
          (declare (type fixnum k))
        (setf b1 (* (aref fx (1- k)) v))
        (setf b (+ b1 (- c)))
        (cond 
         ((not (= b 0d0))
          (setf b (/ (+ c (- v)) b)) (setf ddy (* c b)) (setf c (* b1 b))) 
         (t 
          (setf ddy v)))
        (if (not (= k m1)) (setf v (aref d-rzextr (1- j)  (1- k))))
        (setf (aref d-rzextr (1- j) (1- k)) ddy)
        (setf yy (+ yy ddy)))
      (setf (aref dy (1- j)) ddy)
      (setf (aref yz (1- j)) yy)))) 
   
  (return (values yz dy))))

;------------------------------------------------------------------------------

(fproclaim '(type (simple-array double-float (*)) x-pzextr))
(fproclaim '(type (simple-array double-float (* *)) qcol-pzextr))
(fproclaim '(special x-pzextr qcol-pzextr))
#-aclpc (setq x-pzextr (make-array $bsstep_imax :element-type 'double-float :initial-element 0d0))
#-aclpc (setq qcol-pzextr 
   (make-array (list $bsstep_nmax $bsstep_ncol) 
            :element-type 'double-float :initial-element 0d0))


(defun pzextr (iest xest yest nuse &key (imax 11) (ncol 7) (nmax 10))
 (declare (type (simple-array double-float (*)) yest))
 (declare (type double-float xest))
 (declare (type fixnum iest nuse imax ncol nmax))
 (declare (ignore imax ncol))

 (prog* (
  (nv (array-dimension yest 0))
  (dy (make-array nv :element-type 'double-float :initial-element 0d0))
  (d (make-array nmax :element-type 'double-float :initial-element 0d0))
  (yz (make-array nv :element-type 'double-float :initial-element 0d0))
  (delta 0d0) 
  (f1 0d0) (f2 0d0) (m1 0) (q 0d0)) 


  (declare (type (simple-array double-float (*)) yz)) 
  (declare (type (simple-array double-float (*)) dy)) 
  (declare (type (simple-array double-float (*)) d)) 
  (declare (type double-float delta f1 f2 q))
  (declare (type fixnum m1 nv))
   
  (setf (aref x-pzextr (1- iest)) xest) 
  (do ((j 0 (1+ j)))
      ((> j (1- nv)) t)
      (declare (type fixnum j))
    (setf (aref dy j) (aref yest j))
    (setf (aref yz j) (aref yest j))) 

  (cond
   ((= iest 1)
    (do ((j 0 (+ j 1)))
        ((> j (1- nv)) t)
        (declare (type fixnum j))
      (setf (aref qcol-pzextr j 0) (aref yest j))))
   (t 
    (setf m1 (min iest nuse))

    (do ((j 0 (+ j 1)))
        ((> j (1- nv)) t)
        (declare (type fixnum j))
      (setf (aref d j) (aref yest j)))

    (do ((k1 1 (+ k1 1)))
        ((> k1 (1- m1)) t)
        (declare (type fixnum k1))
      (setf delta (/ 1d0 (- (aref x-pzextr (1- (- iest k1))) xest)))
      (setf f1 (* xest delta))
      (setf f2 (* (aref x-pzextr (1- (- iest k1))) delta))

      (do ((j 0 (+ j 1)))
          ((> j (1- nv)) t)
          (declare (type fixnum j))
        (setf q (aref qcol-pzextr j (1- k1)))
        (setf (aref qcol-pzextr j (1- k1)) (aref dy j))
        (setf delta (- (aref d j) q))
        (setf (aref dy j) (* f1 delta))
        (setf (aref d j) (* f2 delta))
        (setf (aref yz j) (+ (aref yz j) (aref dy j)))))

    (do ((j 0 (+ j 1)))
        ((> j (1- nv)) t)
        (declare (type fixnum j))
      (setf (aref qcol-pzextr j (1- m1)) (aref dy j))))) 
   
  (return (values yz dy))))

;--------------------------------------------------------------------
; end of nr15.l
