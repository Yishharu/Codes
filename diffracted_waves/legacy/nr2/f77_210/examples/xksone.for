      PROGRAM xksone
C     driver for routine ksone
      INTEGER NPTS
      REAL EPS
      PARAMETER(NPTS=1000,EPS=0.1)
      INTEGER i,idum,j
      REAL d,data(NPTS),factr,gasdev,prob,var
      EXTERNAL func
      idum=-5
      write(*,'(/1x,t5,a,t24,a,t44,a/)')
     *     'Variance Ratio','K-S Statistic','Probability'
      do 12 i=1,11
        var=1.0+(i-1)*EPS
        factr=sqrt(var)
        do 11 j=1,NPTS
          data(j)=factr*abs(gasdev(idum))
11      continue
        call ksone(data,NPTS,func,d,prob)
        write(*,'(1x,f14.6,f18.6,e20.4)') var,d,prob
12    continue
      END

      REAL FUNCTION func(x)
      REAL erf,x,y
      y=x/sqrt(2.0)
      func=erf(y)
      END
