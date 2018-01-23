      SUBROUTINE qtrap(func,a,b,s)
      INTEGER JMAX
      REAL a,b,func,s,EPS
      EXTERNAL func
      PARAMETER (EPS=1.e-6, JMAX=20)
CU    USES trapzd
      INTEGER j
      REAL olds
      olds=-1.e30
      do 11 j=1,JMAX
        call trapzd(func,a,b,s,j)
        if (j.gt.5) then
          if (abs(s-olds).lt.EPS*abs(olds).or.(s.eq.0..and.olds.eq.0.)) 
     *return
        endif
        olds=s
11    continue
      pause 'too many steps in qtrap'
      END
