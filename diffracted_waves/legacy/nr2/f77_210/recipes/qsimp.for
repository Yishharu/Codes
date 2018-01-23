      SUBROUTINE qsimp(func,a,b,s)
      INTEGER JMAX
      REAL a,b,func,s,EPS
      EXTERNAL func
      PARAMETER (EPS=1.e-6, JMAX=20)
CU    USES trapzd
      INTEGER j
      REAL os,ost,st
      ost=-1.e30
      os= -1.e30
      do 11 j=1,JMAX
        call trapzd(func,a,b,st,j)
        s=(4.*st-ost)/3.
        if (j.gt.5) then
          if (abs(s-os).lt.EPS*abs(os).or.(s.eq.0..and.os.eq.0.)) return
        endif
        os=s
        ost=st
11    continue
      pause 'too many steps in qsimp'
      END
