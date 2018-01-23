; nr01.l
; Preliminaries
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Routines translated with permission by Kevin A. Broughan from ;;;;;;;;;;;
;;Numerical Recipies in Fortran Copyright (c) Numerical Recipies 1986, 1989;;;;
;;;;;;;;;;;;;;;Modified by Ken Olum for Common Lisp, April 1996;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package "USER")
; functions:

;	flmoon: phases of the moon, calculated by date
;	julday: julian day number, calculated by date
;	calcat: calendar date, calculated from julian day number
;------------------------------------------------------------------------------
(defun flmoon (n nph)
 (declare (type fixnum n nph))


 (prog ((jd 0) (frac 0d0) (rad 0d0) (t0 0d0) 
        (c 0d0) (as 0d0) (am 0d0) (xtra 0d0) (t2 0d0) (i 0))
  (declare (type integer jd i))
  (declare (type double-float frac rad t0 t2 c as am xtra ))

  (setq rad 0.017453d0) 
  (setf c (dfloat (+ n (/ nph 4)))) 
  (setf t0 (/ c 1236.849d0)) 
  (setf t2 (expt t0 2)) 
  (setf as (+ 359.2242d0 (* 29.10535d0 c))) 
  (setf am (+ (+ 306.0252d0 (* 385.8169d0 c)) (* 0.01073d0 t2))) 
  (setf jd (+ (+ 2415020 (* 28 n)) (* 7 nph))) 
  (setf xtra (+ (+ 0.75933d0 (* 1.530589d0 c))
                (* (+ 1.178d-4 (* -1.55d-7 t0))
                   t2))) 
  (cond 
   ((or (= nph 0) (= nph 2))
    (setf xtra (+ (+ xtra
                    (* (+ 0.1734d0 (* -3.93d-4 t0))
                       (sin (* rad as))))
                 (* -0.4068d0 (sin (* rad am))))))
   
   ((or (= nph 1) (= nph 3))
    (setf xtra (+ (+ xtra
                    (* (+ 0.1721d0 (* -4.d-4 t0))
                       (sin (* rad as))))
                 (* -0.628d0 (sin (* rad am))))))
   (t
    (error " nph is unknown. ")))
 
  (if (>= xtra 0)
      (setf i (floor xtra))
      (setf i (floor (1- xtra)))) 

  (setf jd (+ jd i)) 
  (setf frac (- xtra i)) 
 
  (return (values jd frac))))

;-----------------------------------------------------------------------------
(defun julday (mm id iyyy)
 (declare (fixnum mm id iyyy))

 (prog ((igreg 0) (jy 0) (jm 0) (julday 0) (ja 0))
  (declare (fixnum igreg jy jm julday ja))

  (setq igreg (+ 15 (* 31 (+ 10  (* 12 1582)))))
  (if (= iyyy 0) (error " there is not year zero ")) 
  (if (< iyyy 0) (setf iyyy (1+ iyyy))) 

  (cond 
   ((> mm 2) 
    (setf jy iyyy) 
    (setf jm (1+ mm)))
   (t 
    (setf jy (1- iyyy)) 
    (setf jm (+ mm 13)))) 

  (setf julday (+ (+ (+ (floor (* 365.25d0 jy)) (floor (* 30.6001d0 jm))) id)
                  1720995))
 
  (when (>= (+ id (* 31 (+ mm (* 12 iyyy)))) igreg)
   (setf ja (floor (* 0.01d0 jy)))
   (setf julday (+ (- (+ julday 2) ja) (floor (* 0.25d0 ja))))) 
  
  (return (the fixnum julday))))

;-----------------------------------------------------------------------------
(defun caldat (julian)
 (declare (type fixnum julian))

 (prog ((igreg 0) (id 0) (iyyy 0) (jb 0) (jc 0) 
        (ja 0) (jd 0) (je 0) (jalpha 0) (mm 0))
  (declare (type fixnum igreg mm id iyyy jb jc ja jalpha))

  (setq igreg 2299161) 
  (cond 
   ((>= julian igreg) 
    (setf jalpha (floor
                      (/ (- (- julian 1867216) 0.25d0) 36524.25d0)))
    (setf ja (- (+ (+ julian 1) jalpha) (floor (* 0.25d0 jalpha)))))
   (t
    (setf ja julian)))
  (setf jb (+ ja 1524)) 
  (setf jc (floor
                 (+ 6680
                    (/ (- (- jb 2439870) 122.0999) 365.25)))) 
  (setf jd (+ (* 365 jc) (floor (* 0.25d0 jc)))) 
  (setf je (floor (/ (- jb jd) 30.6001d0))) 
  (setf id (- (- jb jd) (floor (* 30.6001d0 je)))) 
  (setf mm (1- je)) 
  (if (> mm 12) (setf mm (- mm 12))) 
  (setf iyyy (- jc 4715)) 
  (if (> mm 2) (setf iyyy (1- iyyy))) 
  (if (<= iyyy 0) (setf iyyy (1- iyyy))) 

  (return (values  mm id iyyy))))
;-----------------------------------------------------------------------------
; end of nr01,k
