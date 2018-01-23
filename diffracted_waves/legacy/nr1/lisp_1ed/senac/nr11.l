; nr11.l
; Eigensystems
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	jacobi: eigenvalues and vectors of a symmetric matrix
;	eigsrt: sorts eigenvectors into order by eigenvalue
;	tred2: Householder reduction of a real symmetric matrix
;	tqli: eigenvalues and vectors of a symmetric tridiagonal matrix
;	balanc: balance a non-symmetric matrix
;	elmhes: reduce a general matrix to Hessenberg form
;	hqr: eigenvalues of a Hessenberg matrix
;------------------------------------------------------------------------------

(defun jacobi (a)
 (declare (type (simple-array double-float (* *)) a)) 

 (prog* ((nrot 0)
  (n (array-dimension a 0))
  (d (make-array n :element-type 'double-float :initial-element 0d0))
  (v 
    (make-array (list n n) :element-type 'double-float :initial-element 0d0))
  (b (make-array n :element-type 'double-float :initial-element 0d0))
  (z (make-array n :element-type 'double-float :initial-element 0d0))
  (sm 0d0) (tresh 0d0) (g 0d0) (h 0d0) (t0 0d0) 
  (theta 0d0) (c 0d0) (s 0d0) (tau 0d0))

  (declare (type (simple-array double-float (*)) d)) 
  (declare (type (simple-array double-float (* *)) v)) 
  (declare (type (simple-array double-float (*)) b)) 
  (declare (type (simple-array double-float (*)) z))
  (declare (type fixnum n nrot))
  (declare (type double-float sm tresh g h t0 theta c s tau))
  


  (do ((ip 1 (+ ip 1)))
      ((> ip n) t)
      (declare (type fixnum ip))
    (do ((iq 1 (+ iq 1)))
        ((> iq n) t)
        (declare (type fixnum iq))
      (fset (fref  v ip iq) 0d0))
    (fset (fref v ip ip) 1d0)) 
  (do ((ip 1 (+ ip 1)))
      ((> ip n) t)
      (declare (type fixnum ip))
    (fset (fref b ip) (fref a ip ip))
    (fset (fref d ip) (fref b ip))
    (fset (fref z ip) 0d0)) 
  (setf nrot 0) 
  (do ((i 1 (+ i 1)))
      ((> i 50) t)
      (declare (type fixnum i))
    (setf sm 0d0)
    (do ((ip 1 (+ ip 1)))
        ((> ip (+ n (- 1))) t)
        (declare (type fixnum ip))
      (do ((iq (+ ip 1) (+ iq 1)))
          ((> iq n) t)
          (declare (type fixnum iq))
        (setf sm (+ sm (abs (fref a ip iq))))))
    
    (if (= sm 0d0) (go end))
    (if (< i 4) 
        (setf tresh (/ (* 0.2d0 sm) (dfloat (expt n 2))))
        (setf tresh 0d0))
    (do ((ip 1 (+ ip 1)))
        ((> ip (+ n (- 1))) t)
        (declare (type fixnum ip))
      (do ((iq (+ ip 1) (+ iq 1)))
          ((> iq n) t)
          (declare (type fixnum iq))
        (setf g (* 100d0 (abs (fref a ip iq))))
        (cond 
         ((and (> i 4)
              (= (+ (abs (fref d ip)) g) (abs (fref d ip)))
              (= (+ (abs (fref d iq)) g) (abs (fref d iq))))
           (fset (fref a ip iq) 0d0))
         ((> (abs (fref a ip iq)) tresh)            
          (setf h (+ (fref d iq) (- (fref d ip))))

          (cond 
           ((= (+ (abs h) g) (abs h))
            (setf t0 (/ (fref a ip iq) h)))
           (t
            (setf theta (/ (* 0.5d0 h) (fref a ip iq)))
           (setf t0 (/ 1d0 (+ (abs theta) (sqrt (1+ (expt theta 2))))))
           (if (< theta 0d0) (setf t0 (- t0)))))

          (setf c (/ 1d0 (sqrt (+ 1d0 (expt t0 2))))) (setf s (* t0 c))
          (setf tau (/ s (1+ c))) (setf h (* t0 (fref a ip iq)))
          (fset (fref z ip) (+ (fref z ip) (- h)))
          (fset (fref z iq) (+ (fref z iq) h))
          (fset (fref d ip) (+ (fref d ip) (- h)))
          (fset (fref d iq) (+ (fref d iq) h)) (fset (fref a ip iq) 0d0)
          (do ((j 1 (+ j 1)))
              ((> j (+ ip (- 1))) t)
              (declare (type fixnum j))
            (setf g (fref a j ip))
            (setf h (fref a j iq))
            (fset (fref a j ip) (+ g (* (- s) (+ h (* g tau)))))
            (fset (fref a j iq) (+ h (* s (+ g (* (- h) tau))))))
          (do ((j (+ ip 1) (+ j 1)))
              ((> j (+ iq (- 1))) t)
              (declare (type fixnum j))
            (setf g (fref a ip j))
            (setf h (fref a j iq))
            (fset (fref a ip j) (+ g (* (- s) (+ h (* g tau)))))
            (fset (fref a j iq) (+ h (* s (+ g (* (- h) tau))))))
          (do ((j (+ iq 1) (+ j 1)))
              ((> j n) t)
              (declare (type fixnum j))
            (setf g (fref a ip j))
            (setf h (fref a iq j))
            (fset (fref a ip j) (+ g (* (- s) (+ h (* g tau)))))
            (fset (fref a iq j) (+ h (* s (+ g (* (- h) tau))))))
          (do ((j 1 (+ j 1)))
              ((> j n) t)
              (declare (type fixnum j))
            (setf g (fref v j ip))
            (setf h (fref v j iq))
            (fset (fref v j ip) (+ g (* (- s) (+ h (* g tau)))))
            (fset (fref v j iq) (+ h (* s (+ g (* (- h) tau))))))
          (setf nrot (+ nrot 1))))))
    (do ((ip 1 (+ ip 1)))
        ((> ip n) t)
        (declare (type fixnum ip))
      (fset (fref b ip) (+ (fref b ip) (fref z ip)))
      (fset (fref d ip) (fref b ip))
      (fset (fref z ip) 0d0))) 
  (error "jacobi should not reach this point") 
end
  (return (values d v nrot))))

;------------------------------------------------------------------------------

(defun eigsrt (d v)
 (declare (type (simple-array double-float (*)) d)) 
 (declare (type (simple-array double-float (* *)) v))

 (prog ((k 0) (n 0) (p 0d0))
  (declare (type fixnum k n))
  (declare (type double-float p))

  (setq n (array-dimension d 0))
   
  (do ((i 1 (+ i 1)))
      ((> i (1- n)) t)
      (declare (type fixnum i))
    (setf k i)
    (setf p (aref  d (1- i)))
    (do ((j (+ i 1) (+ j 1)))
        ((> j n) t)
        (declare (type fixnum j))
      (when (>= (aref d (1- j)) p) 
            (setf k j)
            (setf p (aref d (1- j)))))

    (when (not (= k 1))
     (setf (aref d (1- k)) (aref d (1- i))) 
     (setf (aref d (1- i)) p)
     (do ((j 1 (+ j 1)))
         ((> j n) t)
         (declare (type fixnum j))
       (setf p (aref v (1- j) (1- i)))
       (setf (aref v (1- j) (1- i)) (aref v (1- j) (1- k)))
       (setf (aref v (1- j) (1- k)) p)))) 
  
  (return (values d v))))

;------------------------------------------------------------------------------
(defun tred2 (a &key (eigenvectors t))
 (declare (type (simple-array double-float (* *)) a)) 
 (declare (type symbol eigenvectors))

 (prog* (
  (n (array-dimension a 0))
  (d (make-array n :element-type 'double-float :initial-element 0d0))
  (e (make-array n :element-type 'double-float :initial-element 0d0))
  (l 0) (h 0d0) 
  (scale 0d0) (f 0d0) (g 0d0) (hh 0d0))

  (declare (type (simple-array double-float (*)) d)) 
  (declare (type (simple-array double-float (*)) e)) 
  (declare (type fixnum n l))
  (declare (type double-float h scale f g hh))


  (do ((i n (1- i)))
      ((< i 2) t)
      (declare (type fixnum i))
    (setf l (1- i))
    (setf h 0d0)
    (setf scale 0d0)
    (cond 
     ((> l 1)
      (do ((k 1 (+ k 1)))
          ((> k l) t)
          (declare (type fixnum l))
        (setf scale (+ scale (abs (fref a i k)))))
      (cond 
       ((= scale 0d0)
        (fset (fref e i) (fref a i l)))
       (t
        (do ((k 1 (+ k 1)))
            ((> k l) t)
            (declare (type fixnum k))
          (fset (fref a i k) (/ (fref a i k) scale))
          (setf h (+ h (expt (fref a i k) 2))))
        (setf f (fref a i l)) (setf g (- (signp (sqrt h) f)))
        (fset (fref e i) (* scale g)) (setf h (+ h (* (- f) g)))
        (fset (fref a i l) (+ f (- g))) (setf f 0d0)
        (do ((j 1 (+ j 1)))
            ((> j l) t)
            (declare (type fixnum j))
          (if eigenvectors (fset (fref a j i) (/ (fref a i j) h)))
          (setf g 0d0)
          (do ((k 1 (+ k 1)))
              ((> k j) t)
              (declare (type fixnum k))
            (setf g (+ g (* (fref a j k) (fref a i k)))))
          (do ((k (+ j 1) (+ k 1)))
              ((> k l) t)
              (declare (type fixnum k))
            (setf g (+ g (* (fref a k j) (fref a i k)))))
          (fset (fref e j) (/ g h))
          (setf f (+ f (* (fref e j) (fref a i j)))))
        (setf hh (/ f (+ h h)))
        (do ((j 1 (+ j 1)))
            ((> j l) t)
            (declare (type fixnum j))
          (setf f (fref a i j))
          (setf g (+ (fref e j) (* (- hh) f)))
          (fset (fref e j) g)
          (do ((k 1 (+ k 1)))
              ((> k j) t)
              (declare (type fixnum k))
            (fset (fref a j k) (+ (+ (fref a j k) (* (- f) (fref e k)))
                                 (* (- g) (fref a i k)))))))))
      (t
       (fset (fref e i) (fref a i l))))

    (fset (fref d i) h)) 

  (if eigenvectors (fset (fref d 1) 0d0))
  (fset (fref e 1) 0d0) 
  (do ((i 1 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))
    (when eigenvectors
     (setf l (+ i (- 1)))
     (when 
      (not (= (fref d i) 0d0))
      (do ((j 1 (+ j 1)))
          ((> j l) t)
          (declare (type fixnum j))
        (setf g 0d0)
        (do ((k 1 (+ k 1)))
            ((> k l) t)
            (declare (type fixnum k))
          (setf g (+ g (* (fref a i k) (fref a k j)))))
        (do ((k 1 (+ k 1)))
            ((> k l) t)
            (declare (type fixnum k))
          (fset (fref a k j) (+ (fref a k j) (* (- g) (fref a k i))))))))
     
    (fset (fref d i) (fref a i i))
    (when eigenvectors
     (fset (fref a i i) 1d0)
     (do ((j 1 (+ j 1)))
         ((> j l) t)
         (declare (type fixnum j))
       (fset (fref a i j) 0d0)
       (fset (fref a j i) 0d0)))) 
  
  (return (values a d e))))

;------------------------------------------------------------------------------

(defun tqli (d e z &key (eigenvectors t))
 (declare (type (simple-array double-float (*)) d)) 
 (declare (type symbol eigenvectors))
 (declare (type (simple-array double-float (*)) e)) 
 (declare (type (simple-array double-float (* *)) z)) 

 (prog ((n 0) (m 0) (iter 0) (f 0d0) (s 0d0) (c 0d0) 
        (b 0d0) (r 0d0) (g 0d0) (dd 0d0) (p 0d0))
  (declare (type fixnum n m iter))
  (declare (type double-float f s c b r g dd p))

  (setq n (array-dimension d 0))
  (do ((i 2 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))
    (fset (fref e (+ i (- 1))) (fref e i))) 
  (fset (fref e n) 0d0) 
  (do ((l 1 (+ l 1)))
      ((> l n) t)
      (declare (type fixnum l))
    (setf iter 0)
    label1
    (do ((mm l (+ mm 1)))
        ((> mm (+ n (- 1))) t)
        (declare (type fixnum mm))
      (setf dd (+ (abs (fref d mm)) (abs (fref d (+ mm 1)))))
      (setq m mm)
      (if (= (+ (abs (fref e mm)) dd) dd) (go label2)))
    (setf m n)
    label2
    (when (not (= m l))
     (if (= iter 30) (error "too many iterations in tqli")) 
     (setf iter (+ iter 1))
     (setf g (/ (+ (fref d (+ l 1)) (- (fref d l))) (* 2d0 (fref e l))))
     (setf r (sqrt (+ (expt g 2) 1d0)))
     (setf g (+ (+ (fref d m) (- (fref d l)))
                (/ (fref e l) (+ g (signp r g)))))
     (setf s 1d0) (setf c 1d0) (setf p 0d0)
     (do ((i (+ m (- 1)) (+ i (- 1))))
         ((< i l) t)
         (declare (type fixnum i))
       (setf f (* s (fref e i)))
       (setf b (* c (fref e i)))
       (cond 
        ((>= (abs f) (abs g))
         (setf c (/ g f))
         (setf r (sqrt (+ (expt c 2) 1d0))) 
         (fset (fref e (+ i 1)) (* f r))
         (setf s (/ 1 r)) (setf c (* c s)) )
        (t 
         (setf s (/ f g))
         (setf r (sqrt (+ (expt s 2) 1d0))) 
         (fset (fref e (+ i 1)) (* g r))
         (setf c (/ 1 r)) (setf s (* s c))))

       (setf g (+ (fref d (+ i 1)) (- p)))
       (setf r (+ (* (+ (fref d i) (- g)) s) (* (* 2 c) b)))
       (setf p (* s r))
       (fset (fref d (+ i 1)) (+ g p))
       (setf g (+ (* c r) (- b)))
       (when eigenvectors
        (do ((k 1 (+ k 1)))
            ((> k n) t)
            (declare (type fixnum k))
          (setf f (fref z k (+ i 1)))
          (fset (fref z k (+ i 1)) (+ (* s (fref z k i)) (* c f)))
          (fset (fref z k i) (+ (* c (fref z k i)) (* (- s) f))))))
     (fset (fref d l) (+ (fref d l) (- p))) (fset (fref e l) g)
     (fset (fref e m) 0d0)
     (go label1))) 
  
  (return (values d z))))

;------------------------------------------------------------------------------

(defun balanc (a &key (radix 2d0))
 (declare (type (simple-array double-float (* *)) a))
 (declare (type double-float radix))

 (prog ((n 0) (sqrdx 0d0) (c 0d0) (r 0d0) (last 0) (f 0d0)
        (g 0d0) (s 0d0))
  (declare (type fixnum n last))
  (declare (type double-float sqrdx c r f g s))

  (setq sqrdx (* radix radix))
  (setq n (array-dimension a 0))
label1
  (setf last 1)
  (do ((i 1 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))
   (setf c 0d0)
   (setf r 0d0)
   (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (when (not (= j i)) 
     (setf c (+ c (abs (fref a j i))))
     (setf r (+ r (abs (fref a i j))))))

   (when (and (not (= c 0d0)) (not (= r 0d0)))
    (setf g (/ r radix))
    (setf f 1d0)
    (setf s (+ c r))

(tagbody label2

    (when (< c g)
     (setf f (* f radix))
     (setf c (* c sqrdx))
     (go label2)))

    (setf g (* r radix))
(tagbody    label3
    (when (> c g)
     (setf f (/ f radix))
     (setf c (/ c sqrdx))
     (go label3)))

    (when (< (/ (+ c r) f) (* 0.95d0 s))
     (setf last 0)
     (setf g (/ 1d0 f))
     (do ((j 1 (+ j 1)))
       ((> j n) t)
       (declare (type fixnum j))
      (fset (fref a i j) (* (fref a i j) g)))

     (do ((j 1 (+ j 1)))
       ((> j n) t)
       (declare (type fixnum j))
     (fset (fref a j i) (* (fref a j i) f))))))
  
  (if (= last 0) (go label1))
 
  (return a)))
;-----------------------------------------------------------------------------

(defun elmhes (a)
 (declare (type (simple-array double-float (* *)) a))

 (prog ((n 0) (y 0d0) (x 0d0) (i 0)) 
  (declare (type fixnum n i) (type double-float y x))
  (setq n (array-dimension a 0))

  (do ((m 2 (+ m 1)))
      ((>  m (1- n)) t)
      (declare (type fixnum m))
    (setf x 0d0)
    (setf i m)
    (do ((j m (+ j 1)))
        ((> j n) t)
        (declare (type fixnum j))
      (when (> (abs (fref a j (1- m))) (abs x))
            (setf x (fref a j (1- m))) 
            (setf i j)))

    (when (not (= i m))
     (do ((j (1- m) (+ j 1)))
         ((> j n) t)
         (declare (type fixnum j))
       (setf y (fref a i j))
       (fset (fref a i j) (fref a m j))
       (fset (fref a m j) y))

     (do ((j 1 (+ j 1)))
         ((> j n) t)
         (declare (type fixnum j))
       (setf y (fref a j i))
       (fset (fref a j i) (fref a j m))
       (fset (fref a j m) y)))

    (when (not (= x 0d0))
     (do ((i (1+ m) (+ i 1)))
         ((> i n) t)
         (declare (type fixnum i))
      (setf y (fref a i (1- m)))
       (when (not (= y 0d0))
        (setf y (/ y x))
        (fset (fref a i (1- m)) y)
        (do ((j m (+ j 1)))
            ((> j n) t)
            (declare (type fixnum j))
          (fset (fref a i j) (+ (fref a i j) (* (- y) (fref a m j)))))
        (do ((j 1 (+ j 1)))
            ((> j n) t)
            (declare (type fixnum j))
          (fset (fref a j m) (+ (fref a j m) (* y (fref a j i))))))))) 
   
  (return a)))

;------------------------------------------------------------------------------

(defun hqr (a)
 (declare (type (simple-array double-float (* *)) a)) 

 (prog* (
  (n (array-dimension a 0))
  (wr (make-array n :element-type 'double-float :initial-element 0d0))
  (wi (make-array n :element-type 'double-float :initial-element 0d0))
  (t0 0d0) (nn 0) (s 0d0) 
  (anorm 0d0) (its 0) (l 0) (x 0d0) (y 0d0) (m 0)
  (w 0d0) (p 0d0) (q 0d0) (z 0d0) (r 0d0) (u 0d0) (v 0d0))

  (declare (type (simple-array double-float (*)) wr)) 
  (declare (type (simple-array double-float (*)) wi)) 
  (declare (type fixnum n nn its l m))
  (declare (type double-float t0 s anorm x y w p q z r u v))


  (setf anorm (abs (fref a 1 1))) 
  (do ((i 2 (+ i 1)))
      ((> i n) t)
      (declare (type fixnum i))
    (do ((j (1- i) (1+ j)))
        ((> j n) t)
        (declare (type fixnum j))
      (setf anorm (+ anorm (abs (fref a i j)))))) 
  (setf nn n) 
  (setf t0 0d0) 
  label1 
  (when 
   (>= nn 1)  
(tagbody
   (setf its 0) 
   label2
   (do ((ll nn (1- ll)))
       ((< ll 2) t)
       (declare (type fixnum ll))
       (setq l ll)
     (setf s (+ (abs (fref a (1- ll) (1- ll)))
                (abs (fref a ll ll))))
     (if (= s 0d0) (setf s anorm))
     (if (= (+ (abs (fref a ll  (1- ll))) s) s) (go label3)))
   (setf l 1) 
   label3 
   (setf x (fref a nn nn))
   (cond 
    ((= l nn)  
     (fset (fref wr nn) (+ x t0))
     (fset (fref wi nn) 0d0) 
     (setf nn (1- nn))) 
    (t
     (setf y (fref a (1- nn) (1- nn)))
     (setf w (* (fref a nn (1- nn)) (fref a (1- nn) nn)))
     (cond 
      ((= l (1- nn))
      (setf p (* 0.5d0 (- y x))) (setf q (+ (expt p 2) w))
      (setf z (sqrt (abs q))) (setf x (+ x t0))
      (cond 
       ((>= q 0d0) 
        (setf z (+ p (signp z p)))
        (fset (fref wr nn) (+ x z)) 
        (fset (fref wr (1- nn)) (fref wr nn))
        (if (not (= z 0d0)) (fset (fref wr nn) (+ x (/ (- w) z))))
        (fset (fref wi nn) 0d0) 
        (fset (fref wi (1- nn)) 0d0))
       (t 
        (fset (fref wr nn) (+ x p))
        (fset (fref wr (1- nn)) (fref wr nn)) 
        (fset (fref wi nn) z)
        (fset (fref wi (1- nn)) (- z))))
      (setf nn (- nn 2))) 

(t (if (= its 30) (error " too many iterations in hqr "))

     (when 
      (or (= its 10) (= its 20))
      (setf t0 (+ t0 x))

      (do ((i 1 (+ i 1)))
          ((> i nn) t)
          (declare (type fixnum i))
        (fset (fref a i i) (+ (fref a i i) (- x))))

      (setf s (+ (abs (fref a nn (1- nn)))
                 (abs (fref a (1- nn) (- nn 2)))))
      (setf x (* 0.75d0 s)) (setf y x) (setf w (* -0.4375d0 (expt s 2))))

     (setf its (+ its 1))
(tagbody
     (do ((mm (- nn 2) (1- mm)))
         ((< mm l) t)
         (declare (type fixnum mm))
       (setq m mm)
       (setf z (fref a mm mm))
       (setf r (- x z))
       (setf s (- y z))
       (setf p (+ (/ (- (* r s) w) (fref a (+ mm 1) mm))
                  (fref a mm (+ mm 1))))
       (setf q (- (- (- (fref a (+ mm 1) (+ mm 1)) z) r) s))
       (setf r (fref a (+ mm 2) (+ mm 1)))
       (setf s (+ (+ (abs p) (abs q)) (abs r)))
       (setf p (/ p s))
       (setf q (/ q s))
       (setf r (/ r s))
       (if (= mm l) (go label4))
       (setf u (* (abs (fref a mm (1- mm))) (+ (abs q) (abs r))))
       (setf v (* (abs p)
                  (+ (+ (abs (fref a (1- mm) (1- mm))) (abs z))
                     (abs (fref a (+ mm 1) (+ mm 1))))))
       (if (= (+ u  v) v) (go label4)))

     label4)
     (do ((i (+ m 2) (+ i 1)))
         ((> i nn) t)
         (declare (type fixnum i))
       (fset (fref a i (+ i -2)) 0d0)
       (if (not (= i (+ 2 m))) (fset (fref a i (+ i -3)) 0d0)))

     (do ((k m (+ k 1)))
         ((> k (1- nn)) t)
         (declare (type fixnum k))
       (when 
        (not (= k m))
        (setf p (fref a k (1- k)))
        (setf q (fref a (+ k 1) (1- k))) (setf r 0d0)
        (if (not (= k (1- nn)))
          (setf r (fref a (+ k 2) (1- k))))
        (setf x (+ (+ (abs p) (abs q)) (abs r)))
        (when 
         (not (= x 0d0))
         (setf p (/ p x))
         (setf q (/ q x)) 
         (setf r (/ r x))))
       (setf s (signp (sqrt (+ (+ (expt p 2) (expt q 2)) (expt r 2))) p))

       (when 
        (not (= s 0d0))
        (if 
         (= k m) 
         (if 
           (not (= l m))
           (fset (fref a k (1- k)) (- (fref a k (1- k)))))
         (fset (fref a k (1- k)) (* (- s) x)))

        (setf p (+ p s)) 
        (setf x (/ p s)) 
        (setf y (/ q s)) 
        (setf z (/ r s))
        (setf q (/ q p)) 
        (setf r (/ r p))

        (do ((j k (+ j 1)))
            ((> j nn) t)
            (declare (type fixnum j))
          (setf p (+ (fref a k j) (* q (fref a (+ k 1) j))))
          (when 
           (not (= k (1- nn)))
           (setf p (+ p (* r (fref a (+ k 2) j))))
           (fset (fref a (+ k 2) j) (- (fref a (+ k 2) j) (* p z))))
          (fset (fref a (+ k 1) j) (- (fref a (+ k 1) j) (* p y)))
          (fset (fref a k j) (- (fref a k j) (* p x))))

        (do ((i l (+ i 1)))
            ((> i (min nn (+ k 3))) t)
            (declare (type fixnum i))
          (setf p (+ (* x (fref a i k)) (* y (fref a i (+ k 1)))))
          (when 
           (not (= k (1- nn)))
           (setf p (+ p (* z (fref a i (+ k 2)))))
           (fset (fref a i (+ k 2)) (- (fref a i (+ k 2)) (* p r))))
          (fset (fref a i (+ k 1)) (- (fref a i (+ k 1)) (* p q)))
          (fset (fref a i k) (- (fref a i k) p)))))
     (go label2)))
   ))
   (go label1))) 
   
  (return (values wr wi))))
;------------------------------------------------------------------------------
; end of nr11.l

