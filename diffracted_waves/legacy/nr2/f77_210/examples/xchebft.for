      PROGRAM xchebft
C     driver for routine chebft
      INTEGER NVAL
      REAL PIO2,EPS
      PARAMETER(NVAL=40, PIO2=1.5707963, EPS=1E-6)
      INTEGER i,j,mval
      REAL a,b,dum,f,func,t0,t1,term,x,y,c(NVAL)
      EXTERNAL func
      a=-PIO2
      b=PIO2
      call chebft(a,b,c,NVAL,func)
C     test result
10    write(*,*) 'How many terms in Chebyshev evaluation?'
      write(*,'(1x,a,i2,a)') 'Enter n between 6 and ',NVAL,
     *     '. Enter n=0 to END.'
      read(*,*) mval
      if ((mval.le.0).or.(mval.gt.NVAL)) goto 20
      write(*,'(1x,t10,a,t19,a,t28,a)') 'X','Actual','Chebyshev fit'
      do 12 i=-8,8,1
        x=i*PIO2/10.0
        y=(x-0.5*(b+a))/(0.5*(b-a))
C     evaluate Chebyshev polynomial without using routine CHEBEV
        t0=1.0
        t1=y
        f=c(2)*t1+c(1)*0.5
        do 11 j=3,mval
          dum=t1
          t1=2.0*y*t1-t0
          t0=dum
          term=c(j)*t1
          f=f+term
11      continue
        write(*,'(1x,3f12.6)') x,func(x),f
12    continue
      goto 10
20    END

      REAL FUNCTION func(x)
      REAL x
      func=(x**2)*(x**2-2.0)*sin(x)
      END
