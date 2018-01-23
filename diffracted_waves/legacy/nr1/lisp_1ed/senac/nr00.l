; nr00.l
; support functions and macros for Numerical Recipies in Common Lisp:
;	dfloat
;	fproclaim
;	fref
;	fset
;	real-remainder
;	ffuncall
;	list-array
;	list-array1
;----------------------------------------------------------------------------
(defun dfloat (x) 
 (declare (type number x))
 (the double-float (coerce x 'double-float)))

(defmacro fproclaim (x) `(eval-when (compile load eval) (proclaim ,x)))

(defmacro fref (arr &rest indices)
  `(aref ,arr ,@(mapcar #'(lambda (x) (list '1- x)) indices)))

(defmacro fset (a b) 
  `(setf (fref ,(second a) ,@(cddr a)) ,b))

(defun real-remainder (a b) (- a (* b (floor (/ a b)))))

(defun ffuncall (fun arg)
   (make-array (array-dimension arg 0) 
               :element-type 'double-float 
               :initial-contents
                     (cdr (funcall fun (list-array arg)))))
(defun list-array (a)
 (prog (a1)
  (setq a1 (make-array (apply #'* (array-dimensions a)) 
                       :displaced-to a
                       :element-type (array-element-type a)))
 (return (list-array1 a1))))

(defun list-array1 (a)
 (let ((ret nil))
      (do ((i (1- (array-dimension a 0)) (1- i))) ((< i 0) ret)
         (setq ret (cons (aref a i) ret)))))

;----------------------------------------------------------------------------
; end of nr00.l

