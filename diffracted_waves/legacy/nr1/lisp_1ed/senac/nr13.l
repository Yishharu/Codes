; nr13.l
; Statistical description of data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	moment: calculate the moments of a data set
;	mdian1: calcuate the median of a data set by sorting
;	mdian2: calcuate the median of a data set iteratively
;	ttest: Student's t-test for the difference of means
;	avevar: calcuate the mean and variance of a data set
;	tutest: Student's t-test with unequal variances
;	tptest: Student's t-test with paired data
;	ftest: F-test for difference of variances
;	chsone: chi-square test for difference between data and model
;	chstwo: chi-square test for difference between two data sets
;	ksone: Kolmorgorov-Smirnov test of data against model
;	kstwo: Kolmorgorov-Smirnov test of two data sets
;	probks: Kolmorgorov-Smirnov probability function
;	cntab1: contingency table analysis using chi-square
;	cntab2: contingency table analysis using entropy measure
;	pearsn: Pearson's correlation between two data sets
;	spear: Spearman's rank correlation between two data sets
;	crank: replace array elements by their ranks
;	kendl1: Kendal's tau correlation between two data sets
;	kendl2: contingency table analysis using Kendall's tau
;	smooft: smooth data using FFT
;-------------------------------------------------------------------------------
(defun moment (data )
 (declare (type (simple-array double-float (*)) data)) 

 (prog ((n 0) (ave 0d0) (adev 0d0) (sdev 0d0) (var 0d0) 
        (skew 0d0) (curt 0d0) (s 0d0) (nf 0d0) (p 0d0))
  (declare (type fixnum n))
  (declare (type double-float ave adev sdev var skew curt s nf p))

  (setq n (array-dimension data 0))

  (if (<= n 1) (error " the size of data must be at least 2 for moment ")) 
  (setf s 0d0) 
  (setq nf (dfloat n))

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf s (+ s (aref data j)))) 

  (setf ave (/ s n)) 
  (setf adev 0d0) 
  (setf var 0d0) 
  (setf skew 0d0) 
  (setf curt 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf s (- (aref data j) ave))
    (setf adev (+ adev (abs s)))
    (setf p (* s s))
    (setf var (+ var p))
    (setf p (* p s))
    (setf skew (+ skew p))
    (setf p (* p s))
    (setf curt (+ curt p))) 

  (setf adev (/ adev nf)) 
  (setf var (/ var (1- nf))) 
  (setf sdev (sqrt var)) 
  (cond 
   ((not (= var 0d0)) 
    (setf skew (/ skew (* nf (expt sdev 3))))
    (setf curt (- (/ curt (* nf (expt var 2))) 3d0)))
   (t  
    (error " no skew or kurtosis when zero variance "))) 
   
  (return (values ave adev sdev var skew curt))))

;-----------------------------------------------------------------------------
(defun mdian1 (x)
 (declare (type (simple-array double-float (*)) x))

 (prog ((n 0) (xmed 0d0) (n2 0))
  (declare (type fixnum x n2))
  (declare (type double-float xmed))

  (setq n (array-dimension x 0)) 
  (setq x (sort1 x)) 
  (setf n2 (floor (/ n 2)))
  (if 
   (= (* 2 n2) n)
   (setf xmed (* 0.5d0 (+ (aref x (1- n2)) (aref x n2))))
   (setf xmed (aref x n2))) 
  
  (return (the double-float xmed))))

