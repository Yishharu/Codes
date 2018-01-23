      PROGRAM xpcshft
C     driver for routine pcshft
      INTEGER NVAL
      REAL PIO2
      PARAMETER(NVAL=40, PIO2=1.5707963)
      INTEGER i,j,mval
      REAL a,b,func,poly,x,c(NVAL),d(NVAL)
      EXTERNAL func
      a=-PIO2
      b=PIO2
      call chebft(a,b,c,NVAL,func)
10    write(*,*) 'How many terms in Chebyshev evaluation?'
      write(*,'(1x,a,i2,a)') 'Enter n between 6 and ',NVAL,
     *     '. Enter n=0 to END.'
      read(*,*) mval
      if ((mval.le.0).or.(mval.gt.NVAL)) goto 20
      call chebpc(c,d,mval)
      call pcshft(a,b,d,mval)
C     test shifted polynomial
      write(*,'(1x,t10,a,t19,a,t29,a)') 'X','Actual','Polynomial'
      do 12 i=-8,8,1
        x=i*PIO2/10.0
        poly=d(mval)
        do 11 j=mval-1,1,-1
          poly=poly*x+d(j)
11      continue
        write(*,'(1x,3f12.6)') x,func(x),poly
12    continue
      goto 10
20    END

      REAL FUNCTION func(x)
      REAL x
      func=(x**2)*(x**2-2.0)*sin(x)
      END
