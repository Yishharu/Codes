      PROGRAM xquad3d
C     driver for routine quad3d
      COMMON xmax
      REAL xmax
      INTEGER NVAL
      REAL PI
      PARAMETER(PI=3.1415926,NVAL=10)
      INTEGER i
      REAL s,xmin
      write(*,*) 'Integral of r^2 over a spherical volume'
      write(*,'(/4x,a,t14,a,t24,a)') 'Radius','QUAD3D','Actual'
      do 11 i=1,NVAL
        xmax=0.1*i
        xmin=-xmax
        call quad3d(xmin,xmax,s)
        write(*,'(1x,f8.2,2f10.4)') xmax,s,4.0*PI*(xmax**5)/5.0
11    continue
      END

      REAL FUNCTION func(x,y,z)
      REAL x,y,z
      func=x**2+y**2+z**2
      END

      REAL FUNCTION z1(x,y)
      REAL x,y
      COMMON xmax
      REAL xmax
      z1=-sqrt(abs(xmax**2-x**2-y**2))
      END

      REAL FUNCTION z2(x,y)
      REAL x,y
      COMMON xmax
      REAL xmax
      z2=sqrt(abs(xmax**2-x**2-y**2))
      END

      REAL FUNCTION y1(x)
      REAL x
      COMMON xmax
      REAL xmax
      y1=-sqrt(abs(xmax**2-x**2))
      END

      REAL FUNCTION y2(x)
      REAL x
      COMMON xmax
      REAL xmax
      y2=sqrt(abs(xmax**2-x**2))
      END

      SUBROUTINE qgausx(func,a,b,ss)
      REAL x(5),w(5)
      INTEGER j
      REAL a,b,dx,ss,xm,xr
      REAL func
      EXTERNAL func
      DATA x/.1488743389,.4333953941,.6794095682,
     *     .8650633666,.9739065285/
      DATA w/.2955242247,.2692667193,.2190863625,
     *     .1494513491,.0666713443/
      xm=0.5*(b+a)
      xr=0.5*(b-a)
      ss=0
      do 11 j=1,5
        dx=xr*x(j)
        ss=ss+w(j)*(func(xm+dx)+func(xm-dx))
11    continue
      ss=xr*ss
      return
      END

      SUBROUTINE qgausy(func,a,b,ss)
      REAL x(5),w(5)
      INTEGER j
      REAL a,b,dx,ss,xm,xr
      REAL func
      EXTERNAL func
      DATA x/.1488743389,.4333953941,.6794095682,
     *     .8650633666,.9739065285/
      DATA w/.2955242247,.2692667193,.2190863625,
     *     .1494513491,.0666713443/
      xm=0.5*(b+a)
      xr=0.5*(b-a)
      ss=0
      do 11 j=1,5
        dx=xr*x(j)
        ss=ss+w(j)*(func(xm+dx)+func(xm-dx))
11    continue
      ss=xr*ss
      return
      END

      SUBROUTINE qgausz(func,a,b,ss)
      REAL x(5),w(5)
      INTEGER j
      REAL a,b,dx,ss,xm,xr
      REAL func
      EXTERNAL func
      DATA x/.1488743389,.4333953941,.6794095682,
     *     .8650633666,.9739065285/
      DATA w/.2955242247,.2692667193,.2190863625,
     *     .1494513491,.0666713443/
      xm=0.5*(b+a)
      xr=0.5*(b-a)
      ss=0
      do 11 j=1,5
        dx=xr*x(j)
        ss=ss+w(j)*(func(xm+dx)+func(xm-dx))
11    continue
      ss=xr*ss
      return
      END
