      PROGRAM xbsstep
C     driver for routine bsstep
      INTEGER KMAXX,NMAX,NVAR
      PARAMETER (KMAXX=200,NMAX=50,NVAR=4)
      INTEGER i,kmax,kount,nbad,nok,nrhs
      REAL bessj,bessj0,bessj1
      REAL dxsav,eps,h1,hmin,x1,x2,x,y,ystart(NVAR)
      COMMON /path/ kmax,kount,dxsav,x(KMAXX),y(NMAX,KMAXX)
      COMMON nrhs
      EXTERNAL derivs,bsstep
      nrhs=0
      x1=1.0
      x2=10.0
      ystart(1)=bessj0(x1)
      ystart(2)=bessj1(x1)
      ystart(3)=bessj(2,x1)
      ystart(4)=bessj(3,x1)
      eps=1.0e-4
      h1=.1
      hmin=0.0
      kmax=100
      dxsav=(x2-x1)/20.0
      call odeint(ystart,NVAR,x1,x2,eps,h1,hmin,nok,nbad,derivs,bsstep)
      write(*,'(/1x,a,t30,i3)') 'Successful steps:',nok
      write(*,'(1x,a,t30,i3)') 'Bad steps:',nbad
      write(*,'(1x,a,t30,i3)') 'Function evaluations:',nrhs
      write(*,'(1x,a,t30,i3)') 'Stored intermediate values:',kount
      write(*,'(/1x,t9,a,t20,a,t33,a)') 'X','Integral','BESSJ(3,X)'
      do 11 i=1,kount
        write(*,'(1x,f10.4,2x,2f14.6)') x(i),y(4,i),bessj(3,x(i))
11    continue
      END

      SUBROUTINE derivs(x,y,dydx)
      INTEGER nrhs
      REAL x,y(*),dydx(*)
      COMMON nrhs
      nrhs=nrhs+1
      dydx(1)=-y(2)
      dydx(2)=y(1)-(1.0/x)*y(2)
      dydx(3)=y(2)-(2.0/x)*y(3)
      dydx(4)=y(3)-(3.0/x)*y(4)
      return
      END
