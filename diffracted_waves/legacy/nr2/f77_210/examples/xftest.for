      PROGRAM xftest
C     driver for routine ftest
      INTEGER NPTS,NVAL,MPTS
      REAL EPS
      PARAMETER(NPTS=1000,MPTS=500,EPS=0.01,NVAL=10)
      INTEGER i,idum,j
      REAL f,factor,gasdev,prob,var
      REAL data1(NPTS),data2(MPTS),data3(MPTS)
C     generate two Gaussian distributions with
C     different variances
      idum=-13
      do 11 j=1,NPTS
        data1(j)=gasdev(idum)
11    continue
      do 12 j=1,MPTS
        data2(j)=gasdev(idum)
12    continue
      write(*,'(1x,t5,a,f5.2)') 'Variance 1 = ',1.0
      write(*,'(1x,t5,a,t21,a,t30,a)')
     *     'Variance 2','Ratio','Probability'
      do 14 i=1,NVAL+1
        var=1.0+(i-1)*EPS
        factor=sqrt(var)
        do 13 j=1,MPTS
          data3(j)=factor*data2(j)
13      continue
        call ftest(data1,NPTS,data3,MPTS,f,prob)
        write(*,'(1x,f11.4,2x,2f12.4)') var,f,prob
14    continue
      END
