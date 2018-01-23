; nr06.l
; Special functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	gammln: logarithm of the gamma function
;	factrl: factorial function
;	bico: binomial coefficient function
;	factln: logarithm of the factorial function
;	beta: beta function
;	gammp: incomplete gamma function
;	gammq: incomplete complementary gamma function
;	gser: series evaluation of the incomplete gamma function
;	gcf: continued fraction evaluation of the incomplete gamma function
;	erf: error function
;	erfc: complementary error function
;	erfcc: complementary error function, consise routine
;	betai: incomplete beta function
;	betacf: incomplete beta function, continued fraction evaluation
;	bessj0: bessel function J0
;	bessy0: bessel function Y0
;	bessj1: bessel function J1
;	bessy1: bessel function Y1
;	bessj: bessel function J of integer order
;	bessy: bessel function Y of integer order
;	bessi0: modified bessel function I0
;	bessk0: modified bessel function K0
;	bessi1: modified bessel function I1
;	bessk1: modified bessel function K1
;	bessi: modified bessel function I of integer order
;	bessk: modified bessel function K of integer order
;	plgndr: associated Legendre polynomial (spherical harmonics)
;	el2: elliptic integrals of the first and second kind
;	sncndn: Jacobian elliptic function
;----------------------------------------------------------------------------

(defun gammln (xx)
 (declare (type double-float xx)) 

 (prog ((cof (make-array 6 :element-type 'double-float :initial-contents
             '(76.18009173d0 -86.50532033d0 24.01409822d0 
               -1.231739516d0 0.120858003d-2 -0.536382d-5)))
        (stp 0d0) (half 0d0) (one 0d0) (fpf 0d0) 
        (tmp 0d0) (ser 0d0) (gammln 0d0) (x 0d0))

  (declare (type (simple-array double-float (*)) cof)) 
  (declare (type double-float stp half one fpf tmp ser x gammln)) 

  (setq stp  2.50662827465d0)

  (setq half 0.5d0 one 1.0d0 fpf 5.5d0) 
 
  (setf x (1- xx)) 
  (setf tmp (+ x fpf)) 
  (setf tmp (- (* (+ x half) (log tmp)) tmp)) 
  (setf ser one) 
  (do ((j 0 (+ j 1)))
      ((> j 5) t)
      (declare (type fixnum j))
    (setf x (1+ x))
    (setf ser (+ ser (/ (aref cof j) x)))) 

  (setf gammln (+ tmp (log (* stp ser)))) 
  (return (the double-float gammln))))
;----------------------------------------------------------------------------

