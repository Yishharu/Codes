      PROGRAM xrkdumb
C     driver for routine rkdumb
      INTEGER NSTEP,NVAR
      PARAMETER(NVAR=4,NSTEP=150)
      INTEGER i,j
      REAL bessj,bessj0,bessj1
      REAL x(200),x1,x2,y(50,200),vstart(NVAR)
      COMMON /path/ x,y
      EXTERNAL derivs
      x1=1.0
      vstart(1)=bessj0(x1)
      vstart(2)=bessj1(x1)
      vstart(3)=bessj(2,x1)
      vstart(4)=bessj(3,x1)
      x2=20.0
      call rkdumb(vstart,NVAR,x1,x2,NSTEP,derivs)
      write(*,'(/1x,t9,a,t17,a,t31,a/)') 'X','Integrated','BESSJ3'
      do 11 i=1,(NSTEP/10)
        j=10*i
        write(*,'(1x,f10.4,2x,2f12.6)') x(j),y(4,j),bessj(3,x(j))
11    continue
      END

      SUBROUTINE derivs(x,y,dydx)
      REAL x,y(*),dydx(*)
      dydx(1)=-y(2)
      dydx(2)=y(1)-(1.0/x)*y(2)
      dydx(3)=y(2)-(2.0/x)*y(3)
      dydx(4)=y(3)-(3.0/x)*y(4)
      return
      END