;------------------------------------------------------------------------------
(defun mdian2 (x  &key (big 1.0d30) (afac 1.5d0) (amp 1.5d0))
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type double-float big afrac amp))

 (prog ((xmed 0d0) (n 0) (a 0d0) (am 0d0) (ap 0d0) (sum 0d0) (sumx 0d0) 
        (np 0) (nm 0) (xp 0d0) (xm 0d0) (eps 0d0) (xx 0d0) (dum 0d0) (aa 0d0))
  (declare (type double-float xmed a am ap sum sumx xp xm eps xx dum aa))
  (declare (type fixnum n np nm))

  (setq n (array-dimension x 0))


  (setf a (* 0.5d0 (+ (aref x 0) (aref x (1- n))))) 
  (setf eps (abs (+ (aref x (1- n)) (- (aref x 0))))) 
  (setf ap big) 
  (setf am (- big)) 
label1 
  (setf sum 0d0) 
  (setf sumx 0d0) 
  (setf np 0) 
  (setf nm 0) 
  (setf xp big) 
  (setf xm (- big)) 

  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf xx (aref x j))
    (when (not (= xx a))
     (cond 
       ((> xx a)  
        (setf np (+ np 1))
        (if (< xx xp) (setf xp xx)))
       ((< xx a) 
        (setf nm (+ nm 1))
        (if (> xx xm) (setf xm xx))))
     (setf dum (/ 1d0 (+ eps (abs (+ xx (- a)))))) 
     (setf sum (+ sum dum))
     (setf sumx (+ sumx (* xx dum))))) 

  (cond 
   ((>= (+ np (- nm)) 2) 
    (setf am a)
    (setf aa (+ xp (* (max 0d0 (+ (/ sumx sum) (- a))) amp)))
    (if (> aa ap) (setf aa (* 0.5d0 (+ a ap))))
    (setf eps (* afac (abs (+ aa (- a))))) 
    (setf a aa)
    (go label1))
   ((>= (- nm np) 2) 
    (setf ap a)
    (setf aa (+ xm (* (min 0d0 (+ (/ sumx sum) (- a))) amp)))
    (if (< aa am) (setf aa (* 0.5d0 (+ a am))))
    (setf eps (* afac (abs (+ aa (- a))))) 
    (setf a aa) 
    (go label1))
   (t
    (cond 
     ((= (mod n 2) 0)
      (cond 
       ((= np nm) 
        (setf xmed (* 0.5d0 (+ xp xm))))
       ((> np nm)
        (setf xmed (* 0.5d0 (+ a xp))))
       (t
        (setf xmed (* 0.5d0 (+ xm a))))))
     (t
      (cond 
       ((= np nm)  
        (setf xmed a))
       ((> np nm) 
        (setf xmed xp))
       (t (setf xmed xm))))))) 
  
  (return (the double-float xmed))))

;-----------------------------------------------------------------------------
(defun ttest (data1 data2)
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2)) 

 (prog ((n1 0) (n2 0) (t0 0d0) (prob 0d0) (df 0d0) (var 0d0) 
        (ave1 0d0) (var1 0d0) (ave2 0d0) (var2 0d0))
  (declare (type fixnum n1 n2))
  (declare (type double-float t0 prob df var ave1 var1 ave2 var2))

  (setq n1 (array-dimension data1 0))
  (setq n2 (array-dimension data2 0))

  (multiple-value-setq (ave1 var1) (avevar data1)) 
  (multiple-value-setq (ave2 var2) (avevar data2)) 

  (setf df (dfloat (- (+ n1 n2) 2))) 
  (setf var (/ (+ (* (1- n1) var1) (* (1- n2) var2)) df)) 
  (setf t0 (/ (- ave1 ave2) 
              (sqrt (* var (+ (/ 1d0 (dfloat n1)) (/ 1d0 (dfloat n2))))))) 
  (setf prob (betai (* 0.5d0 df) 0.5d0 (/ df (+ df (expt t0 2))))) 
   
  (return (values t0 prob))))

;-----------------------------------------------------------------------------
(defun avevar (data)
 (declare (type (simple-array double-float (*)) data)) 

 (prog ((n 0) (ave 0d0) (var 0d0) (s 0d0))
   (declare (type fixnum n) (type double-float ave var s))

   (setq n (array-dimension data 0))
   (setf ave 0d0 var 0d0) 
   (do ((j 0 (+ j 1)))
       ((> j (1- n)) t)
       (declare (type fixnum j))
       (setf ave (+ ave (aref data j))))
   (setf ave (/ ave n)) 
   (do ((j 0 (+ j 1)))
       ((> j (1- n)) t)
       (declare (type fixnum j))
       (setf s (- (aref data j) ave)) 
       (setf var (+ var (* s s))))
   (setf var (/ var (1- n))) 
   (return (values ave var))))

;------------------------------------------------------------------------------
(defun tutest (data1 data2)
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2)) 

 (prog ((ave1 0d0) (var1 0d0) (ave2 0d0) (var2 0d0)
        (df 0d0) (prob 0d0) (t0 0d0) (n1 0) (n2 0))
  (declare (type double-float ave1 var1 ave2 var2 df prob t0))
  (declare (type fixnum n1 n2))

  (setq n1 (array-dimension data1 0))
  (setq n2 (array-dimension data2 0))

  (multiple-value-setq (ave1 var1) (avevar data1)) 
  (multiple-value-setq (ave2 var2) (avevar data2)) 
  (setf t0 (/ (- ave1 ave2) 
              (sqrt (+ (/ var1 (dfloat n1)) (/ var2 (dfloat n2)))))) 
  (setf df (/ (expt (+ (/ var1 n1) (/ var2 n2)) 2)
              (+ (/ (expt (/ var1 n1) 2) (1- n1))
                 (/ (expt (/ var2 n2) 2) (1- n2))))) 
  (setf prob (betai (* 0.5d0 df) 0.5d0 (/ df (+ df (expt t0 2))))) 
   
  (return (values t0 prob))))

