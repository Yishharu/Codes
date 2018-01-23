; nr17.l
; Partial differential equations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;Modified by Ken Olum for Common Lisp, April 1996;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package "USER")
; functions:
;	sor: elliptic pde solved by the simultaneous overrelaxation method
;	adi: elliptic pde solved by the alternating direction implicit
;	     method
;		tridag2 - passes extra array dimensions
;------------------------------------------------------------------------------

(defun sor (a b c d e f u rjac &key (maxits 1000) (eps 1.0d-5))
 (declare (type (simple-array double-float (* *)) a)) 
 (declare (type (simple-array double-float (* *)) b)) 
 (declare (type (simple-array double-float (* *)) c)) 
 (declare (type (simple-array double-float (* *)) d)) 
 (declare (type (simple-array double-float (* *)) e)) 
 (declare (type (simple-array double-float (* *)) f)) 
 (declare (type (simple-array double-float (* *)) u)) 
 (declare (type fixnum maxits))
 (declare (type double-float eps rjac))

 (prog ((zero 0d0) (half 0d0) (qtr 0d0) (one 0d0) (anormf 0d0) 
        (omega 0d0) (anorm 0d0) (resid 0d0) (jmax 0))
  (declare (type double-float zero half qtr one anormf
                                           omega anorm resid))
  (declare (type fixnum jmax))

  (setq jmax (array-dimension a 0))

 (setq zero 0.0d0
        half 0.5d0
        qtr 0.25d0
        one 1.0d0) 
  (setf anormf zero)
 
  (do ((j 1 (+ j 1)))
      ((> j (- jmax 2)) t)
      (declare (type fixnum j))
    (do ((l 1 (+ l 1)))
        ((> l (- jmax 2)) t)
        (declare (type fixnum l))
      (setf anormf (+ anormf (abs (aref f j l)))))) 

  (setf omega one) 
  (do ((n 1 (+ n 1)))
      ((> n maxits) t)
      (declare (type fixnum n))
    (setf anorm zero)
    (do ((j 1 (+ j 1)))
        ((> j (- jmax 2)) t)
        (declare (type fixnum j))
      (do ((l 1 (+ l 1)))
          ((> l (- jmax 2)) t)
          (declare (type fixnum l))
        (when 
         (= (mod (+ j l) 2) (mod n 2))
         (setf resid (+ (+ (+ (+ (+ (* (aref a j l) (aref u (+ j 1) l))
                                    (* (aref b j l) (aref u (1- j) l)))
                                 (* (aref c j l) (aref u j (+ l 1))))
                              (* (aref d j l) (aref u j (1- l))))
                           (* (aref e j l) (aref u j l)))
                        (- (aref f j l))))
         (setf anorm (+ anorm (abs resid)))
         (setf (aref u j l) (+ (aref u j l)
                               (/ (* (- omega) resid) (aref e j l)))))))

    (if 
     (= n 1)
     (setf omega (/ one (+ one (* (- half) (expt rjac 2)))))
     (setf omega (/ one (+ one (* (* (- qtr) (expt rjac 2)) omega)))))

    (if (and (> n 1) (< anorm (* eps anormf))) (go end))) 
   
  (error " maxits exceeded in sor ")
end
(return u)))

