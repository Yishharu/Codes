      PROGRAM xtrapzd
C     driver for routine trapzd
      INTEGER NMAX
      REAL PIO2
      PARAMETER(NMAX=14, PIO2=1.5707963)
      INTEGER i
      REAL a,b,fint,func,s
      EXTERNAL func
      a=0.0
      b=PIO2
      write(*,'(1x,a)') 'Integral of FUNC with 2^(n-1) points'
      write(*,'(1x,a,f10.6)') 'Actual value of integral is',
     *     fint(b)-fint(a)
      write(*,'(1x,t7,a,t16,a)') 'n','Approx. Integral'
      do 11 i=1,NMAX
        call trapzd(func,a,b,s,i)
        write(*,'(1x,i6,f20.6)') i,s
11    continue
      END

      REAL FUNCTION func(x)
      REAL x
      func=(x**2)*(x**2-2.0)*sin(x)
      END

      REAL FUNCTION fint(x)
C     integral of FUNC
      REAL x
      fint=4.0*x*((x**2)-7.0)*sin(x)-((x**4)-14.0*(x**2)+28.0)*cos(x)
      END
