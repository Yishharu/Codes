      PROGRAM xrk4
C     driver for routine rk4
      INTEGER N
      PARAMETER(N=4)
      INTEGER i,j
      REAL bessj,bessj0,bessj1
      REAL h,x,y(N),dydx(N),yout(N)
      EXTERNAL derivs
      x=1.0
      y(1)=bessj0(x)
      y(2)=bessj1(x)
      y(3)=bessj(2,x)
      y(4)=bessj(3,x)
      call derivs(x,y,dydx)
      write(*,'(/1x,a,t19,a,t31,a,t43,a,t55,a)')
     *     'Bessel Function:','J0','J1','J3','J4'
      do 11 i=1,5
        h=0.2*i
        call rk4(y,dydx,N,x,h,yout,derivs)
        write(*,'(/1x,a,f6.2)') 'For a step size of:',h
        write(*,'(1x,a10,4f12.6)') 'RK4:',(yout(j),j=1,4)
        write(*,'(1x,a10,4f12.6)') 'Actual:',bessj0(x+h),
     *       bessj1(x+h),bessj(2,x+h),bessj(3,x+h)
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