;------------------------------------------------------------------------------
(defun adi (a b c d e f g u k alpha beta 
             &key (eps 1.0d-5)  (jj 50) (maxits 100) (kk 6) (nrr 32))

 (declare (type (simple-array double-float (* *)) a)) 
 (declare (type (simple-array double-float (* *)) b)) 
 (declare (type (simple-array double-float (* *)) c)) 
 (declare (type (simple-array double-float (* *)) d)) 
 (declare (type (simple-array double-float (* *)) e)) 
 (declare (type (simple-array double-float (* *)) f)) 
 (declare (type (simple-array double-float (* *)) g)) 
 (declare (type (simple-array double-float (* *)) u)) 
 (declare (type double-float alpha beta eps))
 (declare (type fixnum jj maxits kk nrr))

 (prog* (
  (aa (make-array jj :element-type 'double-float :initial-element 0d0))
  (bb (make-array jj :element-type 'double-float :initial-element 0d0))
  (cc (make-array jj :element-type 'double-float :initial-element 0d0))
  (rr (make-array jj :element-type 'double-float :initial-element 0d0))
  (uu (make-array jj :element-type 'double-float :initial-element 0d0))
  (psi 
     (make-array (list jj jj) :element-type 'double-float :initial-element 0d0))
  (alph (make-array kk :element-type 'double-float :initial-element 0d0))
  (bet (make-array kk :element-type 'double-float :initial-element 0d0))
  (r (make-array nrr :element-type 'double-float :initial-element 0d0))
  (s 
    (make-array (list nrr kk) :element-type 'double-float :initial-element 0d0))
  (zero 0d0) (two 0d0) (half 0d0) (jmax 0) 
  (k1 0) (nr 0) (ab 0d0) (disc 0d0)
  (anormg 0d0) (nits 0) (next 0) (rfact 0d0)
  (anorm  0d0) (resid 0d0))

  (declare (type (simple-array double-float (*)) aa)) 
  (declare (type (simple-array double-float (*)) bb)) 
  (declare (type (simple-array double-float (*)) cc)) 
  (declare (type (simple-array double-float (*)) rr)) 
  (declare (type (simple-array double-float (*)) uu)) 
  (declare (type (simple-array double-float (* *)) psi)) 
  (declare (type (simple-array double-float (*)) alph)) 
  (declare (type (simple-array double-float (*)) bet)) 
  (declare (type (simple-array double-float (*)) r)) 
  (declare (type (simple-array double-float (* *)) s)) 
  (declare (type double-float zero two half ab disc anormg rfact anorm resid))
  (declare (type fixnum jmax k1 nr nits next))

  (setq jmax (array-dimension a 0))

  (setq zero 0.0d0
        two 2.0d0
        half 0.5d0) 

  (setq jmax (array-dimension a 0))

  (if (> jmax jj) (error " increase jj in adi ")) 
  (if (> k (+ kk (- 1))) (error " increase kk in adi ")) 
  (setf k1 (+ k 1)) 
  (setf nr (expt 2 k)) 

  (setf (fref alph 1) alpha) 
  (setf (fref bet 1) beta) 

  (do ((j 1 (+ j 1)))
      ((> j k) t)
      (declare (type fixnum j))
    (setf (fref alph (+ j 1)) (sqrt (* (fref alph j) (fref bet j))))
    (setf (fref bet (+ j 1)) (* half (+ (fref alph j) (fref bet j))))) 

  (setf (fref s 1 1) (sqrt (* (fref alph k1) (fref bet k1)))) 
  (do ((j 1 (+ j 1)))
      ((> j k) t)
      (declare (type fixnum j))
    (setf ab (* (fref alph (+ k1 (- j))) (fref bet (+ k1 (- j)))))
    (do ((n 1 (+ n 1)))
        ((> n (expt 2 (1- j))) t)
        (declare (type fixnum n))
      (setf disc (sqrt (+ (expt (fref s n j) 2) (- ab))))
      (setf (fref s (* 2 n) (+ j 1)) (+ (fref s n j) disc))
      (setf (fref s (1- (* 2 n)) (+ j 1)) (/ ab (fref s (* 2 n) (1+ j))))))
 
  (do ((n 1 (+ n 1)))
      ((> n nr) t)
      (declare (type fixnum n))
    (setf (fref r n) (fref s n k1))) 

  (setf anormg zero) 
  (do ((j 2 (+ j 1)))
      ((> j (1- jmax)) t)
      (declare (type fixnum j))
    (do ((l 2 (+ l 1)))
        ((> l (1- jmax)) t)
        (declare (type fixnum l))
      (setf anormg (+ anormg (abs (fref g j l))))
      (setf (fref psi j l) (+ (+ (* (- (fref d j l))
                                    (fref u j (1- l)))
                                 (* (+ (fref r 1) (- (fref e j l)))
                                    (fref u j l)))
                              (* (- (fref f j l)) (fref u j (+ l 1))))))) 

  (setf nits (floor (/ maxits nr))) 
  (do ((kits 1 (+ kits 1)))
      ((> kits nits) t)
      (declare (type fixnum kits))
    (do ((n 1 (1+ n)))
        ((> n nr) t)
        (declare (type fixnum n))
      (if 
        (= n nr) 
        (setf next 1)
        (setf next (+ n 1)))
      (setf rfact (+ (fref r n) (fref r next)))
      (do ((l 2 (+ l 1)))
          ((> l (1- jmax)) t)
          (declare (type fixnum l))
        (do ((j 2 (+ j 1)))
            ((> j (1- jmax)) t)
            (declare (type fixnum j))
          (setf (fref aa (1- j)) (fref a j l))
          (setf (fref bb (1- j)) (+ (fref b j l) (fref r n)))
          (setf (fref cc (1- j)) (fref c j l))
          (setf (fref rr (1- j)) 
                (+ (fref psi j l) (- (fref g j l)))))
        (setq uu (tridag2 aa bb cc rr (- jmax 2) jj :nmax (- jmax 2)))
        (do ((j 2 (+ j 1)))
            ((> j (1- jmax)) t)
            (declare (type fixnum j))
          (setf (fref psi j l) (+ (- (fref psi j l))
                                  (* (* two (fref r n))
                                     (fref uu (1- j)))))))

      (do ((j 2 (+ j 1)))
          ((> j (1- jmax)) t)
          (declare (type fixnum j))
        (do ((l 2 (+ l 1)))
            ((> l (1- jmax)) t)
            (declare (type fixnum l))
          (setf (fref aa (1- l)) (fref d j l))
          (setf (fref bb (1- l)) (+ (fref e j l) (fref r n)))
          (setf (fref cc (1- l)) (fref f j l))
          (setf (fref rr (1- l)) (fref psi j l)))

        (setq uu (tridag2 aa bb cc rr (- jmax 2) jj :nmax (- jmax 2)))
        (do ((l 2 (+ l 1)))
            ((> l (1- jmax)) t)
            (declare (type fixnum l))
          (setf (fref u j l) (fref uu (1- l)))
          (setf (fref psi j l) (+ (- (fref psi j l))
                                  (* rfact (fref uu (1- l))))))))

    (setf anorm zero)
    (do ((j 2 (+ j 1)))
        ((> j (1- jmax)) t)
        (declare (type fixnum j))
      (do ((l 2 (+ l 1)))
          ((> l (1- jmax)) t)
          (declare (type fixnum l))
        (setf resid (+ (+ (+ (+ (+ (* (fref a j l) (fref u (1- j) l))
                                   (* (+ (fref b j l) (fref e j l))
                                      (fref u j l)))
                                (* (fref c j l) (fref u (+ j 1) l)))
                             (* (fref d j l) (fref u j (1- l))))
                          (* (fref f j l) (fref u j (+ l 1))))
                       (fref g j l)))
        (setf anorm (+ anorm (abs resid)))))
    
    (if (< anorm (* eps anormg)) (go end))) 
   
  (error " maxits exceeded in adi ")
end
(return u)
))

;-----------------------------------------------------------------------------
(defun tridag2 (a b c r n m &key (nmax 100))
 (declare (type (simple-array double-float (*)) a)) 
 (declare (type (simple-array double-float (*)) b)) 
 (declare (type (simple-array double-float (*)) c)) 
 (declare (type (simple-array double-float (*)) r)) 
  (declare (type fixnum n m))
 
 (prog ((u (make-array m :element-type 'double-float :initial-element 0d0))
        (gam (make-array nmax :element-type 'double-float :initial-element 0d0))        (bet 0d0))
  (declare (type (simple-array double-float (*)) u)) 
  (declare (type (simple-array double-float (*)) gam)) 
  (declare (type double-float bet))


  (if (= (aref b 0) 0d0) (error " error in tridag - b(1) is zero ")) 
  (setf bet (aref b 0)) 
  (setf (aref u 0) (/ (aref r 0) bet)) 

  (do ((j 1 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref gam j) (/ (aref c (1- j)) bet))
    (setf bet (+ (aref b j) (* (- (aref a j)) (aref gam j))))
    (if (= bet 0d0) (error " error in tridag2 from adi "))
    (setf (aref u j) (/ (+ (aref r j)
                           (* (- (aref a j)) (aref u (1- j))))
                        bet))) 

  (do ((j (- n 2) (1- j)))
      ((< j 0) t)
      (declare (type fixnum j))
    (setf (aref u j) (+ (aref u j)
                        (* (- (aref gam (1+ j))) (aref u (1+ j)))))) 
   
  (return u)))
;------------------------------------------------------------------------------

; end of nr17.l

