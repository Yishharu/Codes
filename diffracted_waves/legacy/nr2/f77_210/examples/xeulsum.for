      PROGRAM xeulsum
C     driver for routine eulsum
      INTEGER NVAL
      PARAMETER (NVAL=40)
      INTEGER i,j,mval
      REAL sum,term,x,xpower,wksp(NVAL)
C     evaluate ln(1+x)=x-x^2/2+x^3/3-x^4/4...  for -1<x<1
10    write(*,*) 'How many terms in polynomial?'
      write(*,'(1x,a,i2,a)') 'Enter n between 1 and ',NVAL,
     *     '. Enter n=0 to END.'
      read(*,*) mval
      if ((mval.le.0).or.(mval.gt.NVAL)) stop
      write(*,'(1x,t9,a1,t18,a6,t28,a10)') 'X','Actual','Polynomial'
      do 12 i=-8,8,1
        x=i/10.0
        sum=0.0
        xpower=-1
        do 11 j=1,mval
          xpower=-x*xpower
          term=xpower/j
          call eulsum(sum,term,j,wksp)
11      continue
        write(*,'(3f12.6)') x,log(1.0+x),sum
12    continue
      goto 10
      END
