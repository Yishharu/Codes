; nr16.l
; Two point boundary value problems
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;Modified by Ken Olum for Common Lisp, April 1996;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package "USER")
; functions:
;	shoot: solve the 2 point BVP by shooting
;	shootf: solve the 2 point BVP by shooting to a fitting point

;	solvde: solve the 2 point BVP by relaxation
;	  bksub: backsubstitution used by solvde
;	  pinvs: diagonalize a sub-block, used by solvde
;	  red: reduce columns of a matrix, used by solvde

;------------------------------------------------------------------------------
(declaim (special $verbose))

(defun shoot (v delv x1 x2 eps h1 hmin derivs load score )
 (declare (type (simple-array double-float (*)) v)) 
 (declare (type (simple-array double-float (*)) delv)) 
 (declare (type double-float x1 x2 eps h1 hmin))
 (declare (special kmax))

 (prog* (
  (n2 (array-dimension v 0))
  (nvar (length derivs))
  (f (make-array n2 :element-type 'double-float :initial-element 0d0))
  (dv (make-array n2 :element-type 'double-float :initial-element 0d0))
  (y (make-array nvar :element-type 'double-float :initial-element 0d0))
  (dfdv 
    (make-array (list n2 n2) 
       :element-type 'double-float :initial-element 0d0))
  (indx (make-array n2 :element-type 'fixnum :initial-element 0))
  (a 0d0) (sav 0d0))

  (declare (type (simple-array double-float (*)) f)) 
  (declare (type (simple-array double-float (*)) dv)) 
  (declare (type (simple-array double-float (*)) y)) 
  (declare (type (simple-array double-float (* *)) dfdv)) 
  (declare (type (simple-array fixnum (*)) indx)) 
  (declare (type fixnum n2 nvar))
  (declare (type double-float sav))

  (progn a)				;Ignorable

;  (setq np nvar) 

  (setf kmax 0) 
  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref y i) 
          (dfloat-check (funcall (nth i load) x1 v))))


  (setq y (odeint y x1 x2 eps h1 hmin derivs))
  (do ((i 0 (+ i 1)))
      ((> i (1- n2)) t)
      (declare (type fixnum i))
    (setf (aref f i) 
          (dfloat-check (funcall (nth i score) x2 v))))

  (do ((iv 0 (+ iv 1)))
      ((> iv (1- n2)) t)
      (declare (type fixnum iv))
    (setf sav (aref v iv))
    (setf (aref v iv) (+ (aref v iv) (aref delv iv)))


    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref y i) 
            (dfloat-check (funcall (nth i load) x1 v))))

    (setq y (odeint y x1 x2 eps h1 hmin derivs))

    (do ((i 0 (+ i 1)))
        ((> i (1- n2)) t)
        (declare (type fixnum i))
      (setf (aref dv i) 
            (dfloat-check (funcall (nth i score) x2 v))) )


    (do ((i 0 (+ i 1)))
        ((> i (1- n2)) t)
        (declare (type fixnum i))
      (setf (aref dfdv i iv) (/ (+ (aref dv i) (- (aref f i)))
                                (aref delv iv))))
    (setf (aref v iv) sav)) 

  (do ((iv 0 (+ iv 1)))
      ((> iv (1- n2)) t)
      (declare (type fixnum iv))
    (setf (aref dv iv) (- (aref f iv)))) 

  (multiple-value-setq (a indx) (ludcmp dfdv))

  (setq dv (lubksb dfdv indx dv))

  (do ((iv 0 (+ iv 1)))
      ((> iv (1- n2)) t)
      (declare (type fixnum iv))
    (setf (aref v iv) (+ (aref v iv) (aref dv iv)))) 

  (return (values y v f dv))))

;------------------------------------------------------------------------------
(defun shootf (v1 v2 delv1 delv2 x1 x2 xf eps h1 hmin 
               derivs load1 load2 score)
 (declare (type (simple-array double-float (*)) v1)) 
 (declare (type (simple-array double-float (*)) v2)) 
 (declare (type (simple-array double-float (*)) delv1)) 
 (declare (type (simple-array double-float (*)) delv2)) 
 (declare (type double-float x1 x2 xf eps h1 hmin))
 (declare (special kmax))

 (prog* (
  (n2 (array-dimension v1 0))
  (n1 (array-dimension v2 0))
  (nvar (length derivs))
  (f (make-array nvar :element-type 'double-float :initial-element 0d0))
  (f1 (make-array nvar :element-type 'double-float :initial-element 0d0))
  (f2 (make-array nvar :element-type 'double-float :initial-element 0d0))
  (dv1 (make-array n2 :element-type 'double-float :initial-element 0d0))
  (dv2 (make-array n1 :element-type 'double-float :initial-element 0d0))
  (y (make-array nvar :element-type 'double-float :initial-element 0d0))
  (dfdv 
    (make-array (list nvar nvar) 
       :element-type 'double-float :initial-element 0d0))
  (indx (make-array nvar :element-type 'fixnum :initial-element 0))
    (j 0) (sav 0d0) (a 0d0))

  (declare (type (simple-array double-float (*)) f f1 f2 dv1 dv2)) 
  (declare (type (simple-array double-float (*)) dv)) 
  (declare (type (simple-array double-float (*)) y)) 
  (declare (type (simple-array double-float (* *)) dfdv)) 
  (declare (type (simple-array fixnum (*)) indx)) 
  (declare (type fixnum n2 nvar j))
  (declare (type double-float sav a))
  (declare (ignore kp))

  (progn a)				;Ignorable

  (setf kmax 0) 
 
  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref y i) 
          (dfloat-check (funcall (nth i load1) x1 v1))) )

  (setq y (odeint y x1 xf eps h1 hmin derivs))
 
  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref f1 i) 
          (dfloat-check (funcall (nth i score) xf y))) )

 
  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref y i) 
          (dfloat-check (funcall (nth i load2) x2 v2))) )

  (setq y (odeint y x2 xf eps h1 hmin derivs))
 
  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref f2 i) 
          (dfloat-check (funcall (nth i score) xf y))) )

  (setf j 0) 
  (do ((iv 0 (+ iv 1)))
      ((> iv (1- n2)) t)
      (declare (type fixnum iv))
    (setf j (+ j 1))
    (setf sav (aref v1 iv))
    (setf (aref v1 iv) (+ (aref v1 iv) (aref delv1 iv)))


    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref y i) 
            (dfloat-check (funcall (nth i load1) x1 v1))) )

    (setq y (odeint y x1 xf eps h1 hmin derivs))


    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref f i) 
            (dfloat-check (funcall (nth i score) xf y))) )


    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref dfdv i (1- j)) (/ (+ (aref f i) (- (aref f1 i)))
                               (aref delv1 iv))))
    (setf (aref v1 iv) sav)) 

  (do ((iv 0 (+ iv 1)))
      ((> iv (1- n1)) t)
      (declare (type fixnum iv))
    (setf j (+ j 1))
    (setf sav (aref v2 iv))
    (setf (aref v2 iv) (+ (aref v2 iv) (aref delv2 iv)))

    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref y i) 
            (dfloat-check (funcall (nth i load2) x2 v2)))) 

    (setq y (odeint y x2 xf eps h1 hmin derivs))


    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref f i) 
            (dfloat-check (funcall (nth i score) xf y))))

    (do ((i 0 (+ i 1)))
        ((> i (1- nvar)) t)
        (declare (type fixnum i))
      (setf (aref dfdv i (1- j)) (/ (+ (aref f2 i) (- (aref f i)))
                               (aref delv2 iv))))
    (setf (aref v2 iv) sav)) 

  (do ((i 0 (+ i 1)))
      ((> i (1- nvar)) t)
      (declare (type fixnum i))
    (setf (aref f i) (+ (aref f1 i) (- (aref f2 i))))
    (setf (aref f1 i) (- (aref f i)))) 

  (multiple-value-setq (a indx) (ludcmp dfdv)) 
  (setq f1 (lubksb dfdv indx f1)) 

  (setf j 0) 

  (do ((iv 0 (+ iv 1)))
      ((> iv (1- n2)) t)
      (declare (type fixnum iv))
    (setf j (+ j 1))
    (setf (aref v1 iv) (+ (aref v1 iv) (aref f1 (1- j))))
    (setf (aref dv1 iv) (aref f1 (1- j)))) 

  (do ((iv 0 (+ iv 1)))
      ((> iv (1- n1)) t)
      (declare (type fixnum iv))
    (setf j (+ j 1))
    (setf (aref v2 iv) (+ (aref v2 iv) (aref f1 (1- j))))
    (setf (aref dv2 iv) (aref f1 (1- j)))) 
  
  (return (values y v1 v2 f dv1 dv2))))