;------------------------------------------------------------------------------
(defun tptest (data1 data2)
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2)) 

 (prog ((n 0) (t0 0d0) (prob 0d0) (ave1 0d0) (var1 0d0)
        (ave2 0d0) (var2 0d0) (cov 0d0) (sd 0d0) (df 0d0))
  (declare (type fixnum n))
  (declare (type double-float t0 prob ave1 var1 ave2 var2 cov sd df))

  (setq n (array-dimension data1 0))

  (multiple-value-setq (ave1 var1) (avevar data1)) 
  (multiple-value-setq (ave2 var2) (avevar data2)) 
  (setf cov 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf cov (+ cov
                 (* (+ (aref data1 j) (- ave1))
                    (+ (aref data2 j) (- ave2)))))) 
  (setf df (dfloat (1- n)) )
  (if (= cov 0d0) (error " zero covariance in tptest "))
  (setf cov (/ cov df)) 
  (setf sd (sqrt (/ (+ (+ var1 var2) (* -2d0 cov)) (dfloat n)))) 
  (if (= sd 0d0) (error " zero joint deviation sd in tptest "))
  (setf t0 (/ (+ ave1 (- ave2)) sd)) 
  (setf prob (betai (* 0.5d0 df) 0.5d0 (/ df (+ df (expt t0 2))))) 
   
  (return (values t0 prob))))

;------------------------------------------------------------------------------
(defun ftest (data1 data2)
 (declare (type (simple-array double-float (*)) data1 data2))

 (prog ((n1 0) (n2 0) (f 0d0) (prob 0d0) (dum 0d0) (var1 0d0) 
        (var2 0d0) (df1 0d0) (df2 0d0))
  (declare (type fixnum n1 n2)) 
  (declare (type double-float f prob var1 var2 df1 df2))
#+vms  (declare (ignore dum))

  (setq n1 (array-dimension data1 0))
  (setq n2 (array-dimension data2 0))
  (multiple-value-setq (dum var1) (avevar data1)) 
  (multiple-value-setq (dum var2) (avevar data2))
  (cond 
   ((> var1 var2)
    (setq f (/ var1 var2))
    (setq df1 (dfloat (1- n1)))
    (setq df2 (dfloat (1- n2))))
   (t
    (setq f (/ var2 var1))
    (setq df1 (dfloat (1- n2)))
    (setq df2 (dfloat (1- n1)))))

  (setq prob (* 2d0 (betai (* 0.5d0 df1) (* 0.5d0 df2) 
                           (/ df2 (+ df2 (* df1 f))))))
  (if (> prob 1d0) (setq prob (- 2d0 prob)))
  (return (values f prob))))

;------------------------------------------------------------------------------
    
(defun chsone (bins ebins knstrn)
 (declare (type (simple-array double-float (*)) bins)) 
 (declare (type (simple-array double-float (*)) ebins)) 
 (declare (type fixnum knstrn))

 (prog ((df 0d0) (chsq 0d0) (prob 0d0) (nbins 0))
  (declare (type double-float chsq prob df) (type fixnum nbins))

  (setq nbins (array-dimension bins 0))
  (setf df (dfloat (- (1- nbins) knstrn)))
  (setf chsq 0d0) 
  (do ((j 0 (1+ j)))
      ((> j (1- nbins)) t)
    (if (<= (aref ebins j) 0d0) (error "bad expected number in chsone"))
    (setf chsq (+ chsq
                  (/ (expt (- (aref bins j) (aref ebins j)) 2)
                     (aref ebins j))))) 
  (setf prob (gammq (* 0.5d0 df) (* 0.5d0 chsq))) 
  (return (values df chsq prob))))

;-------------------------------------------------------------------------------

(defun chstwo (bins1 bins2 knstrn)
 (declare (type (simple-array double-float (*)) bins1)) 
 (declare (type (simple-array double-float (*)) bins2)) 
 (declare (type fixnum knstrn))

 (prog ((nbins 0) (df 0d0) (chsq 0d0) (prob 0d0))
  (declare (type fixnum nbins))
  (declare (type double-float chsq prob df))

  (setf nbins (array-dimension bins1 0))
  (setf df (dfloat (- (1- nbins) knstrn))) 
  (setf chsq 0d0) 
  (do ((j 0 (1+ j)))
      ((> j (1- nbins)) t)
    (if (and (= (aref bins1 j) 0) (= (aref bins2 j) 0))
     (setf df (1- df))
     (setf chsq (+ chsq
                   (/ (expt (- (aref bins1 j) (aref bins2 j)) 2)
                      (+ (aref bins1 j) (aref bins2 j))))))) 

  (setf prob (gammq (* 0.5d0 df) (* 0.5d0 chsq))) 

  (return (values df chsq prob))))

