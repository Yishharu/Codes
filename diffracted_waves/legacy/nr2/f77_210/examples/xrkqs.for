      PROGRAM xrkqs
C     driver for routine rkqs
      INTEGER N
      PARAMETER(N=4)
      INTEGER i,j
      REAL bessj,bessj0,bessj1
      REAL eps,hdid,hnext,htry,x,y(N),dydx(N),dysav(N),ysav(N),yscal(N)
      EXTERNAL derivs
      x=1.0
      ysav(1)=bessj0(x)
      ysav(2)=bessj1(x)
      ysav(3)=bessj(2,x)
      ysav(4)=bessj(3,x)
      call derivs(x,ysav,dysav)
      do 11 i=1,N
        yscal(i)=1.0
11    continue
      htry=0.6
      write(*,'(/1x,t8,a,t19,a,t31,a,t43,a)')
     *     'eps','htry','hdid','hnext'
      do 13 i=1,15
        eps=exp(-float(i))
        x=1.0
        do 12 j=1,N
          y(j)=ysav(j)
          dydx(j)=dysav(j)
12      continue
        call rkqs(y,dydx,n,x,htry,eps,yscal,hdid,hnext,derivs)
        write(*,'(2x,e12.4,f8.2,2x,2f12.6)') eps,htry,hdid,hnext
13    continue
      END

      SUBROUTINE derivs(x,y,dydx)
      REAL x,y(*),dydx(*)
      dydx(1)=-y(2)
      dydx(2)=y(1)-(1.0/x)*y(2)
      dydx(3)=y(2)-(2.0/x)*y(3)
      dydx(4)=y(3)-(3.0/x)*y(4)
      return
      END
