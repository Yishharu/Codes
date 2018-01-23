; nr07.l
; Random numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;Modified by Ken Olum for Common Lisp, April 1996;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package "USER")
; functions:
;	ran0: random deviates, improve an existing generator
;	ran1: random deviates, uniform
;	ran2: random deviates, uniform
;	ran3: random deviates, uniform subtractive method
;	expdev: random deviates, exponential
;	gasdev: random deviates, normally distributed Box-Muller method
;	gamdev: random deviates, gamma-law distribution
;	poidev: random deviates, Poisson distributed
;	bnldev: random deviates, binomial distributed
;	irbit1: generate a random bit sequence
;	irbit2: generate a random bit sequence
;	ran4: random deviates, uniform using Data Encryption
;	des: encryption
;	ks: encryption key standard
;	cyfun: cyfer function for the Data Encryption Standard
;-----------------------------------------------------------------------------
 
(defvar *random-states-list* nil)
(defun ran (iseed) 
  (declare (type fixnum iseed))
  (if (< iseed 0) (setq *random-state* (get-random-state (- iseed))))
  (random 1d0))

(defun get-random-state (iseed)
 (declare (type fixnum iseed))
 (let ((statei nil))
   (setq statei (cadr (assoc iseed *random-states-list* :test #'equal)))
   (if (null statei) 
       (setq *random-states-list* 
            (cons (list iseed 
                       (setq statei (princ-to-string (make-random-state t))))
                  *random-states-list*)) )
   (read-from-string statei)))


(defvar ran0 
 (let 
   ((iff 0) 
    (y 0d0)
    (v (make-array 97 :element-type 'double-float :initial-element 0d0))
    (iseed 0))
   #'(lambda (idum)
       (declare (type fixnum idum))

       (prog ((ran0 0d0) (j 0)) ;(dum 0d0)
        (declare (type fixnum j))
        (declare (type double-float ran0))
  (when 
   (or (< idum 0) (= iff 0))
   (setf iff 1)
   (setf iseed (abs idum)); (setf idum 1)
   (if (< idum 0) (ran idum))
   (do ((j 1 (+ j 1)))
       ((> j 97) t)
       (declare (type fixnum j))
     ;(setf dum (ran iseed))
)
   (do ((j 1 (+ j 1)))
       ((> j 97) t)
       (declare (type fixnum j))
     (setf (aref v (1- j)) (ran iseed)))
   (setf y (ran iseed))) 

  (setf j (1+ (floor (* 97 y)))) 
  (if (or (> j 97) (< j 1)) (error " error in ran0 ")) 
  (setf y (aref v (1- j))) 
  (setf ran0 y) 
  (setf (aref v (1- j)) (ran iseed)) 
   
  (return (the double-float ran0))))))

;----------------------------------------------------------------------------

(defvar ran1 

(let 
 ((iff 0)
  (ix1 0)
  (ix2 0)
  (ix3 0)
  (r (make-array 97 :element-type 'double-float :initial-element 0d0)))
 (declare (type fixnum iff ix1 ix2 ix3))
 (declare (type (simple-array double-float (*)) r))

#'(lambda (idum)
   (declare (type fixnum idum))

   (prog ((m1 0) (ia1 0) (ic1 0) (m2 0) (ia2 0) (ic2 0) (rm1 0d0) (rm2 0d0)
          (m3 0) (ia3 0) (ic3 0) (j 0) (ran1 0d0))
    (declare (type fixnum m1 ia1 ic1 m2 ia2 ic2 m3 ia3 ic3 j))
    (declare (type double-float rm1 rm2 ran1))

  (setq m1 259200
        ia1 7141
        ic1 54773
        rm1 3.8580247d-6) 
  (setq m2 134456
        ia2 8121
        ic2 28411
        rm2 7.4373773d-6) 
  (setq m3 243000
        ia3 4561
        ic3 51349) 

  (when 
   (or (< idum 0) (= iff 0)) 
   (setf iff 1)
   (setf ix1 (mod (- ic1 idum) m1))
   (setf ix1 (mod (+ (* ia1 ix1) ic1) m1)) 
   (setf ix2 (mod ix1 m2))
   (setf ix1 (mod (+ (* ia1 ix1) ic1) m1)) 
   (setf ix3 (mod ix1 m3))

   (do ((j 1 (1+ j)))
       ((> j 97) t)
       (declare (type fixnum j))
     (setf ix1 (mod (+ (* ia1 ix1) ic1) m1))
     (setf ix2 (mod (+ (* ia2 ix2) ic2) m2))
     (setf (aref r (1- j)) (* (+ (dfloat ix1) (* (dfloat ix2) rm2)) rm1)))
   (setf idum 1)) 

  (setf ix1 (mod (+ (* ia1 ix1) ic1) m1)) 
  (setf ix2 (mod (+ (* ia2 ix2) ic2) m2)) 
  (setf ix3 (mod (+ (* ia3 ix3) ic3) m3)) 
  (setf j (+ 1 (floor (/ (* 97 ix3) m3)))) 
  (if (or (> j 97) (< j 1)) (error " error in ran1 ")) 
  (setf ran1 (aref r (1- j))) 
  (setf (aref r (1- j)) (* (+ (dfloat ix1) (* (dfloat ix2) rm2)) rm1)) 
   
  (return (the double-float ran1))))))

;----------------------------------------------------------------------------
(defvar ran2 
(let 
  ((iff 0)
   (iy 0)
   (ir (make-array 97 :element-type 'fixnum :initial-element 0)))

 #'(lambda (idum)
    (declare (type fixnum idum))

    (prog ((ran2 0d0) (m 0) (ia 0) (ic 0) (rm 0d0) (j 0))
      (declare (type fixnum m ia ic j))
      (declare (type double-float rm ran2))

  (setq m 714025
        ia 1366
        ic 150889
        rm 1.4005112d-6) 
 
  (when 
   (or (< idum 0) (= iff 0))
   (setf iff 1)
   (setf idum (mod (- ic idum) m))
   (do ((j 1 (+ j 1)))
       ((> j 97) t)
       (declare (type fixnum j))
     (setf idum (mod (+ (* ia idum) ic) m))
     (setf (aref ir (1- j)) idum))

   (setf idum (mod (+ (* ia idum) ic) m)) (setf iy idum)) 

  (setf j (+ 1 (floor (/ (* 97 iy) m)))) 
  (if (or (> j 97) (< j 1)) (error " error in ran2 ")) 
  (setf iy (aref ir (1- j))) 
  (setf ran2 (* iy rm)) 
  (setf idum (mod (+ (* ia idum) ic) m)) 
  (setf (aref ir (1- j)) idum) 
  
  (return (the double-float ran2))))))

;-----------------------------------------------------------------------------
(defvar ran3 
 (let
   ((iff 0)
    (inext 0)
    (inextp 0)
    (ma (make-array 55 :element-type 'integer :initial-element 0)))
   (declare (type (simple-array integer (*)) ma)) 
   (declare (type integer iff inext inextp))

#'(lambda (idum)
    (declare (type fixnum idum))

    (prog ((ran3 0d0) (mbig 0) (mseed 0) (mz 0) 
           (fac 0d0) (ii 0) (mj 0) (mk 0))
     (declare (type integer mseed mz ii mj mk))
     (declare (type integer mbig))
     (declare (type double-float fac ran3))
 
  (setq mbig 1000000000
        mseed 161803398
        mz 0
        fac 1.0d-9) 

  (when 
   (or (< idum 0) (= iff 0))
   (setf iff 1)
   (setf mj (- mseed (abs idum))) 
   (setf mj (mod mj mbig))
   (setf (aref ma 54) mj) 
   (setf mk 1)
   (do ((i 1 (+ i 1)))
       ((> i 54) t)
       (declare (type fixnum i))
     (setf ii (mod (* 21 i) 55))
     (setf (aref ma (1- ii)) mk)
     (setf mk (- mj mk))
     (if (< mk mz) (setf mk (+ mk mbig)))
     (setf mj (aref ma (1- ii))))
   (do ((k 1 (+ k 1)))
       ((> k 4) t)
       (declare (type fixnum k))
     (do ((i 1 (1+ i)))
         ((> i 55) t)
         (declare (type fixnum i))
       (setf (aref ma (1- i)) (- (aref ma (1- i))
                            (aref ma (mod (+ i 30) 55))))
       (if (< (aref ma (1- i)) mz) 
           (setf (aref ma (1- i)) (+ (aref ma (1- i)) mbig)))))

   (setf inext 0) 
   (setf inextp 31) 
   (setf idum 1)) 
  (setf inext (1+ inext)) 
  (if (= inext 56) (setf inext 1)) 
  (setf inextp (1+ inextp)) 
  (if (= inextp 56) (setf inextp 1)) 
  (setf mj (- (aref ma (1- inext)) (aref ma (1- inextp)))) 
  (if (< mj mz) (setf mj (+ mj mbig))) 
  (setf (aref ma (1- inext)) mj) 
  (setf ran3 (* mj fac)) 
   
  (return (the double-float ran3))))))

;-----------------------------------------------------------------------------
(defun expdev (idum)
 (declare (type fixnum idum))

 (prog ((dum 0d0) (expdev 0d0))
  (declare (type double-float dum expdev))

label1 
  (setf dum (funcall ran1 idum)) 
  (if (= dum 0d0) (go label1)) 
  (setf expdev (* -1d0 (log dum))) 
  (return (the double-float expdev))))

;-----------------------------------------------------------------------------
(defun gasdev (idum)
 (declare (type fixnum idum))

 (prog ((iset 0) (gasdev 0d0) (v1 0d0) (v2 0d0) (r 0d0) (fac 0d0) (gset 0d0)) 
  (declare (type fixnum iset)) 
  (declare (type double-float gasdev v1 v2 r fac gset))

  (setq iset 0) 
  (cond 
   ((= iset 0) 
    (tagbody
     label1
     (setf v1 (1- (* 2 (funcall ran1 idum))))
     (setf v2 (1- (* 2 (funcall ran1 idum))))
     (setf r (+ (expt v1 2) (expt v2 2))) 
     (if (or (>= r 1d0) (= r 0d0)) (go label1)))
    (setf fac (sqrt (/ (* -2d0 (log r)) r))) 
    (setf gset (* v1 fac))
    (setf gasdev (* v2 fac)) 
    (setf iset 1)) 
   (t 
    (setf gasdev gset)
    (setf iset 0)))
  
  (return (the double-float gasdev))))

;------------------------------------------------------------------------------
(defun gamdev (ia idum)
 (declare (type fixnum ia idum))

 (prog ((gamdev 0d0) (x 0d0) (v1 0d0) (v2 0d0) (y 0d0) (am 0d0) (s 0d0) (e 0d0))
  (declare (type double-float gamdev x v1 v2 y am s e))

  (if (< ia 1) (error " ia in gamdev too small ")) 
  (cond 
   ((< ia 6)
    (setf x 1d0)
    (do ((j 1 (+ j 1)))
        ((> j ia) t)
        (declare (type fixnum j))
      (setf x (* x (funcall ran1 idum))))
    (setf x (- (log x)))) 
  (t
   (tagbody
 label1
    (setf v1 (1- (* 2d0 (funcall ran1 idum))))
    (setf v2 (1- (* 2d0 (funcall ran1 idum)))) 
    (if (> (+ (* v1 v1) (* v2 v2))  1d0) (go label1)) 
    (setf y (/ v2 v1))
    (setf am (dfloat (1- ia))) 
    (setf s (sqrt (1+ (* 2d0 am))))
    (setf x (+ (* s y) am)) 
    (if (<= x 0d0) (go label1))
    (setf e (* (1+ (expt y 2))
               (exp (+ (* am (log (/ x am))) (* (- s) y)))))
    (if (> (funcall ran1 idum) e) (go label1)))))

  (setf gamdev x) 
  (return (the double-float gamdev))))

;-----------------------------------------------------------------------------

(defvar poidev 

(let ((oldm -1d0) (y 0d0) (sq 0d0) (alxm 0d0))
  (declare (type double-float oldm y sq alxm))

#'(lambda (xm idum)
 (declare (type double-float xm))
 (declare (type fixnum idum))

 (prog ((t0 0d0) (g 0d0)  (em 0d0) (poidev 0d0))
  (declare (type double-float  t0 g  em poidev))
 
  (cond 
   ((< xm 12)
    (when 
     (not (= xm 12d0))
     (setf oldm xm)
     (setf g (exp (- xm))))
     (setf em -1d0) 
     (setf t0 1d0) 
     (tagbody
      label2 
      (setf em (1+ em))
      (setf t0 (* t0 (funcall ran1 idum)))
      (if (> t0 g) (go label2))))

  (t 
   (when 
    (not (= xm oldm))
    (setf oldm xm)
    (setf sq (sqrt (* 2d0 xm))) 
    (setf alxm (log xm))
    (setf g (- (* xm alxm) (gammln (1+ xm)))))
   (tagbody
    label1 
    (setf y (tan (* pi (funcall ran1 idum)))) 
    (setf em (+ (* sq y) xm))
    (if (< em 0d0) (go label1)) 
    (setf em (floor em))
    (setf t0 (* (* 0.9d0 (1+ (expt y 2)))
                (exp
                    (- (- (* em alxm) (gammln (+ em 1)))
                        g))))
    (if (> (funcall ran1 idum) t0) (go label1))))) 
  (setf poidev em) 
   
  (return poidev)))))

;-----------------------------------------------------------------------------

(defvar bnldev 

(let ((nold -1) (pold -1d0) (pc 0d0) (en 0d0) (oldg 0d0) (plog 0d0) (pclog 0d0))
   (declare (type fixnum nold))
   (declare (type double-float pold pc en oldg plog pclog))

#'(lambda (pp n idum)
 (declare (type double-float pp) (type fixnum n idum))

 (prog ((p 0d0) (am 0d0) (t0 0d0) (bnldev1 0d0) (g 0d0) (j 0) (em 0d0)
         (y 0d0) (sq 0d0))
  (declare  (type double-float p am t0 bnldev1 g em y sq))
  (declare (type fixnum j))

  (if (<= pp 0.5d0) 
     (setf p pp)
     (setf p (- 1d0 pp))) 

  (setf am (dfloat (* n p))) 

  (cond
    ((< n 25) 
     (setf bnldev1 0d0)
     (do ((j 1 (+ j 1)))
         ((> j n) t)
         (declare (type fixnum j))
       (if (< (funcall ran1 idum) p) (setf bnldev1 (1+ bnldev1)))))
    ((< am 1d0)
     (tagbody
      (setf g (exp (- am))) 
      (setf t0 1d0)
      (do ((jj 0 (+ jj 1)))
          ((> jj n) t)
          (declare (type fixnum jj))
        (setf t0 (* t0 (funcall ran1 idum)))
        (when (< t0 g) (setq j jj) (go label1)))
      (setf j n) 
      label1 
      (setf bnldev1 (dfloat j))))
    (t
     (when 
       (not (= n nold))
       (setf en (dfloat n))
       (setf oldg (gammln (1+ en))) 
       (setf nold n))
     (when
      (not (= p pold))
      (setf pc (- 1d0 p)) 
      (setf plog (log p))
      (setf pclog (log pc)) 
      (setf pold p))
     (setf sq (sqrt (* (* 2d0 am) pc))) 
     (tagbody
      label2
      (setf y (tan (* pi (funcall ran1 idum)))) 
      (setf em (+ (* sq y) am)) 
      (if (or (< em 0d0) (>= em (1+ en))) (go label2)) 
      (setf em (dfloat (floor em)))
      (setf t0 (* (* (* 1.2d0 sq) (+ 1d0 (expt y 2)))
                 (exp
                     (+ oldg
                        (- (gammln (1+ em)))
                        (- (gammln (1+ (- en em))))
                        (* em plog)
                        (* (- en em) pclog)))))

      (if (> (funcall ran1 idum) t0) (go label2)))
     (setf bnldev1 em)))

  (if (not (= p pp)) 
      (setf bnldev1 (- (dfloat n) bnldev1))) 
  (return (the double-float bnldev1))))))

;-----------------------------------------------------------------------------

(defvar irbit1 

 (let ((iseed 4543456))
  (declare (type fixnum iseed))

#'(lambda ()

 (prog ((newbit nil) (ib1 0) (irbit1 0));  (ib2 0) (ib5 0) (ib18 0))
  (declare (type fixnum irbit1)); ib1 ib2 ib5 ib18)) 
;  (declare (type symbol newbit))

  (setq ib1 1)
;        ib2 2
;        ib5 16
;        ib18 131072) 
  (setf newbit (logbitp 18 iseed))
  (if (logbitp 5 iseed) (setf newbit (not newbit))) 
  (if (logbitp 2 iseed) (setf newbit (not newbit))) 
  (if (logbitp 1 iseed) (setf newbit (not newbit))) 
  (setf irbit1 0) 
  (setf iseed (ash iseed 1)) 
  (when 
    newbit
    (setf irbit1 1)
    (setf iseed (logior iseed  ib1)))
  (return (the fixnum irbit1))))))


;------------------------------------------------------------------------------
(defvar irbit2 

(let ((iseed 23432345))

 #'(lambda ()
 (declare (type fixnum iseed))

 (prog ((ib1 0) (ib2 0) (ib5 0) (mask 0) (irbit 0))
  (declare (type fixnum ib1 ib2 ib5 mask irbit))

  (setq ib1 1
        ib2 2
        ib5 16
       ; ib18 131072
        mask (+ ib1 ib2 ib5))
  (cond 
   ((logbitp 18 iseed)
    (setf iseed (logior (ash (logxor iseed mask) 1)  ib1))

    (setf irbit 1))
   (t 
    (setf iseed  (logand (ash iseed 1)  (lognot ib1)))
    (setf irbit 0))) 
  (return (the fixnum irbit))))))

;------------------------------------------------------------------------------
(defvar ran4 

 (let
  ((iff 0)
   (inp (make-array 64 :element-type 'fixnum :initial-element 0))
   (key (make-array 64 :element-type 'fixnum :initial-element 0))
   (pow (make-array 65 :element-type 'double-float :initial-element 0d0))
   (newkey 0))
  (declare (type (simple-array fixnum (*)) inp)) 
  (declare (type (simple-array fixnum (*)) key)) 
  (declare (type (simple-array double-float (*)) pow)) 

#'(lambda (idum)
   (declare (type fixnum idum))

    (prog ((ran4 0d0) (im 0) (ia 0) (ic 0) (nacc 0) 
           (jot (make-array 64 :element-type 'fixnum :initial-element 0)) 
           (isav 0))
     (declare (type double-float ran4))
     (declare (type (simple-array fixnum (*)) jot)) 
     (declare (type fixnum im ia ic nacc isav))

  (setq im 11979
        ia 430
        ic 2531
        nacc 24) 

  (when 
   (or (< idum 0) (= iff 0)) 
   (setf iff 1)
   (setf idum (mod idum im)) 
   (if (< idum 0) (setf idum (+ idum im)))
   (setf (aref pow 0) 0.5d0)
   (do ((j 0 (+ j 1)))
       ((> j 63) t)
       (declare (type fixnum j))
     (setf idum (mod (+ (* idum ia) ic) im))
     (setf (aref key j) (floor (/ (* 2 idum) im)))
     (setf (aref inp j) (mod (floor (/ (* 4 idum) im)) 2))
     (setf (aref pow (+ j 1)) (* 0.5d0 (aref pow j))))
   (setf newkey 1)) 
  (setf isav (aref inp 63)) 
  (when 
   (not (= isav 0))
   (setf (aref inp 4) (1+ (- (aref inp 4))))
   (setf (aref inp 3) (1+ (- (aref inp 3))))
   (setf (aref inp 1) (1+ (- (aref inp 1))))) 
  (do ((j 63 (1- j)))
      ((< j 1) t)
      (declare (type fixnum j))
    (setf (aref inp j) (aref inp (1- j)))) 

  (setf (aref inp 0) isav) 
  (setq jot (des inp key newkey 0)) 
  (setf ran4 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- nacc)) t)
      (declare (type fixnum j))
    (if (not (= (aref jot j) 0d0))
        (setf ran4 (+ ran4 (aref pow j))))) 
   
  (return (the double-float ran4))))))

;-----------------------------------------------------------------------------
(defun des (input key newkey isw)
 (declare (type (simple-array fixnum (*)) input)) 
 (declare (type (simple-array fixnum (*)) key)) 
 (declare (type fixnum newkey isw))

 (prog  (
  (ip (make-array 64 :element-type 'fixnum :initial-contents
  '(58 50 42 34 26 18 10 2 60 52 44 36 28 20
   12 4 62 54 46 38 30 22 14 6 64 56 48 40 32 
   24 16 8 57 49 41 33 25 17 9 1 59 51 43 35 27
   19 11 3 61 53 45 37 29 21 13 5 63 55 47 39 
   31 23 15 7))) 

  (ipm (make-array 64 :element-type 'fixnum :initial-contents
  '(40 8 48 16 56 24 64 32 39 7 47 15 55 23
   63 31 38 6 46 14 54 22 62 30 37 5 45 13 53 
   21 61 29 36 4 44 12 52 20 60 28 35 3 43 11 51
   19 59 27 34 2 42 10 50 18 58 26 33 1 41 9 49
   17 57 25))) 
  (jotput (make-array 64 :element-type 'fixnum :initial-element 0))
  (itmp (make-array 64 :element-type 'fixnum :initial-element 0))
  (icf (make-array 32 :element-type 'fixnum :initial-element 0))
  (reti (make-array 48 :element-type 'fixnum :initial-element 0))
  (retj (make-array 32 :element-type 'fixnum :initial-element 0))
  (kns (make-array '(48 16) :element-type 'fixnum :initial-element 0))
  (ic 0) (ii 0))

  (declare (type (simple-array fixnum (*)) jotput)) 
  (declare (type (simple-array fixnum (*)) itmp reti retj)) ; reti 48 retj 32
  (declare (type (simple-array fixnum (*)) ip)) 
  (declare (type (simple-array fixnum (*)) ipm)) 
  (declare (type (simple-array fixnum (*)) icf)) 
  (declare (type (simple-array fixnum (* *)) kns))
  (declare (type fixnum ic ii))
 

  (when 
   (not (= newkey 0)) 
   (setf newkey 0)
   (do ((i 1 (+ i 1)))
       ((> i 16) t)
      (declare (type fixnum i))
      (setq reti (ks key i))
      (do ((j 0 (1+ j))) 
          ((> j 47) t)
         (declare (type fixnum j))
         (setf (aref kns j (1- i)) (aref reti j)))))

  
  (do ((j 1 (+ j 1)))
      ((> j 64) t)
      (declare (type fixnum i))
    (setf (aref itmp (1- j)) (aref input (1- (aref ip (1- j)))))) 

  (do ((i 1 (+ i 1)))
      ((> i 16) t)
      (declare (type fixnum i))
    (setf ii i)
    (if (= isw 1) (setf ii (- 17 i)))

    (do ((j 0 (1+ j)))
        ((> j 31) t)
       (declare (type fixnum j))
       (setf (aref retj j) (aref itmp (+ j 32))))
    (do ((j 0 (1+ j)))
        ((> j 47) t)
       (declare (type fixnum j))
       (setf (aref reti j) (aref kns j (1- ii))))
    (setq icf (cyfun retj reti))

    (do ((j 0 (+ j 1)))
        ((> j 31) t)
        (declare (type fixnum j))
      (setf ic (+ (aref icf j) (aref itmp j)))
      (setf (aref itmp j) (aref itmp (+ j 32)))
      (setf (aref itmp (+ j 32)) (logand ic 1))))
  (do ((j 0 (+ j 1)))
      ((> j 31) t)
      (declare (type fixnum j))
    (setf ic (aref itmp j))
    (setf (aref itmp j) (aref itmp (+ j 32)))
    (setf (aref itmp (+ j 32)) ic))
  (do ((j 1 (+ j 1)))
      ((> j 64) t)
      (declare (type fixnum j))
    (setf (aref jotput (1- j)) (aref itmp (1- (aref ipm (1- j))))))
 
  (return jotput)))

;-----------------------------------------------------------------------------
(declaim (special icd))
(declaim (type (simple-array fixnum (56)) icd))
(setq icd (make-array 56 :element-type 'fixnum :initial-element 0))
 
(defun ks (key n)
 (declare (type fixnum n))
 (declare (type (simple-array fixnum (*)) key)) 

 (prog (
  (ipc1 (make-array 56 :element-type 'fixnum :initial-contents 
    '(57 49 41 33 25 17 9 1 58 50 42 34 26
     18 10 2 59 51 43 35 27 19 11 3 60 52 44 36 63
     55 47 39 31 23 15 7 62 54 46 38 30 22 14 6
     61 53 45 37 29 21 13 5 28 20 12 4)))
  (ipc2 (make-array 48 :element-type 'fixnum :initial-contents  
    '(14 17 11 24 1 5 3 28 15 6 21 10 23 19
     12 4 26 8 16 7 27 20 13 2 41 52 31 37 47 55
     30 40 51 45 33 48 44 49 39 56 34 53 46 42 50 
     36 29 32)))
  (kn (make-array 48 :element-type 'fixnum :initial-element 0))
  (it 0) (ic 0) (id 0))

  (declare (type (simple-array fixnum (*)) kn)) 
  (declare (type (simple-array fixnum (*)) ipc1)) 
  (declare (type (simple-array fixnum (*)) ipc2)) 
  (declare (type fixnum it ic id))


  (when 
   (= n 1)
   (do ((j 1 (1+ j)))
       ((> j 56) t)
       (declare (type fixnum j))
     (setf (aref icd (1- j)) (aref key (1- (aref ipc1 (1- j))))))) 

  (setf it 2) 
  (if (or (= n 1) (= n 2) (= n 9) (= n 16)) (setf it 1)) 

  (do ((i 1 (1+ i)))
      ((> i it) t)
      (declare (type fixnum i))
    (setf ic (aref icd 0))
    (setf id (aref icd 28))
    (do ((j 0 (1+ j)))
        ((> j 26) t)
        (declare (type fixnum j))
      (setf (aref icd j) (aref icd (+ j 1)))
      (setf (aref icd (+ j 28)) (aref icd (+ j 29))))
    (setf (aref icd 27) ic)
    (setf (aref icd 55) id)) 

  (do ((j 1 (+ j 1)))
      ((> j 48) t)
      (declare (type fixnum j))
    (setf (aref kn (1- j)) (aref icd (1- (aref ipc2 (1- j)))))) 
  
  (return kn)))

;-----------------------------------------------------------------------------
(defvar is_list
'(((14 4 13 1 2 15 11 8 3 10 6 12 5 9 0 7)
  (0 15 7 4 14 2 13 1 10 6 12 11 9 5 3 8)
  (4 1 14 8 13 6 2 11 15 12 9 7 3 10 5 0)
  (15 12 8 2 4 9 1 7 5 11 3 14 10 0 6 13))
 ((15 1 8 14 6 11 3 4 9 7 2 13 12 0 5 10)
  (3 13 4 7 15 2 8 14 12 0 1 10 6 9 11 5)
  (0 14 7 11 10 4 13 1 5 8 12 6 9 3 2 15)
  (13 8 10 1 3 15 4 2 11 6 7 12 0 5 14 9))
 ((10 0 9 14 6 3 15 5 1 13 12 7 11 4 2 8)
  (13 7 0 9 3 4 6 10 2 8 5 14 12 11 15 1)
  (13 6 4 9 8 15 3 0 11 1 2 12 5 10 14 7)
  (1 10 13 0 6 9 8 7 4 15 14 3 11 5 2 12))
 ((7 13 14 3 0 6 9 10 1 2 8 5 11 12 4 15)
  (13 8 11 5 6 15 0 3 4 7 2 12 1 10 14 9)
  (10 6 9 0 12 11 7 13 15 1 3 14 5 2 8 4)
  (3 15 0 6 10 1 13 8 9 4 5 11 12 7 2 14))
 ((2 12 4 1 7 10 11 6 8 5 3 15 13 0 14 9)
  (14 11 2 12 4 7 13 1 5 0 15 10 3 9 8 6)
  (4 2 1 11 10 13 7 8 15 9 12 5 6 3 0 14)
  (11 8 12 7 1 14 2 13 6 15 0 9 10 4 5 3))
 ((12 1 10 15 9 2 6 8 0 13 3 4 14 7 5 11)
  (10 15 4 2 7 12 9 5 6 1 13 14 0 11 3 8)
  (9 14 15 5 2 8 12 3 7 0 4 10 1 13 11 6)
  (4 3 2 12 9 5 15 10 11 14 1 7 6 0 8 13))
 ((4 11 2 14 15 0 8 13 3 12 9 7 5 10 6 1)
  (13 0 11 7 4 9 1 10 14 3 5 12 2 15 8 6)
  (1 4 11 13 12 3 7 14 10 15 6 8 0 5 9 2)
  (6 11 13 8 1 4 10 7 9 5 0 15 14 2 3 12))
 ((13 2 8 4 6 15 11 1 10 9 3 14 5 0 12 7)
  (1 15 13 8 10 3 7 4 12 5 6 11 0 14 9 2)
  (7 11 4 1 9 12 14 2 0 6 10 13 15 3 5 8)
  (2 1 14 7 4 10 8 13 15 12 9 0 3 5 6 11))) )

(defun cyfun (ir k)
 (declare (type (simple-array fixnum (*)) ir)) 
 (declare (type (simple-array fixnum (*)) k))
 
 (prog (
  (ie (make-array 48 :element-type 'fixnum :initial-element 0))
  (itmp (make-array 32 :element-type 'fixnum :initial-element 0))

  (iet (make-array 48 :element-type 'fixnum :initial-contents 
   '(32 1 2 3 4 5 4 5 6 7 8 9 8 9 10 11
   12 13 12 13 14 15 16 17 16 17 18 19 20 21 20 
   21 22 23 24 25 24 25 26 27 28 29 28 29 30 31 
   32 1)))
 
  (ip (make-array 32 :element-type 'fixnum :initial-contents 
   '(16 7 20 21 29 12 28 17 1 15 23 26 5 18 
   31 10 2 8 24 14 32 27 3 9 19 13 30 6 22 11 4
   25))) 
  (iout (make-array 32 :element-type 'fixnum :initial-element 0))
  (ibin (make-array '(16 4) :element-type 'fixnum :initial-contents
    '((0 0 0 0) (0 0 0 1) (0 0 1 0) (0 0 1 1) (0 1 0 0) (0 1 0 1) 
      (0 1 1 0) (0 1 1 1) (1 0 0 0) (1 0 0 1) (1 0 1 0) (1 0 1 1) 
      (1 1 0 0) (1 1 0 1) (1 1 1 0) (1 1 1 1))))
  (is (make-array '(8 4 16) :element-type 'fixnum :initial-contents
       is_list))
  (i 0)  (kk 0) (iss 0) (icol 0) (irow 0) (j 0))

  (declare (type (simple-array fixnum (*)) iout)) 
  (declare (type (simple-array fixnum (*)) ie)) 
  (declare (type (simple-array fixnum (*)) iet)) 
  (declare (type (simple-array fixnum (*)) ip)) 
  (declare (type (simple-array fixnum (*)) itmp)) 
  (declare (type (simple-array fixnum (* * *)) is)) 
  (declare (type (simple-array fixnum (* *)) ibin)) 
  (declare (type fixnum j irow   icol iss))
  (declare (type cons is_list)) 
  (declare (special is_list))
  (declare (ignore i))
  
  (do ((j 1 (+ j 1)))
      ((> j 48) t)
    (setf (aref ie (1- j)) 
          (logand (+ (aref ir (1- (aref iet (1- j)))) (aref k (1- j))) 1))) 

  (do ((jj 1 (+ jj 1)))
      ((> jj 8) t)
    (setf j (- (* 6 jj) 5))
    (setf irow (logior (aref ie (+ j 4)) (ash (aref ie (1- j)) 1)))
    (setf icol (logior (aref ie (+ j 3))
                     (ash
                           (logior (aref ie (+ j 2))
                                 (ash
                                       (logior (aref ie (+ j 1))
                                             (ash (aref ie j) 1))
                                       1))
                           1)))
    (setf iss (aref is (1- jj) irow icol))
    (setf kk (* 4 (1- jj)))
    (do ((ki 1 (+ ki 1)))
        ((> ki 4) t)
      (setf (aref itmp (1- (+ kk ki))) (aref ibin iss (1- ki))))) 

  (do ((j 1 (+ j 1)))
      ((> j 32) t)
    (setf (aref iout (1- j)) (aref itmp (1- (aref ip (1- j)))))) 

  (return iout)))

;-----------------------------------------------------------------------------
; end of nr07.l