;------------------------------------------------------------------------------

(defun ksone (data func)
 (declare (type (simple-array double-float (*)) data)) 

 (prog ((n 0) (d 0d0) (prob 0d0) (fn 0d0) (ff 0d0) (dt 0d0) (fo 0d0) (en 0d0))
  (declare (type fixnum n))
  (declare (type double-float d prob fn ff dt fo en))

  (setq n (array-dimension data 0))
  (setq data (sort1 data))  ; there is a common lisp function named sort
  (setf en (dfloat n)) 
  (setf d 0d0) 
  (setf fo 0d0) 

  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf fn (/ (dfloat j) en))
    (setf ff (funcall func (aref data (1- j))))
    (setf dt (max (abs (- fo ff)) (abs (- fn ff))))
    (if (> dt d) (setf d dt))
    (setf fo fn))
 
  (setf prob (probks (* (sqrt en) d))) 
   
  (return (values d prob))))

;-----------------------------------------------------------------------------
(defun kstwo (data1 data2)
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2))

 (prog ((n1 0) (n2 0) (en1 0d0) (en2 0d0) (j1 0) (j2 0) (fn1 0d0) 
        (fn2 0d0) (d 0d0) (prob 0d0) (d1 0d0) (d2 0d0) (dt 0d0))
  (declare (type fixnum n1 n2 j1 j2))
  (declare (type double-float en1 en2 fn1 fn2 d prob d1 d2 dt))

  (setq n1 (array-dimension data1 0))
  (setq n2 (array-dimension data2 0))
 
  (setq data1 (sort1 data1)) 
  (setq data2 (sort1 data2)) 
  (setf en1 (dfloat n1)) 
  (setf en2 (dfloat n2)) 
  (setf j1 1) 
  (setf j2 1) 
  (setf fn1 0d0) 
  (setf fn2 0d0) 
  (setf d 0d0) 
  label1 
  (when 
   (and (<= j1 n1) (<= j2 n2)) 
   (setf d1 (aref data1 (1- j1))) 
   (setf d2 (aref data2 (1- j2)))
   (when 
    (<= d1 d2)  
    (setf fn1 (/ (dfloat j1) en1))
    (setf j1 (1+ j1)))
   (when 
    (<= d2 d1)  
    (setf fn2 (/ (dfloat j2) en2))
    (setf j2 (1+ j2)))
   (setf dt (abs (- fn2 fn1))) 
   (if (> dt d) (setf d dt)) 
   (go label1)) 
  (setf prob (probks (* (sqrt (/ (* en1 en2) (+ en1 en2))) d))) 
  
  (return (values d prob))))

;-----------------------------------------------------------------------------
(defun probks (alam &key (eps1 0.001d0) (eps2 1.0d-8))
 (declare (type double-float alam eps1 eps2))

 (prog ((probks 0d0) (a2 0d0) (fac 0d0) (termbf 0d0) (term 0d0))
  (declare (type double-float probks a2 fac termbf term))

  (setf a2 (* -2d0 (expt alam 2))) 
  (setf fac 2d0) 
  (setf probks 0d0) 
  (setf termbf 0d0) 

  (do ((j 1 (+ j 1)))
      ((> j 100) t)
    (setf term (* fac (exp (* a2 (dfloat (expt j 2))))))
    (setf probks (+ probks term))
   
    (if  
        (or (<= (abs term) (* eps1 termbf))
            (<= (abs term) (* eps2 probks)))
        (go end))
    (setf fac (- fac))
    (setf termbf (abs term))) 
  (setf probks 1d0)
 end  
  (return (the double-float probks))))