(defun factrl (n)
 (declare (type fixnum n))

 (prog ((factrl 0d0) 
        (a (make-array 33 :element-type 'double-float :initial-element 0d0))
        (ntop 0))
; (save ntop , a) 
  (declare (type (simple-array double-float (33)) a)) 
  (declare (type fixnum ntop) (type double-float factrl))

  (setq ntop 0)
  (setf (aref a 0) 1d0)

  (cond 
   ((< n 0) 
    (error " negative factorial "))
   ((<= n ntop)
    (setf factrl (aref a n)))
   ((<= n 32)
    (do ((j (+ ntop 1) (+ j 1)))
        ((> j n) t)
        (declare (type fixnum j))
      (setf (aref a j) (* j (aref a (1- j)))))
    (setf ntop n) 
    (setf factrl (aref a n)))
   (t
   (setf factrl (exp (gammln (+ n 1)))))) 

  (return (the double-float factrl))))
;(fproclaim '(special a-factln))
;(fproclaim '(type (simple-array double-float (*)) a)) 

;----------------------------------------------------------------------------
(defun bico (n k)
 (declare (type fixnum n k))
 (the double-float (exp (- (factln n) (factln k) (factln (- n k))))))
;----------------------------------------------------------------------------

(defun factln (n)
 (declare (type fixnum n))

 (prog  ((a (make-array 100 :element-type 'double-float :initial-element -1d0)) 
         (factln 0d0))
  (declare (type (simple-array double-float (100)) a))
  (declare (type double-float factln))


  (if (<= n 0) (error "negative or zero argument to factln")) 
  (cond 
   ((<= n 99) 
     (if (< (aref a n) 0d0) 
         (setf (aref a n) (gammln (dfloat (+ n 1)))))
     (setf factln (aref a n)))
   (t
   (setf factln (gammln (dfloat (+ n 1)))))) 
  
  (return (the double-float factln))))
;----------------------------------------------------------------------------

(defun beta (z w)
  (declare (type double-float z w))
  (the double-float 
   (exp
    (- (+ (funcall #'gammln z) (funcall #'gammln w))
       (funcall #'gammln (+ z w))))))
;----------------------------------------------------------------------------

(defun gammp (a x)
 (declare (type double-float a x))

 (prog ((gamser 0d0) (gammcf 0d0) (gammp 0d0))
  (declare (type double-float gamser gammcf gammp))

  (if (or (< x 0d0) (<= a 0d0)) (error " invalid arguments for gammp")) 
  (cond 
    ((< x (+ a 1d0))
     (setq gamser (gser a x)) 
     (setf gammp gamser)) 
    (t
     (setq gammcf (gcf a x)) 
     (setf gammp (- 1d0 gammcf)))) 
 
  (return (the double-float gammp))))
;----------------------------------------------------------------------------

(defun gammq (a x)
 (declare (type double-float a x))

 (prog ((gamser 0d0) (gammcf 0d0) (gammq 0d0))
  (declare (type double-float gamser gammcf gammq))

  (if (or (< x 0d0) (<= a 0d0)) (error " invalid arguments for gammq")) 
  (cond 
    ((< x (+ a 1d0))
     (setq gamser (gser a x)) 
     (setf gammq (- 1d0 gamser))) 
    (t
     (setq gammcf (gcf a x)) 
     (setf gammq gammcf))) 
 
  (return (the double-float gammq))))
;----------------------------------------------------------------------------

(defun gser (a x &key (itmax 100) (eps 3.0d-7))
 (declare (type double-float a x eps))
 (declare (type fixnum itmax))

 (prog ((gamser 0d0) (gln 0d0) (ap 0d0) 
        (del 0d0) (sum 0d0))
  (declare (type double-float gamser gln ap del sum))


  (setf gln (gammln a)) 
  (when 
   (<= x 0)  
   (if (< x 0d0) (error " invalid argument to gser "))
   (setf gamser 0d0) 
   (return (values gamser gln))) 

  (setf ap a) 
  (setf sum (/ 1d0 a)) 
  (setf del sum) 
  (do ((n 1 (+ n 1)))
      ((> n itmax) t)
      (declare (type fixnum n))
    (setf ap (+ ap 1))
    (setf del (/ (* del x) ap))
    (setf sum (+ sum del))
    (if (< (abs del) (* (abs sum) eps)) (go label1))) 

  (error " a too large , itmax too small in gser ") 
  label1 
  (setf gamser (* sum
                  (exp (+ (- x) (* a (log x)) (- gln))))) 
   
  (return (values gamser gln))))

;----------------------------------------------------------------------------

(defun gcf (a x &key (itmax 100) (eps 3.0d-7))
 (declare (type double-float a x eps))
 (declare (type fixnum itmax))

 (prog ((gammcf 0d0) (gln 0d0) (gold 0d0) (a0 0d0) (a1 0d0) 
        (b0 0d0) (b1 0d0) (fac 0d0) (an 0d0) (ana 0d0) (anf 0d0) (g 0d0))
  (declare (type double-float gln gammcf gold a0 a0 b0 b1 fac an ana anf g))

  (setf gln (gammln a)) 
  (setf gold 0d0) 
  (setf a0 1d0) 
  (setf a1 x) 
  (setf b0 0d0) 
  (setf b1 1d0) 
  (setf fac 1d0) 
  (do ((n 1 (+ n 1)))
      ((> n itmax) t)
    (setf an (dfloat n))
    (setf ana (- an a))
    (setf a0 (* (+ a1 (* a0 ana)) fac))
    (setf b0 (* (+ b1 (* b0 ana)) fac))
    (setf anf (* an fac))
    (setf a1 (+ (* x a0) (* anf a1)))
    (setf b1 (+ (* x b0) (* anf b1)))
    (when 
     (not (= a1 0d0))
     (setf fac (/ 1d0 a1))
     (setf g (* b1 fac)) 
     (if (< (abs (/ (- g gold) g)) eps) (go label1))
     (setf gold g))) 
   
  (error " a too large , itmax too small in gcf ") 
  label1 
  (setf gammcf (* (exp (+ (- x) (* a (log x)) (- gln)))
                  g)) 
   
  (return (values gammcf gln))))
;----------------------------------------------------------------------------

(defun erf (x)
  (declare (type double-float x))
  (the double-float
   (if (< x 0d0)
    (- (gammp 0.5d0 (expt x 2)))
    (gammp 0.5d0 (expt x 2)))))
;----------------------------------------------------------------------------

(defun erfc (x)
  (declare (type double-float x))
  (if (< x 0d0)
      (1+ (gammp 0.5d0 (expt x 2)))
      (gammq 0.5d0 (expt x 2)))) 
;----------------------------------------------------------------------------

(defun erfcc (x)
 (declare (type double-float x))

 (prog ((erfcc 0d0) (z 0d0) (t0 0d0))
  (declare (type double-float erfcc z t0))

  (setf z (abs x)) 
  (setf t0 (/ 1d0 (1+ (* 0.5d0 z)))) 
  (setf erfcc (* t0
                 (exp
                       (+ (+ (* (- z) z) -1.265512d0)
                          (* t0
                             (+ 1.000024d0
                                (* t0
                                   (+ 0.374092d0
                                      (* t0
                                         (+
                                          0.096784d0
                                          (*
                                           t0
                                           (+
                                            -0.186288d0
                                            (*
                                             t0
                                             (+
                                              0.278868
                                              (*
                                               t0
                                               (+
                                                -1.135204d0
                                                (*
                                                 t0
                                                 (+
                                                  1.488516d0
                                                  (*
                                                   t0
                                                   (+
                                                    -0.822152d0
                                                    (*
                                                     t0
                                                     0.170873d0))))))))))))))))))))) 
  (if (< x 0d0) (setf erfcc (- 2d0 erfcc))) 
   
  (return (the double-float erfcc))))
;----------------------------------------------------------------------------

(defun betacf (a b x &key (itmax 100) (eps 3.0d-7))
 (declare (type double-float a b x eps))
 (declare (type fixnum itmax))

 (prog ((betacf 0d0) (am 0d0) (bm 0d0) (az 0d0) 
        (qab 0d0) (qap 0d0) (qam 0d0) (em 0d0) (d 0d0) (aold 0d0) 
        (ap 0d0) (bp 0d0) (app 0d0) (bpp 0d0) (tem 0d0) (bz 0d0))
  (declare (type double-float betacf am bm az qab qap qam em d aold bz))
  (declare (type double-float ap bp app bpp tem))

  (setf am 1d0) 
  (setf bm 1d0) 
  (setf az 1d0) 
  (setf qab (+ a b)) 
  (setf qap (+ a 1d0)) 
  (setf qam (1- a)) 
  (setf bz (+ 1 (/ (* (- qab) x) qap))) 
  (do ((m 1 (+ m 1)))
      ((> m itmax) t)
    (declare (type fixnum m))
    (setf em (dfloat m))
    (setf tem (+ em em))
    (setf d (/ (* (* em (- b m)) x) (* (+ qam tem) (+ a tem))))
    (setf ap (+ az (* d am)))
    (setf bp (+ bz (* d bm)))
    (setf d (/ (* (* (* -1 (+ a em)) (+ qab em)) x) (* (+ a tem) (+ qap tem))))
    (setf app (+ ap (* d az)))
    (setf bpp (+ bp (* d bz)))
    (setf aold az)
    (setf am (/ ap bpp))
    (setf bm (/ bp bpp))
    (setf az (/ app bpp))
    (setf bz 1d0)
    (if (< (abs (- az aold)) (* eps (abs az))) (go label1))) 
  (error " a or b too big , or itmax too small ") 
  label1 
  (setf betacf az) 
  (return (the double-float betacf))))
;----------------------------------------------------------------------------

(defun betai (a b x)
 (declare (type double-float a b x))

 (prog ((bt 0d0) (betai 0d0))
  (declare (type double-float bt betai))

  (if (or (< x 0d0) (> x 1d0)) (error "bad argument x in betai")) 
  (if (or (= x 0d0) (= x 1d0)) 
   (setf bt 0d0)
   (setf bt (exp
                  (+ (+ (+ (+ (gammln (+ a b)) (- (gammln a)))
                           (- (gammln b)))
                        (* a (log x)))
                     (* b (log (- 1d0 x))))))) 

  (if (< x (/ (+ a 1d0) (+ (+ a b) 2d0))) 
    (progn
     (setf betai (/ (* bt (betacf a b x)) a))  
     (return (the double-float betai)))
    (progn
     (setf betai (+ 1d0 (/ (* (- bt) (betacf b a (- 1d0 x))) b)))
     (return (the double-float betai))))))
;----------------------------------------------------------------------------

(defun bessi (n  x)
 (declare (type fixnum n) (type double-float x))

 (prog ((iacc 0) (bigno 0d0) (bigni 0d0) (tox 0d0) (bip 0d0) 
        (bi 0d0) (m 0) (bessi 0d0)  (bim 0d0))
  (declare (type fixnum iacc m)) 
  (declare (type double-float bigno bigni tox bip bi bessi bim))

  (setq iacc 40
        bigno 1.0d10
        bigni 1.0d-10)

  (if (< n 2) (error "bad argument n in bessi")) 

  (if (= x 0d0) 
      (setf bessi 0d0) 
      (progn 
       (setf tox (/ 2.0d0 (abs x))) 
       (setf bip 0.0d0)
       (setf bi 1.0d0) 
       (setf bessi 0d0)
       (setf m (* 2 (+ n (floor (sqrt (dfloat (* iacc n)))))))
       (do ((j m (1- j)))
           ((< j 1) t)
           (declare (type fixnum j))
           (setf bim (+ bip (* (* (dfloat j) tox) bi))) 
           (setf bip bi) 
           (setf bi bim)
           (when (> (abs bi) bigno)  
                 (setf bessi (* bessi bigni))
                 (setf bi (* bi bigni)) 
                 (setf bip (* bip bigni)))
           (if (= j n) (setf bessi bip)))

      (setf bessi (/ (* bessi (bessi0 x)) bi))
      (if (and (< x 0d0) (= (mod n 2) 1)) 
          (setf bessi (- bessi)))))

  (the double-float (return bessi))))
;----------------------------------------------------------------------------

(defun bessi0 (x)
 (declare (type double-float x))

 (prog ((p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) (p6 0d0) (p7 0d0)
        (q1 0d0) (q2 0d0) (q3 0d0) (q4 0d0) (q5 0d0) (q6 0d0) (q7 0d0) 
        (q8 0d0) (q9 0d0) (y 0d0) (bessi0 0d0) (ax 0d0))
  (declare (type double-float p1 p2 p3 p4 p5 p6 p7))
  (declare (type double-float q1 q2 q3 q4 q5 q6 q7 q8 q9 y bessi0 ax)) 

(setq p1 1.0d0 p2 3.5156229d0 p3 3.0899424d0 p4 1.2067492d0 
      p5 0.2659732d0 p6 0.360768d-1 p7 0.45813d-2  
      q1 0.39894228d0 q2 0.1328592d-1 q3 0.225319d-2 q4 -0.157565d-2 
      q5 0.916281d-2 q6 -0.2057706d-1 q7 0.2635537d-1 q8 -0.1647633d-1 
      q9 0.392377d-2) 

  (if (< (abs x) 3.75d0) 
   (progn 
   (setf y (expt (/ x 3.75d0) 2))
   (setf bessi0 (+ p1
                   (* y
                      (+ p2
                         (* y
                            (+ p3
                               (* y
                                  (+ p4
                                     (* y (+ p5 (* y (+ p6 (* y p7))))))))))))))
   (progn 
   (setf ax (abs x)) 
   (setf y (/ 3.75d0 ax))
   (setf bessi0 (* (/ (exp ax) (sqrt ax))
                   (+ q1
                      (* y
                         (+ q2
                            (* y
                               (+ q3
                                  (* y
                                     (+ q4
                                        (*
                                         y
                                         (+
                                          q5
                                          (*
                                           y
                                           (+
                                            q6
                                            (*
                                             y
                                             (+
                                              q7
                                              (*
                                               y
                                               (+ q8 (* y q9))))))))))))))))))
   )) 
  (return (the double-float bessi0))))

;------------------------------------------------------------------------------
(defun bessi1 (x) 
 (declare (type double-float x))

 (prog ((p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) (p6 0d0) (p7 0d0) 
        (q1 0d0) (q2 0d0) (q3 0d0) (q4 0d0) (q5 0d0) (q6 0d0) (q7 0d0)
        (q8 0d0) (q9 0d0) (y 0d0) (bessi1 0d0) (ax 0d0))
  (declare (type double-float p1 p2 p3 p4 p5 p6 p7))
  (declare (type double-float q1 q2 q3 q4 q5 q6 q7 q8 q9 y bessi1 ax)) 

 (setq p1 0.5d0 p2 0.87890594d0 p3 0.51498869d0 p4 0.15084934d0 
      p5 0.2658733d-1 p6 0.301532d-2 p7 0.32411d-3)
 
 (setq q1 0.39894228d0 q2 -0.3988024d-1 q3 -0.362018d-2 q4 0.163801d-2 
       q5 -0.1031555d-1 q6 0.2282967d-1 q7 -0.2895312d-1 q8 0.1787654d-1 
       q9 -0.420059d-2)

 (cond 
  ((< (abs x) 3.75d0) 
   (setf y (expt (/ x 3.75d0) 2))
   (setf bessi1 (* x
                 (+ p1
                    (* y
                       (+ p2
                          (* y
                             (+ p3
                                (* y
                                   (+ p4
                                      (* y
                                         (+ p5 (* y (+ p6 (* y p7))))))))))))))
 )
  (t 
   (setf ax (abs x)) 
   (setf y (/ 3.75d0 ax))
   (setf bessi1 (* (/ (exp ax) (sqrt ax))
                 (+ q1
                    (* y
                       (+ q2
                          (* y
                             (+ q3
                                (* y
                                   (+ q4
                                      (* y
                                         (+
                                          q5
                                          (*
                                           y
                                           (+
                                            q6
                                            (*
                                             y
                                             (+
                                              q7
                                              (*
                                               y
                                               (+ q8 (* y q9))))))))))))))))))
  (if (< x 0d0) (setf bessi1 (- bessi1))))) 
(return (the double-float bessi1))
))
;----------------------------------------------------------------------------

(defun bessj (n x)
 (declare (type fixnum n))
 (declare (type double-float n))

 (prog ((iacc 0) (bigno 0d0) (bigni 0d0) (ax 0d0) (bessj 0d0) 
        (bjp 0d0) (bjm 0d0) (bj 0d0) (tox 0d0) (sum 0d0) (jsum 0) (m 0))
  (declare (type fixnum iacc jsum m))
  (declare (type double-float bigno bigni ax bessj bjp bjm bj tox sum))

  (setq iacc 40
        bigno 1.0d10
        bigni 1.d-10) 
  (if (< n 2) (error "bad argument n in bessj")) 
  (setf ax (abs x)) 
  (cond
   ((= ax 0d0) 
    (setf bessj 0d0))
   ((> ax (dfloat n))
    (setf tox (/ 2d0 ax)) 
    (setf bjm (funcall #'bessj0 ax))
    (setf bj (funcall #'bessj1 ax))

    (do ((j 1 (+ j 1)))
         ((> j (1- n)) t)
         (declare (type fixnum j))
       (setf bjp (- (* (* j tox) bj) bjm))
       (setf bjm bj)
       (setf bj bjp))

    (setf bessj bj))

   (t
    (setf tox (/ 2 ax))
    (setf m (* 2 (/ (+ n (floor (sqrt (dfloat (* iacc n))))) 2)))
    (setq bessj 0d0 jsum 0 sum 0d0  bjp 0d0 bj 1d0)

    (do ((j m (1- j)))
          ((< j 1) t)
          (declare (type fixnum j))
        (setf bjm (- (* (* j tox) bj) bjp))
        (setf bjp bj)
        (setf bj bjm)

        (when 
         (> (abs bj) bigno) 
         (setf bj (* bj bigni)) 
         (setf bjp (* bjp bigni))
         (setf bessj (* bessj bigni)) 
         (setf sum (* sum bigni)))

        (if (not (= jsum 0)) (setf sum (+ sum bj)))
        (setf jsum (- 1 jsum))
        (if (= j n) (setf bessj bjp)))

   (setf sum (- (* 2 sum) bj)) 
   (setf bessj (/ bessj sum))))

  (if (and (< x 0d0) (= (mod n 2) 1)) 
      (setf bessj (- bessj))) 
  (return (the double-float bessj))))
;----------------------------------------------------------------------------
(defun bessj0 (x)
 (declare (type double-float x)) 

 (prog ((p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) (q1 0d0) (q2 0d0) 
        (q3 0d0) (q4 0d0) (q5 0d0) (r1 0d0) (r2 0d0) (r3 0d0) (r4 0d0) 
        (r5 0d0) (r6 0d0) (s1 0d0) (s2 0d0) (s3 0d0) (s4 0d0) (s5 0d0) 
        (s6 0d0) (ax 0d0) (z 0d0) (y 0d0) (bessj0 0d0) (xx 0d0))
  (declare (type double-float y p1 p2 p3 p4 p5 q1 q2 q3 q4 q5 ax z xx))
  (declare (type double-float r1 r2 r3 r4 r5 r6 s1 s2 s3 s4 s5 s6 y bessj0)) 

  (setq p1 1.0d0 p2 -0.1098628627d-2 p3 0.2734510407d-4 
        p4 -0.2073370639d-5 p5 0.2093887211d-6)

  (setq q1 0.1562499995d-1 q2 0.1430488765d-3 q3 -0.6911147651d-5 
        q4 0.7621095161d-6 q5 -0.934945152d-7 ) 

  (setq r1 5.7568490574d10 r2 -1.3362590354d10 r3 651619640.7d0 
        r4 -1.121442418d7 r5 77392.33017d0 r6 -184.9052456d0) 

  (setq s1 5.7568490411d10 s2 1.029532985d9 s3 9.494680718d6 
        s4 59272.64852999999d0 s5 267.8532711999999d0 s6 1.0d0 ) 

  (if (< (abs x) 8d0) 
   (progn  
     (setf y (expt x 2))
     (setf bessj0 (/ (+ r1
                      (* y
                         (+ r2
                            (* y (+ r3 (* y (+ r4 (* y (+ r5 (* y r6))))))))))
                   (+ s1
                      (* y
                         (+ s2
                            (* y
                               (+ s3 (* y (+ s4 (* y (+ s5 (* y s6)))))))))))))

   (progn 
     (setf ax (abs x)) 
     (setf z (/ 8d0 ax)) 
     (setf y (expt z 2))
     (setf xx (+ ax -0.785398d0))
     (setf bessj0 (* (sqrt (/ 0.63662d0 ax))
                   (+ (* (cos xx)
                         (+ p1
                            (* y (+ p2 (* y (+ p3 (* y (+ p4 (* y p5)))))))))
                      (* (* (- z) (sin xx))
                         (+ q1
                            (* y
                               (+ q2 (* y (+ q3 (* y (+ q4 (* y q5)))))))))))))) 

   (return (the double-float bessj0))))
;----------------------------------------------------------------------------

(defun bessj1 (x)
 (declare (type double-float x))

 (prog ((y 0d0) (p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) (q1 0d0) 
        (q2 0d0) (q3 0d0) (q4 0d0) (q5 0d0) (r1 0d0) (r2 0d0) (r3 0d0) 
        (r4 0d0) (r5 0d0) (r6 0d0) (s1 0d0) (s2 0d0) (s3 0d0) (s4 0d0) 
        (s5 0d0) (s6 0d0) (bessj1 0d0) (xx 0d0) (z 0d0) (ax 0d0))
  (declare (type double-float y p1 p2 p3 p4 p5 q1 q2 q3 q4 q5)) 
  (declare (type double-float r1 r2 r3 r4 r5 r6 s1 s2 s3 s4 s5 s6))
  (declare (type double-float bessj1 ax z xx)) 

(setq r1 7.2362614232d10 r2 -7.895059235d9 r3 2.423968531d8 
      r4 -2.972611439d6 r5 15704.48259999999d0 r6 -30.16036606d0
      s1 1.44725228442d11 s2 2.300535178d9 s3 1.858330474d7 
      s4 99447.43394d0 s5 376.9991397d0 s6 1.0d0) 

(setq p1 1.0d0 p2 .183105d-2 p3 -.3516396496d-4 p4 .2457520174d-5 
      p5 -.240337019d-6 
      q1  0.04687499995d0 q2 -.2002690873d-3 q3 .8449199096d-5 
      q4 -.88228987d-6 q5 .105787412d-6) 

  (if (< (abs x) 8d0) 
   (progn  
    (setf y (expt x 2))
    (setf bessj1 (/ (* x
                      (+ r1
                         (* y
                            (+ r2
                               (* y
                                  (+ r3
                                     (* y (+ r4 (* y (+ r5 (* y r6)))))))))))
                   (+ s1
                      (* y
                         (+ s2
                            (* y
                               (+ s3 (* y (+ s4 (* y (+ s5 (* y s6)))))))))))))
   (progn 
    (setf ax (abs x)) 
    (setf z (/ 8d0 ax)) (setf y (expt z 2))
    (setf xx (- ax  2.356194d0))
    (setf bessj1 (* (* (sqrt (/ 0.63662d0 ax))
                      (+ (* (cos xx)
                            (+ p1
                               (* y
                                  (+ p2 (* y (+ p3 (* y (+ p4 (* y p5)))))))))
                         (* (* (* -1 z) (sin xx))
                            (+ q1
                               (* y
                                  (+ q2
                                     (* y (+ q3 (* y (+ q4 (* y q5)))))))))))
                   (signp 1d0 x)))))
  (return (the double-float bessj1))))
;----------------------------------------------------------------------------

(defun bessk (n x)
 (declare (type fixnum n) (type double-float x))

 (prog ((tox 0d0) (bkm 0d0) (bk 0d0) (bkp 0d0))
  (declare (type double-float tox bkm bk bkp))

  (if (< n 2) (error "bad argument n in bessk"))
  (setf tox (/ 2.0d0 x))  
  (setf bkm (bessk0 x)) 
  (setf bk (bessk1 x))
  (do ((j 1 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))

    (setf bkp (+ bkm (* (* j tox) bk))) 
    (setf bkm bk) 
    (setf bk bkp))
   (return (the double-float bk))))
;----------------------------------------------------------------------------

(defun bessk0 (x)
 (declare (type double-float x)) 

 (prog ((y 0d0) (p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) (p6 0d0) 
        (p7 0d0) (q1 0d0) (q2 0d0) (q3 0d0) (q4 0d0) (q5 0d0) (q6 0d0)
        (q7 0d0) (bessk0 0d0))
  (declare (type double-float y p1 p2 p3 p4 p5 p6 p7 q1 q2 q3 q4 q5 q6 q7 bessk0)) 

(setq p1 -0.57721566d0 p2 0.4227842d0 p3 0.23069756d0 
      p4 0.3488590d-1 p5 0.262698d-2 p6 0.10750d-3 p7 0.74d-5) 

(setq q1 1.25331414d0 q2 -0.7832358d-1 q3 0.2189568d-1 
      q4 -0.1062446d-1 q5 0.587872d-2 q6 -0.251540d-2 q7 0.53208d-3) 

  (if (<= x 2d0) 
   (progn  
    (setf y (/ (* x x) 4d0))
    (setf bessk0 (+ (* (- (log (/ x 2d0))) (funcall #'bessi0 x))
                   (+ p1
                      (* y
                         (+ p2
                            (* y
                               (+ p3
                                  (* y
                                     (+ p4
                                        (*
                                         y
                                         (+ p5 (* y (+ p6 (* y p7)))))))))))))))
   (progn 
    (setf y (/ 2d0 x))
    (setf bessk0 (* (/ (exp (- x)) (sqrt x))
                   (+ q1
                      (* y
                         (+ q2
                            (* y
                               (+ q3
                                  (* y
                                     (+ q4
                                        (*
                                         y
                                         (+ q5 (* y (+ q6 (* y q7))))))))))))))))
  (return (the double-float bessk0))))
;----------------------------------------------------------------------------

(defun bessk1 (x)
 (declare (type double-float x)) 

 (prog ((y 0d0) (p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) (p6 0d0) 
        (p7 0d0) (q1 0d0) (q2 0d0) (q3 0d0) (q4 0d0) (q5 0d0) (q6 0d0)
        (q7 0d0) (bessk1 0d0))
  (declare (type double-float y p1 p2 p3 p4 p5 p6 p7 q1 q2 q3 q4 q5 q6 q7 bessk1)) 

(setq p1 1.0d0 p2 0.15443144d0 p3 -0.67278579d0 p4 -0.18156897d0 
      p5 -0.1919402d-1 p6 -0.110404d-2 p7 -0.4686d-4) 
 
(setq q1 1.25331414d0 q2 0.23498619d0 q3 -0.3655620d-1 q4 0.1504268d-1 
      q5 -0.780353d-2 q6 0.325614d-2 q7 -0.68245d-3) 

  (if (<= x 2d0) 
   (progn  
    (setf y (/ (* x x) 4d0))
    (setf bessk1 (+ (* (log (/ x 2d0)) (funcall #'bessi1 x))
                   (* (/ 1d0 x)
                      (+ p1
                         (* y
                            (+ p2
                               (* y
                                  (+ p3
                                     (* y
                                        (+
                                         p4
                                         (*
                                          y
                                          (+
                                           p5
                                           (* y (+ p6 (* y p7))))))))))))))))
   (progn 
    (setf y (/ 2d0 x))
    (setf bessk1 (* (/ (exp (- x)) (sqrt x))
                   (+ q1
                      (* y
                         (+ q2
                            (* y
                               (+ q3
                                  (* y
                                     (+ q4
                                        (*
                                         y
                                         (+ q5 (* y (+ q6 (* y q7))))))))))))))
) )
 
  (return (the double-float bessk1))))
;----------------------------------------------------------------------------

(defun bessy (n x)
 (declare (type fixnum n) (type double-float x))

 (prog ((by 0d0) (bym 0d0) (tox 0d0) (byp 0d0))
  (declare (type double-float by bym tox byp))

  (if (< n 2) (error "bad argument n in bessy")) 
  (setf tox (/ 2d0 x)) 
  (setf by (funcall #'bessy1 x)) 
  (setf bym (funcall #'bessy0 x)) 
  (do ((j 1 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf byp (- (* (* j tox) by) bym))
    (setf bym by)
    (setf by byp)) 
  (return (the double-float by))))
;----------------------------------------------------------------------------

(defun bessy0 (x)
 (declare (type double-float x))

 (prog ((y 0d0) (p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) 
        (q1 0d0) (q2 0d0) (q3 0d0) (q4 0d0) (q5 0d0) (r1 0d0) 
        (r2 0d0) (r3 0d0) (r4 0d0) (r5 0d0) (r6 0d0) (s1 0d0) 
        (s2 0d0) (s3 0d0) (s4 0d0) (s5 0d0) (s6 0d0) (bessy0 0d0) 
        (z 0d0) (xx 0d0))
  (declare (type double-float y p1 p2 p3 p4 p5 
                                q1 q2 q3 q4 q5 
                                r1 r2 r3 r4 r5 r6 
                                s1 s2 s3 s4 s5 s6 bessy0 z xx)) 

(setq p1 1.0d0 p2 -.1098628627d-2 p3 .2734510407d-4
      p4 -.2073370639d-5 p5 .2093887211d-6 
      q1 -.1562499995d-1 q2 .1430488765d-3 q3 -.6911147651d-5 
      q4 .7621095161d-6 q5 -.934945152d-7) 

(setq r1 -2.957821389d9 r2 7.062834065d9 r3 -5.123598036d8 r4 1.087988129d7 
      r5 -86327.92756999999d0 r6 228.4622732999999d0
      s1 4.0076544269d10 s2 7.452499648d8 s3 7.189466438d6 
      s4 47447.26469999999d0  s5 226.1030244d0 s6 1.0d0) 

  (if (< x 8) 
   (progn  
    (setf y (expt x 2))
    (setf bessy0 (+ (/ (+ r1
                         (* y
                            (+ r2
                               (* y
                                  (+ r3 (* y (+ r4 (* y (+ r5 (* y r6))))))))))
                      (+ s1
                         (* y
                            (+ s2
                               (* y
                                  (+ s3
                                     (* y (+ s4 (* y (+ s5 (* y s6)))))))))))
                   (* (* 0.63662d0 (funcall #'bessj0 x)) (log x)))))
   (progn 
    (setf z (/ 8d0 x)) (setf y (expt z 2))
    (setf xx (- x 0.785398d0))
    (setf bessy0 (* (sqrt (/ 0.63662d0 x))
                   (+ (* (sin xx)
                         (+ p1
                            (* y (+ p2 (* y (+ p3 (* y (+ p4 (* y p5)))))))))
                      (* (* z (cos xx))
                         (+ q1
                            (* y
                               (+ q2 (* y (+ q3 (* y (+ q4 (* y q5))))))))))))))
   
  (return (the double-float bessy0))))
;----------------------------------------------------------------------------

(defun bessy1 (x)
 (declare (type double-float x))

 (prog ((y 0d0) (p1 0d0) (p2 0d0) (p3 0d0) (p4 0d0) (p5 0d0) (q1 0d0) 
        (q2 0d0) (q3 0d0) (q4 0d0) (q5 0d0) (r1 0d0) (r2 0d0) (r3 0d0) 
        (r4 0d0) (r5 0d0) (r6 0d0) (s1 0d0) (s2 0d0) (s3 0d0) (s4 0d0) 
        (s5 0d0) (s6 0d0) (s7 0d0) (bessy1 0d0) (z 0d0) (xx 0d0))
  (declare (type double-float y p1 p2 p3 p4 p5 
                                q1 q2 q3 q4 q5 
                                r1 r2 r3 r4 r5 r6 
                                s1 s2 s3 s4 s5 s6 s7 bessy1 z xx)) 


(setq p1 1.0d0 p2 .183105d-2 p3 -.3516396496d-4 p4 .2457520174d-5 
      p5 -.240337019d-6 
      q1 0.04687499995d0 q2 -.2002690873d-3 q3 .8449199096d-5 
      q4 -.88228987d-6 q5 .105787412d-6) 

(setq r1 -4.900604943d12 r2 1.27527439d12 r3 -0.515344d11 
      r4 7.349264551d8 r5 -4.237922726d6 r6 8511.937934999999d0 
      s1 2.49958057d13 s2 4.244419664d11 s3 3.733650367d9 
      s4 2.245904002d7 s5 102042.6049999999d0 
      s6 354.9632884999999d0 s7 1.0d0) 

  (if (< x 8d0) 
   (progn  
    (setf y (expt x 2))
    (setf bessy1 (+ (/ (* x
                         (+ r1
                            (* y
                               (+ r2
                                  (* y
                                     (+ r3
                                        (*
                                         y
                                         (+ r4 (* y (+ r5 (* y r6)))))))))))
                      (+ s1
                         (* y
                            (+ s2
                               (* y
                                  (+ s3
                                     (* y
                                        (+
                                         s4
                                         (*
                                          y
                                          (+ s5 (* y (+ s6 (* y s7)))))))))))))
                   (* 0.63662d0
                      (+ (* (funcall #'bessj1 x) (log x)) (/ -1d0 x))))))
   (progn 
    (setf z (/ 8d0 x)) 
    (setf y (expt z 2))
    (setf xx (- x 2.356194d0))
    (setf bessy1 (* (sqrt (/ 0.63662d0 x))
                   (+ (* (sin xx)
                         (+ p1
                            (* y (+ p2 (* y (+ p3 (* y (+ p4 (* y p5)))))))))
                      (* (* z (cos xx))
                         (+ q1
                            (* y
                               (+ q2 (* y (+ q3 (* y (+ q4 (* y q5)))))))))))))) 
    (return (the double-float bessy1))))
;----------------------------------------------------------------------------

(defun plgndr (l m x)
 (declare (type fixnum l m))
 (declare (type double-float x))

 (prog ((pmm 0d0) (somx2 0d0) (pmmp1 0d0) (pll 0d0) (fact 0d0) (plgndr 0d0))
  (declare (type double-float pmm somx2 pmmp1 pll fact plgndr))

  (if (or (< m 0) (> m l) (> (abs x) 1)) (error " bad arguments to plgndr ")) 
  (setf pmm 1d0) 
  (when 
   (> m 0)
   (setf somx2 (sqrt (* (- 1d0 x) (1+ x)))) 
   (setf fact 1d0)
   (do ((i 1 (+ i 1)))
       ((> i m) t)
       (declare (type fixnum i))
     (setf pmm (* (- pmm) fact somx2))
     (setf fact (+ fact 2d0)))) 

  (cond 
   ((= l m) 
    (setf plgndr pmm))
   (t 
    (setf pmmp1 (* (* x (dfloat (+ (* 2 m) 1))) pmm))
    (cond 
     ((= l (+ m 1)) 
      (setf plgndr pmmp1))
     (t
      (do ((ll (+ m 2) (+ ll 1)))
          ((> ll l) t)
          (declare (type fixnum ll))
        (setf pll (/ (- (* (* x (dfloat (1- (* 2 ll)))) pmmp1)
                        (* (1- (+ ll m)) pmm))
                     (dfloat (- ll m))))
        (setf pmm pmmp1)
        (setf pmmp1 pll))
      (setf plgndr pll))))) 
   
  (return (the double-float plgndr))))
;----------------------------------------------------------------------------

(defun el2 (x qqc aa bb)
 (declare (type double-float  x qqc aa bb))

 (prog ((ca 0d0) (cb 0d0) (l 0) (a 0d0) (b 0d0) (c 0d0) (d 0d0) 
        (p 0d0) (z 0d0) (eye 0d0) (y 0d0) (f 0d0) (g 0d0) (em 0d0)
        (el2 0d0) (e 0d0) (qc 0d0))
  (declare (type double-float ca cb a b c d p z eye y f g em el2 e ggc qc))
  (declare (type fixnum l))

  (setq ca 3.0d-4 cb 1d-9) 

  (cond
   ((= x 0d0)
    (setf el2 0d0))
   ((not (= qqc 0d0))
    (setf qc qqc) 
    (setf a aa) 
    (setf b bb) 
    (setf c (expt x 2)) 
    (setf d (1+ c))
    (setf p (sqrt (/ (+ 1d0 (* (expt qc 2) c)) d))) 
    (setf d (/ x d))
    (setf c (/ d (* 2d0 p))) 
    (setf z (+ a (- b))) 
    (setf eye a)
    (setf a (* 0.5d0 (+ b a))) 
    (setf y (abs (/ 1d0 x))) 
    (setf f 0d0) (setf l 0)
    (setf em 1d0) 
    (setf qc (abs qc)) 
    (tagbody
label1 
     (setf b (+ (* eye qc) b))
     (setf e (* em qc)) 
     (setf g (/ e p)) 
     (setf d (+ (* f g) d)) 
     (setf f c)
     (setf eye a) 
     (setf p (+ g p)) 
     (setf c (* 0.5d0 (+ (/ d p) c))) 
     (setf g em)
     (setf em (+ qc em))
     (setf a (* 0.5d0 (+ (/ b em) a)))
     (setf y (+ (/ (- e) y) y)) 
     (if (= y 0d0) (setf y (* (sqrt e) cb)))
     (when (> (abs (+ g (- qc))) (* ca g))
      (setf qc (* (sqrt e) 2d0)) (setf l (+ l l)) 
      (if (< y 0d0) (setf l (1+ l)))
      (go label1)))
    (if (< y 0d0) (setf l (1+ l)))
    (setf e (/ (* (+ (atan (/ em y)) (dfloat (* pi l))) a) em))
    (if (< x 0d0) (setf e (- e))) 
    (setf el2 (+ e (* c z))))
   (t  
    (error " failure in el2 "))) 

  (return (the double-float el2))))
;----------------------------------------------------------------------------

(defun cel (qqc pp aa bb)
 (declare (type double-float qqc pp aa bb))

 (prog ((ca 0d0) (pio2 0d0) (a 0d0) (b 0d0) (p 0d0) (e 0d0) 
        (em 0d0) (g 0d0) (f 0d0) (q 0d0) (cel 0d0) (qc 0d0))
  (declare (type double-float ca pio2 a b p e em g f q cel qc))

  (setq ca 3.0d-4
        pio2 1.5707963268d0) 
  (if (= qqc 0d0) (error "failure in cel")) 
  (setf qc (abs qqc)) 
  (setf a aa) 
  (setf b bb) 
  (setf p pp) 
  (setf e qc) 
  (setf em 1d0) 
  (cond
   ((> p 0d0) 
    (setf p (sqrt p)) 
    (setf b (/ b p)))
   (t 
    (setf f (* qc qc)) 
    (setf q (- 1d0 f))
    (setf g (- 1d0 p)) 
    (setf f (- f p))
    (setf q (* q (+ b (* (- a) p)))) 
    (setf p (sqrt (/ f g)))
    (setf a (/ (- a b) g))
    (setf b (+ (/ (- q) (* (* g g) p)) (* a p))))) 
  label1 
  (setf f a) 
  (setf a (+ a (/ b p))) 
  (setf g (/ e p)) 
  (setf b (+ b (* f g))) 
  (setf b (+ b b)) 
  (setf p (+ g p)) 
  (setf g em) 
  (setf em (+ qc em)) 
  (when (> (abs (- g qc)) (* g ca)) 
   (setf qc (sqrt e)) 
   (setf qc (+ qc qc)) 
   (setf e (* qc em))
   (go label1)) 
  (setf cel (/ (* pio2 (+ b (* a em))) (* em (+ em p)))) 
  (return (the double-float cel))))
;----------------------------------------------------------------------------

(defun sncndn (uu emmc &key (ca 3.0d-4))
 (declare (type double-float uu emmc ca))

 (prog ((sn 0d0) (cn 0d0) (dn 0d0)
        (em (make-array 13 :element-type 'double-float :initial-element 0d0))
        (en (make-array 13 :element-type 'double-float :initial-element 0d0))
        (a 0d0)
        (c 0d0) (emc 0d0) (u 0d0) (bo nil) (d 0d0) (l 0) (b 0d0))

  (declare (type double-float sn cn dn a c emc u d b))
  (declare (type fixnum l))
  (declare (type symbol bo))
  (declare (type (simple-array double-float (13)) em)) 
  (declare (type (simple-array double-float (13)) en)) 

  (setf emc emmc) 
  (setf u uu) 
  (cond 
   ((not (= emc 0d0))
    (setf bo (< emc 0d0))
    (when 
     bo  
     (setf d (1- emc))
     (setf emc (/ (- emc) d)) 
     (setf d (sqrt d)) (setf u (* d u)))
    (setf a 1d0) 
    (setf dn 1d0)

    (tagbody

     (do ((i 0 (+ i 1)))
         ((> i 12) t)
         (declare (type fixnum i))
       (setf l i)
       (setf (aref em i) a)
       (setf emc (sqrt emc))
       (setf (aref en i) emc)
       (setf c (* 0.5d0 (+ a emc)))
       (if (<= (abs (- a emc)) (* ca a)) (go label1))
       (setf emc (* a emc))
       (setf a c))

 label1)
    (setf u (* c u)) 
    (setf sn (sin u)) 
    (setf cn (cos u))
    (tagbody
     (if (= sn 0d0) (go label2)) 
     (setf a (/ cn sn)) (setf c (* a c))

     (do ((ii l (1- ii)))
         ((< ii 0) t)
         (declare (type fixnum ii))
       (setf b (aref em ii))
       (setf a (* c a))
       (setf c (* dn c))
       (setf dn (/ (+ (aref en ii) a) (+ b a)))
       (setf a (/ c b)))

     (setf a (/ 1d0 (sqrt (+ (expt c 2) 1d0))))
     (if 
      (< sn 0d0)
      (setf sn (- a))
      (setf sn a))
     (setf cn (* c sn)) 
 label2)
    (when 
     bo 
     (setf a dn) 
     (setf dn cn) 
     (setf cn a)
     (setf sn (/ sn d))))
   (t 
    (setf cn (/ 1d0 (cosh u))) 
    (setf dn cn)
    (setf sn (tanh u)))) 
   
  (return (values sn cn dn))))

;------------------------------------------------------------------------------
; end of nr06.l
