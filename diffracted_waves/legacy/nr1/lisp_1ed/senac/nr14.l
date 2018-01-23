; nr14.l
; Modelling Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;	fit: fit data to a straight line using least squares
;	lfit: linear least squares fit, general using normal equations
;	covsrt: covariance matrix, sort, used by lfit
;	svdfit: linear least squares fit, general, singular value decomposition
;	svdvar: variances from singular value decomposition
;	fpoly: fit a polynomial, using lfit or svdfit
;	fleg: fit a Legendre polynomial, using lfit or svdfit
;	mrqmin: nonlinear least squares fit Marquardt's method
;	mrqcof:  nonlinear least squares fit, used by mrqmin
;	fgauss: fit a sum of Gaussians, using mrqmin
;	medfit: fit data to a straight line robustly, least absolute deviation
;	  rofunc: fit data robustly, used by medfit
;-----------------------------------------------------------------------------

(defun fit (x y sig mwt)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) sig)) 
 (declare (type fixnum mwt))

 (prog ((a 0d0) (b 0d0) (siga 0d0) (sigb 0d0) (chi2 0d0) (q 0d0)
        (sx 0d0) (sy 0d0) (st2 0d0) (ndata 0) (t0 0d0)
        (ss 0d0) (wt 0d0) (sxoss 0d0) (sigdat 0d0))
  (declare (type double-float a b siga sigb chi2 q sx sy 
                              st2 t0 ss wt sxoss sigdat))
  (declare (type fixnum ndata))

  (setq ndata (array-dimension x 0))
  (setf sx 0d0) 
  (setf sy 0d0) 
  (setf st2 0d0) 
  (setf b 0d0) 

  (cond 
   ((not (= mwt 0))  
    (setf ss 0d0)
    (do ((i 0 (+ i 1)))
        ((> i (1- ndata)) t)
        (declare (type fixnum i))
      (setf wt (/ 1d0 (expt (aref sig i) 2)))
      (setf ss (+ ss wt))
      (setf sx (+ sx (* (aref x i) wt)))
      (setf sy (+ sy (* (aref y i) wt)))))
   (t
    (do ((i 0 (+ i 1)))
        ((> i (1- ndata)) t)
        (declare (type fixnum i))
      (setf sx (+ sx (aref x i)))
      (setf sy (+ sy (aref y i))))
    (setf ss (dfloat ndata))) )

  (setf sxoss (/ sx ss)) 

  (cond 
   ((not (= mwt 0))
    (do ((i 0 (+ i 1)))
        ((> i (1- ndata)) t)
      (setf t0 (/ (- (aref x i) sxoss) (aref sig i)))
      (setf st2 (+ st2 (* t0 t0)))
      (setf b (+ b (/ (* t0 (aref y i)) (aref sig i))))))
   (t
    (do ((i 0 (+ i 1)))
        ((> i (1- ndata)) t)
        (declare (type fixnum i))
      (setf t0 (- (aref x i) sxoss))
      (setf st2 (+ st2 (* t0 t0)))
      (setf b (+ b (* t0 (aref y i)))))))

  (setf b (/ b st2)) 
  (setf a (/ (- sy (* sx b)) ss)) 
  (setf siga (sqrt (/ (1+ (/ (* sx sx) (* ss st2))) ss))) 
  (setf sigb (sqrt (/ 1d0 st2))) 
  (setf chi2 0d0) 

  (cond 
   ((= mwt 0)
    (do ((i 0 (+ i 1)))
        ((> i (1- ndata)) t)
        (declare (type fixnum i))
      (setf chi2 (+ chi2
                   (expt (- (- (aref y i) a) (* b (aref x i)))
                         2))))
   (setf q 1d0) 
   (setf sigdat (sqrt (/ chi2 (dfloat (2- ndata)))))
   (setf siga (* siga sigdat)) (setf sigb (* sigb sigdat))) 
   (t
    (do ((i 0 (+ i 1)))
        ((> i (1- ndata)) t)
         (declare (type fixnum i))
     (setf chi2 (+ chi2
                   (expt (/ (- (- (aref y i) a) (* b (aref x i)))
                            (aref sig i))
                         2))))
   (setf q (gammq (* 0.5d0 (2- ndata)) (* 0.5d0 chi2)))))

  (return (values a b siga sigb chi2 q))))