;------------------------------------------------------------------------------
(defun cntab1 (nn &key (tiny 1.0d-30))
 (declare (type (simple-array fixnum (* *)) nn)) 
 (declare (type double-float tiny))

 (prog* ((chisq 0d0) (df 0d0) (prob 0d0) (cramrv 0d0)
    (ccc 0d0)
    (ni (array-dimension nn 0)) (nj (array-dimension nn 1)) 
    (sum 0d0) (nni 0) (nnj 0)
    (sumi (make-array ni :element-type 'double-float :initial-element 0d0)) 
    (sumj (make-array nj :element-type 'double-float :initial-element 0d0))
    (expctd 0d0) (gammq 0d0))

  (declare (type (simple-array double-float (*)) sumi)) 
  (declare (type (simple-array double-float (*)) sumj)) 
  (declare (type fixnum ni nj df nni nnj))
  (declare (type double-float chisq df prob cramrv ccc sumi sumj sum
         expctd gammq)) 
  (declare (ignore gammq))


  (setf sum 0d0) 
  (setf nni ni) 
  (setf nnj nj) 

  (do ((i 0 (1+ i)))
      ((> i (1- ni)) t)
      (declare (type fixnum i))
    (setf (aref sumi i) 0d0)
    (do ((j 0 (+ j 1)))
        ((> j (1- nj)) t)
        (declare (type fixnum j))
      (setf (aref sumi i) (+ (aref sumi i) (aref nn i j)))
      (setf sum (+ sum (aref nn i j))))
    (if (= (aref sumi i) 0d0) (setf nni (1- nni)))) 

  (do ((j 0 (+ j 1)))
      ((> j (1- nj)) t)
      (declare (type fixnum j))
    (setf (aref sumj j) 0d0)
    (do ((i 0 (+ i 1)))
        ((> i (1- ni)) t)
      (declare (type fixnum i))
      (setf (aref sumj j) (+ (aref sumj j) (aref nn i j))))
    (if (= (aref sumj j) 0d0) (setf nnj (1- nnj)))) 

  (setf df (dfloat (+ (- (- (* nni nnj) nni) nnj) 1))) 
  (setf chisq 0d0) 
  (do ((i 0 (+ i 1)))
      ((> i (1- ni)) t)
      (declare (type fixnum i))
    (do ((j 1 (+ j 1)))
        ((> j (1- nj)) t)
        (declare (type fixnum j))
      (setf expctd (/ (* (aref sumj j) (aref sumi i)) sum))
      (setf chisq (+ chisq
                     (/ (expt (- (aref nn i j) expctd) 2)
                        (+ expctd tiny)))))) 

  (setf prob (gammq (* 0.5d0 df) (* 0.5d0 chisq))) 
  (setf cramrv (sqrt (/ chisq
                        (* sum (min (1- nni) (1- nnj)))))) 
  (setf ccc (sqrt (/ chisq (+ chisq sum)))) 

  (return (values chisq df prob cramrv ccc))))

;-------------------------------------------------------------------------------
(defun cntab2 (nn &key (tiny 1.0d-30))
 (declare (type (simple-array fixnum (* *)) nn)) 
 (declare (type double-float tiny))

 (prog* (
         (ni (1- (array-dimension nn 0)))
         (nj (1- (array-dimension nn 1)))
        (h 0d0) (hx 0d0) (hy 0d0) (hygx 0d0) 
        (hxgy 0d0) (uygx 0d0) (uxgy 0d0) (uxy 0d0) (sum 0d0)
   (sumi (make-array (1+ ni) :element-type 'double-float :initial-element 0d0)) 
   (sumj (make-array (1+ nj) :element-type 'double-float :initial-element 0d0)) 
   (p 0d0))

  (declare (type (simple-array double-float (*)) sumi)) 
  (declare (type (simple-array double-float (*)) sumj)) 
  (declare (type fixnum ni nj maxi maxj))
  (declare (type double-float hx hy hygx hxgy uygx uxgy uxy 
                 sum sumi sumj p h))


  (setf sum 0d0)

 
  (do ((i 0 (+ i 1)))
      ((> i ni) t)
      (declare (type fixnum i))
    (setf (aref sumi i) 0d0)
    (do ((j 0 (+ j 1)))
        ((> j nj) t)
        (declare (type fixnum j))
      (setf (aref sumi i) (+ (aref sumi i) (aref nn i j)))
      (setf sum (+ sum (aref nn i j))))) 

  (do ((j 0 (+ j 1)))
      ((> j nj) t)
      (declare (type fixnum j))
    (setf (aref sumj j) 0d0)
    (do ((i 0 (+ i 1)))
        ((> i ni) t)
        (declare (type fixnum i))
      (setf (aref sumj j) (+ (aref sumj j) (aref nn i j)))))
 
  (setf hx 0d0) 
  (do ((i 0 (+ i 1)))
      ((> i ni) t)
    (when (aref sumi i)
     (setf p (/ (aref sumi i) sum)) 
     (setf hx (+ hx (* (- p) (log p)))))) 

  (setf hy 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j nj) t)
      (declare (type fixnum j))
    (when (aref sumj j)
     (setf p (/ (aref sumj j) sum)) 
     (setf hy (+ hy (* (- p) (log p)))))) 

  (setf h 0d0) 
  (do ((i 0 (+ i 1)))
      ((> i ni) t)
      (declare (type fixnum i))
    (do ((j 0 (+ j 1)))
        ((> j nj) t)
        (declare (type fixnum j))
      (when (aref nn i j)
       (setf p (/ (aref nn i j) sum)) 
       (setf h (+ h (* (- p) (log p))))))) 

  (setf hygx (- h hx)) 
  (setf hxgy (- h hy)) 
  (setf uygx (/ (- hy hygx) (+ hy tiny))) 
  (setf uxgy (/ (- hx hxgy) (+ hx tiny))) 
  (setf uxy (/ (* 2d0 (- (+ hx hy) h)) (+ (+ hx hy) tiny))) 

  (return (values h hx hy hygx hxgy uygx uxgy uxy))))

;------------------------------------------------------------------------------
(defun pearsn (x y)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 

 (prog ((r 0d0) (prob 0d0) (z 0d0) (tiny 0d0) (ax 0d0) (ay 0d0) 
        (sxx 0d0) (syy 0d0) (sxy 0d0) (xt 0d0) (yt 0d0) (t0 0d0)
        (df 0d0) (n 0))
  (declare (type double-float r prob z tiny ax ay sxx syy sxy xt yt t0 df))
  (declare (type fixnum n))

  (setq tiny 1.d-20) 
  (setf ax 0d0) 
  (setf ay 0d0)
  (setq n (array-dimension x 0))
 
  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf ax (+ ax (aref x j)))
    (setf ay (+ ay (aref y j)))) 

  (setf ax (/ ax n)) 
  (setf ay (/ ay n)) 
  (setf sxx 0d0) 
  (setf syy 0d0) 
  (setf sxy 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf xt (- (aref x j) ax))
    (setf yt (- (aref y j) ay))
    (setf sxx (+ sxx (expt xt 2)))
    (setf syy (+ syy (expt yt 2)))
    (setf sxy (+ sxy (* xt yt)))) 

  (setf r (/ sxy (sqrt (* sxx syy)))) 
  (setf z (* 0.5d0 (log (/ (+ 1d0 r tiny) (+ (- 1d0 r) tiny))))) 
  (setf df (dfloat (2- n))) 
  (setf t0 (* r (sqrt (/ df (* (+ (- 1d0 r) tiny) (+ 1d0 r tiny)))))) 
  (setf prob (betai (* 0.5d0 df) 0.5d0 (/ df (+ df (expt t0 2))))) 
; (setf prob (erfcc (/ (abs (* z (sqrt (1- n)))) 1.414214d0))) 
   
  (return (values r prob z))))

;------------------------------------------------------------------------------
(defun spear (data1 data2 )
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2)) 

 (prog* ((t0 0d0) 
  (n (array-dimension data1 0))
  (wksp1 (make-array n :element-type 'double-float :initial-element 0d0))
  (wksp2 (make-array n :element-type 'double-float :initial-element 0d0))
  (d 0d0) (zd 0d0) 
  (probd 0d0) (rs 0d0) (probrs 0d0) (sf 0d0) (sg 0d0)
  (en 0d0) (en3n 0d0) (aved 0d0) (fac 0d0) (vard 0d0) (df 0d0))

  (declare (type (simple-array double-float (*)) wksp1)) 
  (declare (type (simple-array double-float (*)) wksp2))
  (declare (type fixnum n))
  (declare (type double-float d zd probd rs probrs sf sg en en3n aved 
                 fac vard df t0))



  (do ((j 0 (1+ j)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref wksp1 j) (aref data1 j))
    (setf (aref wksp2 j) (aref data2 j)))
  (multiple-value-setq (wksp1 wksp2) (sort2 wksp1 wksp2)) 
  (multiple-value-setq (wksp1 sf) (crank wksp1)) 
  (multiple-value-setq (wksp2 wksp1) (sort2 wksp2 wksp1)) 
  (multiple-value-setq (wksp2 sg) (crank wksp2)) 
  (setf d 0d0) 

  (do ((j 0 (1+ j)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf d (+ d (expt (+ (aref wksp1 j) (- (aref wksp2 j))) 2)))) 

  (setf en (dfloat n)) 
  (setf en3n (+ (expt en 3) (- en))) 
  (setf aved (+ (/ en3n 6d0) (/ (- (+ sf sg)) 12d0))) 
  (setf fac (* (1+ (/ (- sf) en3n)) (1+ (/ (- sg) en3n)))) 
  (setf vard (* (/ (* (* (1- en) (expt en 2)) (expt (1+ en) 2)) 36d0)
                fac)) 
  (setf zd (/ (+ d (- aved)) (sqrt vard))) 
  (setf probd (erfcc (/ (abs zd) 1.414214d0))) 
  (setf rs (/ (1+ (* (- (/ 6d0 en3n)) (+ d (/ (+ sf sg) 12d0)))) (sqrt fac))) 
  (setf fac (* (1+ rs) (1+ (- rs)))) 
  (cond 
    ((> fac 0d0)
     (setf t0 (* rs (sqrt (/ (+ en (- 2d0)) fac)))) 
     (setf df (+ en (- 2d0)))
     (setf probrs (betai (* 0.5d0 df) 0.5d0 (/ df (+ df (expt t0 2))))))
    (t 
     (setf probrs 0d0))) 
   
  (return (values d zd probd rs probrs))))

;-----------------------------------------------------------------------------
(defun crank (w)
 (declare (type (simple-array double-float (*)) w))

 (prog ((j 0) (jt 0) (t0 0d0) (n 0) (rank 0d0) (s 0d0))
  (declare (type fixnum j jt n))
  (declare (type double-float t0 rank s))

  (setq n (array-dimension w 0))
  (setf s 0d0) 
  (setf j 1) 
label1 
  (when 
   (< j n) 
   (cond
    ((not (= (aref w j) (aref w (- j 1))))  
     (setf (aref w (1- j)) (dfloat j))
     (setf j (+ j 1)))
    (t
     (tagbody

     (do ((jtt (+ j 1) (+ jtt 1)))
        ((> jtt n) t)
        (declare (type fixnum i))
      (setq jt jtt)
      (if (not (= (aref w (1- jt)) (aref w (1- j)))) (go label2)))

     (setf jt (+ n 1))
 label2 )
     (setf rank (* 0.5d0 (dfloat (1- (+ j jt)))))
     (do ((ji j (+ ji 1)))
         ((> ji (1- jt)) t)
        (declare (type fixnum ji))
       (setf (aref w (1- ji)) rank))

     (setf t0 (dfloat (- jt j))) 
     (setf s (- (+ s (expt t0 3)) t0)) 
     (setf j jt)))
    (go label1)) 
  (if (= j n) (setf (aref w (1- n)) (dfloat n))) 

  (return (values w s))))

;------------------------------------------------------------------------------

(defun kendl1 (data1 data2)
 (declare (type (simple-array double-float (*)) data1)) 
 (declare (type (simple-array double-float (*)) data2)) 

 (prog ((n 0) (tau 0d0) (z 0d0) (prob 0d0) (n1 0) 
        (n2 0) (is 0) (a1 0d0) (a2 0d0) (aa 0d0) (var 0d0))
  (declare (type fixnum n n1 n2 is))
  (declare (type double-float tau z a1 a2 aa var))

  (setq n (array-dimension data1 0))  
  (setf n1 0) 
  (setf n2 0) 
  (setf is 0) 
  (do ((j 1 (+ j 1)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (do ((k (1+ j) (+ k 1)))
        ((> k n) t)
        (declare (type fixnum k))
      (setf a1 (- (fref data1 j) (fref data1 k)))
      (setf a2 (- (fref data2 j) (fref data2 k)))
      (setf aa (* a1 a2))
      (cond 
       ((not (= aa 0d0))
        (setf n1 (1+ n1))
        (setf n2 (1+ n2))
        (if 
         (> aa 0d0) 
         (setf is (1+ is))
         (setf is (1- is))))
       (t 
        (if (not (= a1 0d0)) (setf n1 (1+ n1)))
        (if (not (= a2 0d0)) (setf n2 (1+ n2)))))))
 
  (setf tau (/ (dfloat is) (sqrt (dfloat (* n1 n2))))) 
  (setf var (dfloat (/ (+ (* 4 n) 10) (* (* 9 n) (1- n))))) 
  (setf z (/ tau (sqrt var))) 
  (setf prob (erfcc (/ (abs z) 1.414214d0))) 
  (return (values tau z prob))))

;-------------------------------------------------------------------------------

(defun kendl2 (tab i j)
 (declare (type fixnum i j))
 (declare (type (simple-array double-float (* *)) tab)) 

 (prog ((ip 0) (jp 0)  (tau 0d0) (z 0d0) (prob 0d0) (en1 0d0)
        (en2 0d0) (s 0d0) (nn 0) (pairs 0d0) (li 0) 
        (lj 0) (m1 0) (m2 0) (mm 0) (var 0d0) 
        (points 0d0) (ki 0) (kj 0))
  (declare (type fixnum ip jp nn li lj m1 m2 mm ki kj))
  (declare (type double-float tau z prob en1 en2 s pairs var points))

  (setq ip (array-dimension tab 0))
  (setq jp (array-dimension tab 1))
  (if (or (> i ip) (> j jp)) (error " index out of range in Kendl2."))
  (setf en1 0d0) 
  (setf en2 0d0) 
  (setf s 0d0) 
  (setf nn (* i j)) 
  (setf points (aref tab (1- i) (1- j))) 

  (do ((k 0 (+ k 1)))
      ((> k (- nn 2)) t)
      (declare (type fixnum k))
    (setf ki (floor (/ k j)))
    (setf kj (- k (* j ki)))
    (setf points (+ points (aref tab ki kj)))
    (do ((l (+ k 1) (+ l 1)))
        ((> l (1- nn)) t)
        (declare (type fixnum l))
      (setf li (floor (/ l j)))
      (setf lj (- l (* j li)))
      (setf m1 (- li ki))
      (setf m2 (- lj kj))
      (setf mm (* m1 m2))
      (setf pairs (* (aref tab ki kj) (aref tab li lj)))
      (cond 
       ((not (= mm 0))
        (setf en1 (+ en1 pairs)) (setf en2 (+ en2 pairs))
        (if 
         (> mm 0) 
         (setf s (+ s pairs))
         (setf s (- s pairs))))
       (t
        (if (not (= m1 0)) (setf en1 (+ en1 pairs)))
        (if (not (= m2 0)) (setf en2 (+ en2 pairs))))))) 

  (setf tau (/ s (sqrt (* en1 en2)))) 
  (setf var (/ (+ (* 4d0 points) 10d0) (* (* 9d0 points) (1- points)))) 
  (setf z (/ tau (sqrt var))) 
  (setf prob (erfcc (/ (abs z) 1.414214d0))) 
   
  (return (values tau z prob))))

;-------------------------------------------------------------------------------
(defun smooft (yy pts &key (mmax 1024)) 
 (declare (type (simple-array double-float (*)) yy))
 (declare (type fixnum pts mmax))
 (declare (ignore mmax))

 (prog ((m 0) (nmin 0) (y1 0d0) (yn 0d0) (rn1 0d0) (mo2 0) 
        (fac 0d0) (const 0d0) (k 0) (n 0) (y nil))
  (declare (type fixnum m n nmin mo2 k))
  (declare (type double-float y yn rn1 fac const))
;  (declare (type (simple-array double-float (*)) y))

  (setq n (array-dimension yy 0))


  
  (setf m 2) 
  (setf nmin (+ n (* 2 pts))) 
label1 

  (when 
    (< m nmin)
    (setf m (* 2 m))
    (go label1)) 

  (setq y (make-array m :element-type 'double-float :initial-element 0d0))
  (do ((j 0 (1+ j)))
      ((> j (1- n)) t)
      (declare (type fixnum j))
    (setf (aref y j) (aref yy j)))

;  (if (> m mmax) (error "mmax too small in smooft ")) 
  (setf const (expt (dfloat (/ pts m)) 2)) 
  (setf y1 (aref y 0)) 
  (setf yn (aref y (1- n))) 
  (setf rn1 (/ 1d0 (+ n (- 1)))) 

  (do ((j 1 (+ j 1)))
      ((> j n) t)
      (declare (type fixnum j))
    (setf (aref y (1- j)) (+ (aref y (1- j))
                        (* (- rn1)
                           (+ (* y1 (+ n (- j))) (* yn (1- j))))))) 

  (do ((j n (+ j 1)))
      ((> j (1- m)) t)
      (declare (type fixnum j))
    (setf (aref y j) 0d0)) 

  (setf mo2 (floor (/ m 2))) 
  (setq y (realft y mo2 :isign 1))

  (setf (aref y 0) (/ (aref y 0) mo2)) 
  (setf fac 1d0) 
  (do ((j 1 (+ j 1)))
      ((> j (1- mo2)) t)
      (declare (type fixnum j))
    (setf k (1+ (* 2 j)))
    (cond 
     ((not (= fac 0d0))
      (setf fac (max 0d0 (/ (+ 1d0 (* (- const) (expt j 2))) mo2)))
      (setf (aref y (1- k)) (* fac (aref y (1- k))))
      (setf (aref y k) (* fac (aref y  k))))
     (t
      (setf (aref y (1- k)) 0d0) (setf (aref y k) 0d0))))
 
  (setf fac (max 0d0 (/ (1+ (* -0.25d0 (expt pts 2))) mo2))) 
  (setf (aref y 1) (* fac (aref y 1))) 
  (setq y (realft y mo2 :isign -1))
 
  (do ((j 1 (+ j 1)))
      ((> j n) t)
    (setf (aref y (1- j)) (+ (* rn1 (+ (* y1 (+ n (- j))) (* yn (1- j))))
                        (aref y (1- j))))) 
   
  (return y)))

;------------------------------------------------------------------------------
;end of nr13.l