;-----------------------------------------------------------------------------
(defun solvde
 (scalv indexv nb y difeq &key (nmax 10) (itmax 200)
 (conv 1.0d-4) (slowc 1d0))
 (declare (type (simple-array double-float (* *)) y)) 
 (declare (type (simple-array double-float (*)) scalv)) 
 (declare (type (simple-array fixnum (*)) indexv)) 
 (declare (type fixnum nb nmax itmax))
 (declare (type double-float conv slowc))
 (declare (ignore nmax))


 (prog* (
  (nyj (array-dimension y 0))
  (nyk (array-dimension y 1))
  (ne (array-dimension indexv 0))
  (m nyk)
  (nci ne) (ncj (1+ (- ne nb))) (nck (1+ m)) (nsi ne) (nsj (1+ (* 2 ne)))
  (c 
   (make-array (list nci ncj nck) 
        :element-type 'double-float :initial-element 0d0))

  (kmax (make-array ne :element-type 'fixnum :initial-element 0))
  (ermax (make-array ne :element-type 'double-float :initial-element 0d0))
  (s (make-array (list nsi nsj) :element-type 'double-float
        :initial-element 0d0))
        (k1 0) (k2 0) (nvars 0) 
        (j1 0) (j2 0) (j3 0) (j4 0) (j5 0) (j6 0) 
        (j7 0) (j8 0) (j9 0) (ic1 0) (ic2 0) 
        (ic3 0) (ic4 0) (jc1 0) (jcf 0) 
        (k 0) (iflag 0) (kp 0) (err 0d0) 
        (jv 0) (errj 0d0) (km 0) (vmax 0d0)
        (vz 0d0) (fac 0d0) (j 0))

  (declare (type (simple-array double-float (* *)) s)) 
  (declare (type (simple-array double-float (* * *)) c)) 
  (declare (type (simple-array double-float (*)) ermax)) 
  (declare (type (simple-array fixnum (*)) kmax)) 
  (declare (type fixnum m k1 k2 nvars j1 j2 j3 j4 j5 j6 j7 j8 j9
      ic1 ic2 ic3 ic4 jc1 jcf k iflag kp jv km j))
  (declare (type double-float fac fz vmax errj err))
  
  (progn iflag)				;Ignorable

  (setf k1 1) 
  (setf k2 m) 
  (setf nvars (* ne m)) 
  (setf j1 1) 
  (setf j2 nb) 
  (setf j3 (+ nb 1)) 
  (setf j4 ne) 
  (setf j5 (+ j4 j1)) 
  (setf j6 (+ j4 j2)) 
  (setf j7 (+ j4 j3)) 
  (setf j8 (+ j4 j4)) 
  (setf j9 (+ j8 j1)) 
  (setf ic1 1) 
  (setf ic2 (+ ne (- nb))) 
  (setf ic3 (+ ic2 1)) 
  (setf ic4 ne) 
  (setf jc1 1) 
  (setf jcf ic3) 
  (do ((it 1 (+ it 1)))
      ((> it itmax) t)
      (declare (type fixnum it))
    (setf k k1)
    (funcall difeq k k1 k2 j9 ic3 ic4 indexv ne nsi nsj s y nyj nyk)
    (setq iflag (pinvs ic3 ic4 j5 j9 jc1 k1 c nci ncj nck s nsi nsj :nmax ne))
    (do ((k (+ k1 1) (+ k 1)))
        ((> k k2) t)
        (declare (type fixnum k))
      (setf kp (+ k (- 1)))
      (funcall difeq k k1 k2 j9 ic1 ic4 indexv ne nsi nsj s y nyj nyk)

      (setq iflag (red ic1 ic4 j1 j2 j3 j4 j9 ic3 jc1 jcf kp c nci ncj nck s
		       nsi nsj))
      (setq iflag (pinvs ic1 ic4 j3 j9 jc1 k c nci ncj nck s nsi nsj
			 :nmax ne)))
    (setf k (+ k2 1))
    (funcall difeq k k1 k2 j9 ic1 ic2 indexv ne nsi nsj s y nyj nyk)
    (setq iflag (red ic1 ic2 j5 j6 j7 j8 j9 ic3 jc1 jcf k2 c nci ncj nck s nsi
                 nsj))
    (setq iflag (pinvs ic1 ic2 j7 j9 jcf (1+ k2)  c nci ncj nck s nsi nsj
                                                   :nmax ne))
    (setq iflag (bksub ne nb jcf k1 k2 c nci ncj nck))

    (setf err 0d0)
    (do ((j 1 (+ j 1)))
        ((> j ne) t)
      (declare (type fixnum j))
      (setf jv (aref indexv (1- j)))
      (setf errj 0d0)
      (setf km 0)
      (setf vmax 0d0)
      (do ((k k1 (+ k 1)))
          ((> k k2) t)
          (declare (type fixnum k))
        (setf vz (abs (aref c (1- j) 0 (1- k))))
        (when 
         (> vz vmax)  
         (setf vmax vz)
         (setf km k))
        (setf errj (+ errj vz)))
      (setf err (+ err (/ errj (aref scalv (1- jv)))))
      (setf (aref ermax (1- j)) 
            (/ (aref c (1- j) 0 (1- km)) (aref scalv (1- jv))))
      (setf (aref kmax (1- j)) km))
    (setf err (/ err nvars))
    (setf fac (/ slowc (max slowc err)))
    (do ((jv 1 (+ jv 1)))
        ((> jv ne) t)
        (declare (type fixnum jv))
      (setf j (aref indexv (1- jv)))
      (do ((k k1 (+ k 1)))
          ((> k k2) t)
          (declare (type fixnum k))
        (setf (aref y (1- j) (1- k)) 
              (+ (aref y (1- j) (1- k)) 
                 (* (- fac) (aref c (1- jv) 0 (1- k)))))))
    (if (< err conv) (go end)))
  (error " itmax exceeded in solvde ") 
  end
  (return y)))

;------------------------------------------------------------------------------


(defun bksub (ne nb jf k1 k2 c nci ncj nck)
 (declare (type fixnum ne nb jf k1 k2 nci ncj nck))
 (declare (type (simple-array double-float (* * *)) c))
 (declare (ignore nci ncj nck))

 (prog ((nbf 0) (im 0) (kp 0) (xx 0d0))
  (declare (type fixnum nbf kp im))
  (declare (type double-float xx))

  (setf nbf (- ne nb)) 
  (setf im 1) 
  (do ((k k2 (1- k)))
      ((< k k1) t)
      (declare (type fixnum k))
    (if (= k k1) (setf im (+ nbf 1)))
    (setf kp (+ k 1))
    (do ((j 1 (+ j 1)))
        ((> j nbf) t)
        (declare (type fixnum j))
      (setf xx (aref c (1- j) (1- jf) (1- kp)))
      (do ((i im (+ i 1)))
          ((> i ne) t)
          (declare (type fixnum i))
        (setf (aref c (1- i) (1- jf) (1- k)) 
              (+ (aref c (1- i) (1- jf) (1- k)) 
                 (* (- (aref c (1- i) (1- j) (1- k))) xx)))))) 

  (do ((k k1 (+ k 1)))
      ((> k k2) t)
      (declare (type fixnum k))
    (setf kp (+ k 1))
    (do ((i 1 (+ i 1)))
        ((> i nb) t)
        (declare (type fixnum i))
      (setf (aref c (1- i) 0 (1- k)) 
            (aref c (1- (+ i nbf)) (1- jf) (1- k))))
    (do ((i 1 (+ i 1)))
        ((> i nbf) t)
        (declare (type fixnum i))
      (setf (aref c (1- (+ i nb)) 0 (1- k)) 
            (aref c (1- i) (1- jf) (1-  kp))))) 

  (return 0)))

;------------------------------------------------------------------------------

(defun pinvs (ie1 ie2 je1 jsf jc1 k c nci ncj nck s nsi nsj &key (nmax 10))
  (declare (type (simple-array double-float (* * *)) c)) 
  (declare (type (simple-array double-float (* *)) s)) 
  (declare (special nmax))
  (declare (type fixnum ie1 ie2 je1 jsf jc1 k nci ncj nck nsi nsj nmax nmax))
  (declare (ignore nsj nsi nsk nci ncj nck))
 
  (prog* (
   (pscl 
       (make-array nmax :element-type 'double-float :initial-element 0d0))
   (indxr 
       (make-array nmax :element-type 'fixnum :initial-element 0))
   (zero 0d0) (one 0d0) 
   (je2 0) (js1 0) (big 0d0) (piv 0d0) (jp 0)
   (ipiv 0) (jpiv 0) (pivinv 0d0) (dum 0d0)
   (jcoff 0) (icoff 0) (irow 0))

   (declare (type fixnum je2 js1 jp ipiv jpiv jcoff icoff irow))
   (declare (type double-float big piv pivinv dum))
   (declare (type (simple-array double-float (*)) pscl)) 
   (declare (type (simple-array fixnum (*)) indxr)) 

  (setq zero 0d0
        one 1d0) 

  (setf je2 (+ (+ je1 ie2) (- ie1))) 
  (setf js1 (+ je2 1)) 
  (do ((i ie1 (+ i 1)))
      ((> i ie2) t)
      (declare (type fixnum i))
    (setf big zero)
    (do ((j je1 (+ j 1)))
        ((> j je2) t)
        (declare (type fixnum j))
      (if (> (abs (aref s (1- i) (1- j))) big) 
          (setf big (abs (aref s (1- i) (1- j))))))
    (if (= big zero)
      (error "singular matrix in pinvs called by solvde - a row is zero"))
    (setf (aref pscl (1- i)) (/ one big))
    (setf (aref indxr (1- i)) 0)) 

  (do ((id ie1 (+ id 1)))
      ((> id ie2) t)
      (declare (type fixnum id))
    (setf piv zero)
    (do ((i ie1 (+ i 1)))
        ((> i ie2) t)
      (declare (type fixnum i))
      (when 
       (= (aref indxr (1- i)) 0)
       (setf big zero)
       (do ((j je1 (+ j 1)))
           ((> j je2) t)
           (declare (type fixnum j))
         (when 
          (> (abs (aref s (1- i) (1- j))) big)
          (setf jp j) (setf big (abs (aref s (1- i) (1- j))))))
       (when 
        (> (* big (aref pscl (1- i))) piv)
        (setf ipiv i) 
        (setf jpiv jp) 
        (setf piv (* big (aref pscl (1- i)))))))

    (if (= (aref s (1- ipiv) (1- jpiv)) zero) 
        (error "singular matrix in pinvs called by solvde"))
    (setf (aref indxr (1- ipiv)) jpiv)
    (setf pivinv (/ one (aref s (1- ipiv) (1- jpiv))))
    (do ((j je1 (+ j 1)))
        ((> j jsf) t)
        (declare (type fixnum j))
      (setf (aref s (1- ipiv) (1- j)) 
            (* (aref s (1- ipiv) (1- j)) pivinv)))
    (setf (aref s (1- ipiv) (1- jpiv)) one)
    (do ((i ie1 (+ i 1)))
        ((> i ie2) t)
        (declare (type fixnum i))
      (when (not (= (aref indxr (1- i)) jpiv)) 
       (when (not (= (aref s (1- i) (1- jpiv)) zero))
        (setf dum (aref s (1- i) (1- jpiv)))
        (do ((j je1 (+ j 1)))
            ((> j jsf) t)
            (declare (type fixnum j))
          (setf (aref s (1- i) (1- j)) 
                (+ (aref s (1- i) (1- j)) 
                   (* (- dum) (aref s (1- ipiv) (1- j))))))
        (setf (aref s (1- i) (1- jpiv)) zero))))) 

  (setf jcoff (+ jc1 (- js1))) 
  (setf icoff (+ ie1 (- je1))) 
  (do ((i ie1 (+ i 1)))
      ((> i ie2) t)
      (declare (type fixnum i))
    (setf irow (+ (aref indxr (1- i)) icoff))
    (do ((j js1 (+ j 1)))
        ((> j jsf) t)
        (declare (type fixnum j))
      (setf (aref c (1- irow) (1- (+ j jcoff)) (1- k)) 
            (aref s (1- i) (1- j))))) 
  (return 0)))

;------------------------------------------------------------------------------

(defun red (iz1 iz2 jz1 jz2 jm1 jm2 jmf ic1 jc1 jcf kc c nci ncj nck s nsi nsj)
 (declare (type (simple-array double-float (* * *)) c))
 (declare (type (simple-array double-float (* *)) s)) 
 (declare (type fixnum 
               nci ncj nck nsi nsj iz1 iz2 jz1 jz2 jm1 jm2 jmf ic1 jc1 jcf kc))
 (declare (ignore nci ncj nck nsi nsj))

 (prog ((vx 0d0) (loff 0) (ic 0))
  (declare (type double-float vx))
  (declare (type fixnum loff ic))

  (setf loff (+ jc1 (- jm1))) 
  (setf ic ic1) 
  (do ((j jz1 (+ j 1)))
      ((> j jz2) t)
      (declare (type fixnum j))
    (do ((l jm1 (+ l 1)))
        ((> l jm2) t)
        (declare (type fixnum l))
      (setf vx (aref c (1- ic) (1- (+ l loff)) (1- kc)))
      (do ((i iz1 (+ i 1)))
          ((> i iz2) t)
          (declare (type fixnum i))
        (setf (aref s (1- i) (1- l)) (+ (aref s (1- i) (1- l)) 
                                        (* (- (aref s (1- i) (1- j))) vx)))))

    (setf vx (aref c (1- ic) (1- jcf) (1- kc)))

    (do ((i iz1 (+ i 1)))
        ((> i iz2) t)
        (declare (type fixnum i))
      (setf (aref s (1- i) (1- jmf)) (+ (aref s (1- i) (1- jmf)) 
                                        (* (- (aref s (1- i) (1- j))) vx))))
    (setf ic (+ ic 1))) 
   
  (return 0)))

;------------------------------------------------------------------------------
; end of nr16.l

