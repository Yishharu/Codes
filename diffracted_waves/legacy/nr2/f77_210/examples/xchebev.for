      PROGRAM xchebev
C     driver for routine chebev
      INTEGER NVAL
      REAL PIO2
      PARAMETER(NVAL=40, PIO2=1.5707963)
      INTEGER i,mval
      REAL a,b,chebev,func,x,c(NVAL)
      EXTERNAL func
      a=-PIO2
      b=PIO2
      call chebft(a,b,c,NVAL,func)
C     test Chebyshev evaluation routine
10    write(*,*) 'How many terms in Chebyshev evaluation?'
      write(*,'(1x,a,i2,a)') 'Enter n between 6 and ',NVAL,
     *     '. Enter n=0 to END.'
      read(*,*) mval
      if ((mval.le.0).or.(mval.gt.NVAL)) goto 20
      write(*,'(1x,t10,a,t19,a,t28,a)') 'X','Actual','Chebyshev fit'
      do 11 i=-8,8,1
        x=i*PIO2/10.0
        write(*,'(1x,3f12.6)') x,func(x),chebev(a,b,c,mval,x)
11    continue
      goto 10
20    END

      REAL FUNCTION func(x)
      REAL x
      func=(x**2)*(x**2-2.0)*sin(x)
      END