;-----------------------------------------------------------------------------

(defun lfit (x y sig mfit lista funcs)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) sig))
 (declare (type fixnum mfit))
 (declare (type (simple-array fixnum (*)) lista)) 

 (prog* (
   (chisq 0d0) (kk 0)
   (ihit 0)   
   (ndata (array-dimension x 0))
  (ma (array-dimension lista 0))
  (ncvm ma)
  (a (make-array ma :element-type 'double-float :initial-element 0d0))
  (covar (make-array (list ma ma) 
                :element-type 'double-float :initial-element 0d0))
  (covar1 (make-array (list mfit mfit) 
                :element-type 'double-float :initial-element 0d0))
  (beta (make-array mfit 
                :element-type 'double-float :initial-element 0d0))
  (beta2 (make-array (list mfit 1)
                :element-type 'double-float :initial-element 0d0))
  (afunc (make-array ma 
                :element-type 'double-float :initial-element 0d0))
  (ym 0d0) (sig2i 0d0) (wt 0d0) (sum 0d0)) 


  (declare (type (simple-array double-float (*)) a)) 
  (declare (type (simple-array double-float (* *)) covar)) 
  (declare (type (simple-array double-float (* *)) covar1))
  (declare (type (simple-array double-float (*)) beta)) 
  (declare (type (simple-array double-float (* *)) beta2))
  (declare (type (simple-array double-float (*)) afunc)) 
  (declare (type fixnum kk ihit ndata ma ncvm))
  (declare (type double-float ym sig2i wt sum))
  (declare (ignore ncvm))

 
  (setf kk (+ mfit 1)) 
  (do ((j 1 (+ j 1)))
      ((> j ma) t)
      (declare (type fixnum j))
    (setf ihit 0)
    (do ((k 1 (+ k 1)))
        ((> k mfit) t)
        (declare (type fixnum k))
      (if (= (aref lista (1- k)) j) (setf ihit (+ ihit 1))))

    (cond 
     ((= ihit 0) 
      (setf (aref lista (1-  kk)) j)
      (setf kk (+ kk 1)))
     ((> ihit 1)
      (error " Improper set in lista for lfit ")))) 

  (if (not (= kk (1+ ma))) (error " improper set in lista for lfit ")) 

  (do ((j 1 (+ j 1)))
      ((> j mfit) t)
      (declare (type fixnum j))
    (do ((k 1 (+ k 1)))
        ((> k mfit) t)
        (declare (type fixnum k))
      (fset (fref covar j k) 0d0))
    (fset (fref beta j) 0d0))
 
  (do ((i 1 (+ i 1)))
      ((> i ndata) t)
      (declare (type fixnum i))
     (do ((j 1 (1+ j)))
         ((> j ma) t)
         (declare (type fixnum j))
        (setf (aref afunc (1- j)) 
            (dfloat (funcall (nth (1- j) funcs) (aref x (1- i))))))
    (setf ym (aref y (1- i)))

    (if (< mfit ma)
     (do ((j (+ mfit 1) (+ j 1)))
         ((> j ma) t)
         (declare (type fixnum j))
       (setf ym (- ym
                   (* (fref a (fref lista j))
                      (fref afunc (fref lista j)))))))

    (setf sig2i (/ 1d0 (expt (fref sig i) 2)))
    (do ((j 1 (+ j 1)))
        ((> j mfit) t)
        (declare (type fixnum j))
      (setf wt (* (fref afunc (fref lista j)) sig2i))
      (do ((k 1 (+ k 1)))
          ((> k j) t)
        (setf (aref covar1 (1- j) (1- k)) (+ (fref covar1 j k)
                                  (* wt (fref afunc (fref lista k))))))
      (setf (aref beta (1- j)) (+ (fref beta j) (* ym wt))))) 


  (if (> mfit 1)
   (do ((j 2 (+ j 1)))
       ((> j mfit) t)
       (declare (type fixnum j))
     (do ((k 1 (+ k 1)))
         ((> k (1- j)) t)
         (declare (type fixnum k))
       (setf (aref covar1 (1- k) (1- j)) (fref covar1 j k)))))

(do ((j 0 (1+ j))) ((> j (1- mfit)) t)
  (setf (aref beta2 j 0) (aref beta j)))
 
  (multiple-value-setq (covar1 beta2) (gaussj covar1 beta2))

(do ((j 0 (1+ j))) ((> j (1- mfit)) t)
  (setf (aref beta j) (aref beta2 j 0)))

  (do ((j 1 (+ j 1)))
      ((> j mfit) t)
      (declare (type fixnum j))
    (setf (aref a (1- (fref lista j))) (fref beta j))) 

  (setf chisq 0d0) 
  (do ((i 1 (+ i 1)))
      ((> i ndata) t)
      (declare (type fixnum i))
    (do ((j 1 (1+ j)))
        ((> j ma) t)
        (declare (type fixnum j))
      (setf (aref afunc (1- j)) 
             (dfloat (funcall (nth (1- j) funcs) (fref x i)))))
    (setf sum 0d0)
    (do ((j 1 (+ j 1)))
        ((> j ma) t)
        (declare (type fixnum j))
      (setf sum (+ sum (* (fref a j) (fref afunc j)))))
    (setf chisq (+ chisq (expt (/ (- (fref y i) sum) (fref sig i)) 2)))) 


  (setq covar (covsrt covar1 ma lista mfit)) 
          ; covar1 is mfitxmfit and lista mfit 
  
  (return (values a covar chisq))))
;-------------------------------------------------------------------------------

(defun covsrt (covar1 ma lista mfit)
 (declare (type (simple-array double-float (* *)) covar1)) 
 (declare (type (simple-array fixnum (*)) lista)) 
 (declare (type fixnum ma mfit))

 (prog ((ncvm 0)  
        (covar (make-array (list ma ma) :element-type 'double-float
                                       :initial-element 0d0)) 
        (swap 0d0))
  (declare (type fixnum ncvm))
  (declare (type double-float swap))
  (declare (type (simple-array double-float (* *)) covar))
  (declare (ignore ncvm))
  

  (do ((i 0 (1+ i)))
      ((> i (1- mfit)) t)
      (declare (type fixnum i))
   (do ((j 0 (1+ j)))
       ((> j (1- mfit)) t)
       (declare (type fixnum j))
     (setf (aref covar i j) (aref covar1 i j))))

  (do ((j 1 (1+ j)))
      ((> j (1- ma)) t)
      (declare (type fixnum j))
   (do ((i (1+ j) (1+ i)))
       ((> i ma) t)
       (declare (type fixnum i))
     (fset (fref covar i j) 0d0)))


  (do ((i 1 (+ i 1)))
      ((> i (1- mfit)) t)
      (declare (type fixnum i))
    (do ((j (1+ i) (+ j 1)))
        ((> j mfit) t)
        (declare (type fixnum j))
      (if (> (fref lista j) (fref lista i)) 
          (setf (aref covar (1- (fref lista j)) (1- (fref lista i))) 
                (fref covar i j))
          (setf (aref covar (1- (fref lista i)) (1- (fref lista j))) 
                (fref covar i j)))))

  (setf swap (fref covar 1 1)) 

  (do ((j 1 (+ j 1)))
      ((> j ma) t)
      (declare (type fixnum j))
    (setf (aref covar 0 (1- j)) (fref covar j j))
    (setf (aref covar (1- j) (1- j)) 0d0)) 

  (fset (fref covar (fref lista 1) (fref lista 1)) swap) 
  (do ((j 2 (+ j 1)))
      ((> j mfit) t)
      (declare (type fixnum j))
    (setf (aref covar (1- (fref lista j)) (1- (fref lista j))) 
          (fref covar 1 j))) 

  (do ((j 2 (+ j 1)))
      ((> j ma) t)
      (declare (type fixnum j))
    (do ((i 1 (+ i 1)))
        ((> i (1- j)) t)
        (declare (type fixnum i))
      (setf (aref covar (1- i) (1- j)) (fref covar j i)))) 

  (return covar)))

;------------------------------------------------------------------------------

(defun svdfit (x y sig a funcs 
                      &key (tol 1.0d-5))
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) sig)) 
 (declare (type (simple-array double-float (*)) a))
 (declare (type double-float tol))

 (prog* ( 
  (ma (length funcs))
  (ndata (array-dimension x 0))

  (u 
   (make-array (list ndata ma) 
               :element-type 'double-float :initial-element 0d0))
  (v 
   (make-array (list ma ma) 
               :element-type 'double-float :initial-element 0d0))
  (w 
   (make-array ma 
               :element-type 'double-float :initial-element 0d0))
  (b 
   (make-array ndata 
               :element-type 'double-float :initial-element 0d0))
  (afunc 
   (make-array ma 
               :element-type 'double-float :initial-element 0d0))
  (tmp 0d0) (wmax 0d0) (thresh 0d0) (chisq 0d0) (sum 0d0))


  (declare (type (simple-array double-float (* *)) v)) 
  (declare (type (simple-array double-float (* *)) u)) 
  (declare (type (simple-array double-float (*)) w)) 
  (declare (type (simple-array double-float (*)) b)) 
  (declare (type (simple-array double-float (*)) afunc)) 
  (declare (type fixnum ndata))
  (declare (type double-float  tmp wmax thresh chisq sum))


  (do ((i 0 (+ i 1)))
      ((> i (1- ndata)) t)
     (do ((j 0 (1+ j)))
         ((> j (1-  ma)) t)
         (declare (type fixnum j))
        (setf (aref afunc j) (dfloat (funcall (nth j funcs) (aref x i)))))
    (setf tmp (/ 1d0 (aref sig i)))
    (do ((j 0 (+ j 1)))
        ((> j (1- ma)) t)
        (declare (type fixnum j))
      (setf (aref u i j) (* (aref afunc j) tmp)))
    (setf (aref b i) (* (aref y i) tmp))) 

  (multiple-value-setq (u w v) (svdcmp u))

  (setf wmax 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- ma)) t)
      (declare (type fixnum j))
    (if (> (aref w j) wmax) (setf wmax (aref w j)))) 

  (setf thresh (* tol wmax)) 
  (do ((j 0 (+ j 1)))
      ((> j (1- ma)) t)
      (declare (type fixnum j))
    (if (< (aref w j) thresh) (setf (aref w j) 0d0))) 

  (setq a (svbksb u w v b))

  (setf chisq 0d0) 
  (do ((i 0 (+ i 1)))
      ((> i (1- ndata)) t)
      (declare (type fixnum i))
     (do ((j 0 (1+ j)))
         ((> j (1- ma)) t)
         (declare (type fixnum j))
        (setf (aref afunc j) (dfloat (funcall (nth j funcs) (aref x i)))))
    (setf sum 0d0)
    (do ((j 0 (+ j 1)))
        ((> j (1- ma)) t)
        (declare (type fixnum j))
      (setf sum (+ sum (* (aref a j) (aref afunc j)))))

    (setf chisq (+ chisq (expt (/ (+ (aref y i) (- sum)) (aref sig i)) 2)))) 
   
  (return (values a u v w chisq))))

;------------------------------------------------------------------------------
(defun svdvar (v ma w)
 (declare (type (simple-array double-float (* *)) v)) 
 (declare (type (simple-array double-float (*)) w)) 
 (declare (type fixnum ma))

 (prog* (
  (ncvm ma)
  (wti (make-array ma :element-type 'double-float :initial-element 0d0))
  (cvm (make-array (list ncvm ncvm) 
                    :element-type 'double-float :initial-element 0d0))
  (sum 0d0))


  (declare (type (simple-array double-float (* *)) cvm)) 
  (declare (type (simple-array double-float (*)) wti)) 
  (declare (type double-float sum))
  (declare (type fixnum ncvm))

  (do ((i 0 (+ i 1)))
      ((> i (1- ma)) t)
      (declare (type fixnum i))
    (setf (aref wti i) 0d0)
    (if (not (= (aref w i) 0d0))
        (setf (aref wti i) (/ 1d0 (* (aref w i) (aref w i)))))) 
  (do ((i 0 (+ i 1)))
      ((> i (1- ma)) t)
      (declare (type fixnum i))
    (do ((j 0 (+ j 1)))
        ((> j i) t)
        (declare (type fixnum j))
      (setf sum 0d0)
      (do ((k 0 (+ k 1)))
          ((> k (1- ma)) t)
          (declare (type fixnum k))
        (setf sum (+ sum (* (* (aref v i k) (aref v j k)) (aref wti k)))))
      (setf (aref cvm i j) sum)
      (setf (aref cvm j i) sum))) 
   
  (return cvm)))

;-----------------------------------------------------------------------------

(defun fpoly-old (x p)
 (declare (type (simple-array double-float (*)) p))
 (declare (type double-float x))
 
 (prog ((np 0))
  (declare (type fixnum np))
  (setq np (array-dimension p 0))
  (setf (aref p 0) 1d0) 

  (do ((j 1 (+ j 1)))
      ((> j (1- np)) t)
      (declare (type fixnum j)) 
    (setf (aref p j) (* (aref p (1- j)) x))) 

  (return p)))

;------------------------------------------------------------------------------

(defun fleg-old (x nl)
 (declare (type double-float x))
 (declare (type fixnum nl))

 (prog ((pl 0d0) (f1 0d0) (f2 0d0) (twox 0d0) (d 0d0))
;  (declare (type (simple-array double-float (*)) pl))
  (declare (type double-float f1 f2 twox d))

  (setq pl (make-array nl :element-type 'double-float :initial-element 0d0))

  (setf (aref pl 0) 1d0) 
  (setf (aref pl 1) x) 

  (when (> nl 2)
   (setf twox (* 2d0 x)) (setf f2 x)
   (setf d 1d0)
   (do ((j 2 (+ j 1)))
       ((> j (1- nl)) t)
       (declare (type fixnum j))
     (setf f1 d)
     (setf f2 (+ f2 twox))
     (setf d (+ d 1))
     (setf (aref pl j) (/ (- (* f2 (aref pl (1- j)))
                             (* f1 (aref pl (1- j))))
                          d)))) 
 
  (return pl)))

;------------------------------------------------------------------------------
;(fproclaim '(special ochisq atry beta))
;(fproclaim '(type (simple-array double-float (*)) atry)) 
;(fproclaim '(type (simple-array double-float (*)) beta)) 
;(fproclaim '(type double-float ochisq))

(defun mrqmin
 (x y sig a lista mfit funcs funcsd alamda)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) sig)) 
 (declare (type (simple-array double-float (*)) a)) 
 (declare (type (simple-array fixnum (*)) lista)) 
 (declare (type fixnum mfit))
 (declare (type double-float alamda))

 (prog* (  
  (ndata (array-dimension x 0))
  (ma (array-dimension lista 0))
  (atry (make-array ma :element-type 'double-float :initial-element 0d0))
  (beta (make-array ma :element-type 'double-float :initial-element 0d0))
  (da (make-array ma :element-type 'double-float :initial-element 0d0))
  (da2 
     (make-array (list ma 1) :element-type 'double-float :initial-element 0d0))
  (covar (make-array (list mfit mfit)
       :element-type 'double-float :initial-element 0d0))
  (alpha (make-array (list mfit mfit)
       :element-type 'double-float :initial-element 0d0))
  (chisq 0d0) (ochisq 0d0)  (kk 0) (ihit 0))



  (declare (type (simple-array double-float (* *)) covar)) 
  (declare (type (simple-array double-float (* *)) alpha)) 
  (declare (type (simple-array double-float (* *)) da2)) 
  (declare (type (simple-array double-float (*)) da atry beta)) 
  (declare (type double-float chisq ochisq))
  (declare (ignore ndata))
  (declare (type fixnum kk ihit))

  
  (when 
   (< alamda 0d0) 
   (setf kk (+ mfit 1))
   (do ((j 1 (+ j 1)))
       ((> j ma) t)
       (declare (type fixnum j))
     (setf ihit 0)
     (do ((k 1 (+ k 1)))
         ((> k mfit) t)
         (declare (type fixnum k))
       (if (= (fref lista k) j) (setf ihit (+ ihit 1))))
     (cond 
      ((= ihit 0) 
       (fset (fref lista kk) j)
       (setf kk (+ kk 1)))
      ((> ihit 1) 
       (error " improper permutation in lista "))))

   (if (not (= kk (1+ ma))) (error " improper permutation in lista. ")) 
   (setf alamda 0.001d0)
   (multiple-value-setq (alpha beta chisq)
                        (mrqcof x y sig a ma lista mfit funcs funcsd))
   (setf ochisq chisq)
   (do ((j 1 (+ j 1)))
       ((> j ma) t)
       (declare (type fixnum j))
     (fset (fref atry j) (fref a j)))) 

  (do ((j 1 (+ j 1)))
      ((> j mfit) t)
      (declare (type fixnum j))
    (do ((k 1 (+ k 1)))
        ((> k mfit) t)
        (declare (type fixnum k))
      (fset (fref covar j k) (fref alpha j k)))

    (fset (fref covar j j) (* (fref alpha j j) (+ 1 alamda)))
    (fset (fref da j) (fref beta j))) 

(do ((j 0 (1+ j))) ((> j (1- ma)) t)
  (setf (aref da2 j 0) (aref da j)))
 
  (multiple-value-setq (covar da2) (gaussj covar da2))

(do ((j 0 (1+ j))) ((> j (1- ma)) t)
  (setf (aref da j) (aref da2 j 0)))

  (when 
   (= alamda 0d0)
   (setq covar (covsrt covar  ma lista mfit)) 
   (go end)) 
  (do ((j 1 (+ j 1)))
      ((> j mfit) t)
      (declare (type fixnum j))
    (fset (fref atry (fref lista j)) (+ (fref a (fref lista j)) (fref da j)))) 
  (multiple-value-setq (covar da chisq)
              (mrqcof x y sig atry ma lista mfit funcs funcsd))
  (cond 
   ((< chisq ochisq)
    (setf alamda (* 0.1d0 alamda)) 
    (setf ochisq chisq)
    (do ((j 1 (+ j 1)))
        ((> j mfit) t)
        (declare (type fixnum j))
      (do ((k 1 (+ k 1)))
          ((> k mfit) t)
          (declare (type fixnum k))
        (fset (fref alpha j k) (fref covar j k)))
      (fset (fref beta j) (fref da j))
      (fset (fref a (fref lista j)) (fref atry (fref lista j)))))
   (t (setf alamda (* 10d0 alamda)) (setf chisq ochisq))) 
end 
  (return (values covar alpha a chisq alamda))))

;------------------------------------------------------------------------------
(defun mrqcof (x y sig a ma lista nalp funcs funcsd)
 (declare (type (simple-array double-float (*)) x)) 
 (declare (type (simple-array double-float (*)) y)) 
 (declare (type (simple-array double-float (*)) sig)) 
 (declare (type (simple-array double-float (*)) dyda)) 
 (declare (type (simple-array fixnum (*)) lista)) 
 (declare (type (simple-array double-float (*)) a)) 
 (declare (ignore nalp))

 (prog* (
  (ndata (array-dimension x 0))
  (mfit (array-dimension lista 0))

  (alpha 
      (make-array (list mfit mfit) :element-type 'double-float
                                   :initial-element 0d0))
  (beta 
      (make-array ma :element-type 'double-float :initial-element 0d0))
  (dyda 
      (make-array ma :element-type 'double-float :initial-element 0d0))
  (argi nil) (ymod 0d0) (chisq 0d0)
  (sig2i 0d0) (dy 0d0) (wt 0d0))



  (declare (type (simple-array double-float (* *)) alpha)) 
  (declare (type (simple-array double-float (*)) beta dyda)) 
  (declare (type double-float chisq sig2i dy wt ymod))
  (declare (type fixnum ndata mfit))
;  (declare (type cons argi))


  (do ((j 1 (+ j 1)))
      ((> j mfit) t)
      (declare (type fixnum j))
    (do ((k 1 (+ k 1)))
        ((> k j) t)
        (declare (type fixnum k))
      (fset (fref alpha j k) 0d0))
    (fset (fref beta j) 0d0)) 

  (setf chisq 0d0) 
  (do ((i 1 (+ i 1)))
      ((> i ndata) t)
      (declare (type fixnum i))
    (setq argi (cons (fref x i) (list-array a)))

    (setq ymod (dfloat (apply funcs argi)))
    (do ((j 1 (1+ j)))
        ((> j ma) t)
        (declare (type fixnum j))
      (fset (fref dyda j) (dfloat (apply (nth (1- j) funcsd) argi))))

    (setf sig2i (/ 1d0 (* (fref sig i) (fref sig i))))
    (setf dy (- (fref y i) ymod))
    (do ((j 1 (+ j 1)))
        ((> j mfit) t)
        (declare (type fixnum j))
      (setf wt (* (fref dyda (fref lista j)) sig2i))
      (do ((k 1 (+ k 1)))
          ((> k j) t)
          (declare (type fixnum k))
        (fset (fref alpha j k) (+ (fref alpha j k)
                                  (* wt (fref dyda (fref lista k))))))

      (fset (fref beta j) (+ (fref beta j) (* dy wt))))

    (setf chisq (+ chisq (* (* dy dy) sig2i)))) 

  (do ((j 2 (+ j 1)))
      ((> j mfit) t)
      (declare (type fixnum j))
    (do ((k 1 (+ k 1)))
        ((> k (1- j)) t)
        (declare (type fixnum k))
      (fset (fref alpha k j) (fref alpha j k)))) 

   
  (return (values alpha beta chisq))))

;-----------------------------------------------------------------------------

(defun fgauss (x a y)
 (declare (type (simple-array double-float (*)) a))
 (declare (type double-float x y))
 
 (prog* (
   (na (array-dimension a 0))
   (dyda (make-array na :element-type 'double-float :initial-element 0d0)) 
   (ex 0d0) (fac 0d0) (arg 0d0))

  (declare (type (simple-array double-float (*)) dyda)) 
  (declare (type fixnum na))
  (declare (type double-float ex fac arg))

  
  (setf y 0d0) 
  (do ((i 0 (+ i 3)))
      ((> i (2- na)) t)
    (setf arg (/ (- x (aref a (+ i 1))) (aref a (+ i 2))))
    (setf ex (exp (- (expt arg 2))))
    (setf fac (* (* (* (aref a i) ex) 2) arg))
    (setf y (+ y (* (aref a i) ex)))
    (setf (aref dyda i) ex)
    (setf (aref dyda (+ i 1)) (/ fac (aref a (+ i 2))))
    (setf (aref dyda (+ i 2)) (/ (* fac arg) (aref a (+ i 2))))) 
  (return dyda)))

;------------------------------------------------------------------------------

(defun medfit (x y)
  (declare (type (simple-array double-float (*)) x)) 
  (declare (type (simple-array double-float (*)) y)) 

 (prog* (
  (ndata (array-dimension x 0))
  (arr (make-array ndata :element-type 'double-float :initial-element 0d0)) 
  (xt (make-array ndata :element-type 'double-float :initial-element 0d0))   
  (yt (make-array ndata :element-type 'double-float :initial-element 0d0))
  (sx 0d0) (sy 0d0) (sxy 0d0) (sxx 0d0) (a 0d0) 
  (b 0d0) (abdev 0d0) (abdevt 0d0)  
  (aa 0d0) (bb 0d0) (chisq 0d0) 
  (del 0d0) (sigb 0d0) (b1 0d0) 
  (f1 0d0) (b2 0d0) (f2 0d0) (f 0d0))


  (declare (type double-float sx sy sxy sxx ab abdev aa bb chisq))
  (declare (type fixnum ndata))
  (declare (type double-float abdevt del sigb b1 f1 b2 f2 f))
  (declare (type (simple-array double-float (*)) arr xt yt)) 
  (declare (special arr xt yt ndata abdevt aa))
;------------
(defun rofunc (b &key (nmax 1000))
 (declare (type double-float b))
 (declare (type fixnum nmax))
 (declare (ignore nmax))

 (prog ((rofunc 0d0) (sum 0d0) (d 0d0) (n1 0) (nml 0) (nmh 0))
  (declare (type double-float rofunc sum d))
  (declare (type fixnum n1 nml nmh))

  (setf n1 (+ ndata 1)) 
  (setf nml (floor (/ n1 2))) 
  (setf nmh (+ n1 (- nml))) 
  (do ((j 0 (+ j 1)))
      ((> j (1- ndata)) t)
      (declare (type fixnum j))
    (setf (aref arr j) (+ (aref yt j) (* (- b) (aref xt j))))) 
  (setq arr (sort1 arr)) 
  (setf aa (* 0.5d0 (+ (aref arr nml) (aref arr nmh)))) 
  (setf sum 0d0) 
  (setf abdevt 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- ndata)) t)
      (declare (type fixnum j))
    (setf d (+ (aref yt j) (- (+ (* b (aref xt j)) aa))))
    (setf abdevt (+ abdevt (abs d)))
    (setf sum (+ sum (* (aref xt j) (signp 1.0d0 d))))) 
  (setf rofunc sum) 
   
  (return (the double-float rofunc))))
;----------------------

  (setf sx 0d0) 
  (setf sy 0d0) 
  (setf sxy 0d0) 
  (setf sxx 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- ndata)) t)
      (declare (type fixnum j))
    (setf (aref xt j) (aref x j))
    (setf (aref yt j) (aref y j))
    (setf sx (+ sx (aref x j)))
    (setf sy (+ sy (aref y j)))
    (setf sxy (+ sxy (* (aref x j) (aref y j))))
    (setf sxx (+ sxx (expt (aref x j) 2)))) 
  (setf del (+ (* (dfloat ndata) sxx) (- (expt sx 2)))) 
  (setf aa (/ (+ (* sxx sy) (* (- sx) sxy)) del)) 
  (setf bb (/ (+ (* (dfloat ndata) sxy) (* (- sx) sy)) del)) 
  (setf chisq 0d0) 
  (do ((j 0 (+ j 1)))
      ((> j (1- ndata)) t)
      (declare (type fixnum j))
    (setf chisq (+ chisq
                   (expt (+ (aref y j) (- (+ aa (* bb (aref x j))))) 2)))) 
  (setf sigb (sqrt (/ chisq del))) 
  (setf b1 bb) 
  (setf f1 (funcall #'rofunc b1)) 
  (setf b2 (+ bb (signp (* 3d0 sigb) f1))) 
  (setf f2 (funcall #'rofunc b2)) 
  label1 
  (when 
   (> (* f1 f2) 0d0)
   (setf bb (+ (* 2d0 b2) (- b1))) (setf b1 b2) (setf f1 f2) (setf b2 bb)
   (setf f2 (funcall #'rofunc b2)) (go label1)) 
  (setf sigb (* 0.01d0 sigb)) 
  label2 
  (when 
   (> (abs (+ b2 (- b1))) sigb)
   (setf bb (* 0.5d0 (+ b1 b2))) 
   (if (or (= bb b1) (= bb b2)) (go label3))
   (setf f (funcall #'rofunc bb))
   (cond 
    ((>= (* f f1) 0d0)
     (setf f1 f) (setf b1 bb))
    (t
     (setf f2 f) (setf b2 bb)))
   (go label2)) 
  label3 
  (setf a aa) 
  (setf b bb) 
  (setf abdev (/ abdevt (dfloat ndata))) 
; this is the return from medfit  ----> 
  (return (values a b abdev))





; end of medfit
))

;-------------------------------------------------------------------------------
; end of nr14.l

