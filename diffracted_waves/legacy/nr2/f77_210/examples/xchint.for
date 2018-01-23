      PROGRAM xchint
C     driver for routine chint
      INTEGER NVAL
      REAL PIO2
      PARAMETER(NVAL=40, PIO2=1.5707963)
      INTEGER i,mval
      REAL a,b,chebev,fint,func,x,c(NVAL),cint(NVAL)
      EXTERNAL fint,func
      a=-PIO2
      b=PIO2
      call chebft(a,b,c,NVAL,func)
C     test integral
10    write(*,*) 'How many terms in Chebyshev evaluation?'
      write(*,'(1x,a,i2,a)') 'Enter n between 6 and ',NVAL,
     *     '. Enter n=0 to END.'
      read(*,*) mval
      if ((mval.le.0).or.(mval.gt.NVAL)) goto 20
      call chint(a,b,c,cint,mval)
      write(*,'(1x,t10,a,t19,a,t29,a)') 'X','Actual','Cheby. Integ.'
      do 11 i=-8,8,1
        x=i*PIO2/10.0
        write(*,'(1x,3f12.6)') x,fint(x)-fint(-PIO2),
     *       chebev(a,b,cint,mval,x)
11    continue
      goto 10
20    END

      REAL FUNCTION func(x)
      REAL x
      func=(x**2)*(x**2-2.0)*sin(x)
      END

      REAL FUNCTION fint(x)
C     integral of FUNC
      REAL x
      fint=4.0*x*((x**2)-7.0)*sin(x)-((x**4)-14.0*(x**2)+28.0)*cos(x)
      END
