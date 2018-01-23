      PROGRAM xkstwo
C     driver for routine kstwo
      INTEGER N1,N2
      REAL EPS
      PARAMETER(N1=2000,N2=1000,EPS=0.1)
      INTEGER i,idum,j
      REAL d,data1(N1),data2(N2),factr,gasdev,prob,var
      idum=-1357
      do 11 j=1,N1
        data1(j)=gasdev(idum)
11    continue
      write(*,'(/1x,t6,a,t26,a,t46,a/)')
     *     'Variance Ratio','K-S Statistic','Probability'
      do 13 i=1,11
        var=1.0+(i-1)*EPS
        factr=sqrt(var)
        do 12 j=1,N2
          data2(j)=factr*gasdev(idum)
12      continue
        call kstwo(data1,N1,data2,N2,d,prob)
        write(*,'(1x,f15.6,f19.6,e20.4)') var,d,prob
13    continue
      END
