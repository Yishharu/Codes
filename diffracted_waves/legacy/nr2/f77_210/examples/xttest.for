      PROGRAM xttest
C     driver for routine ttest
      INTEGER NPTS,NSHFT,MPTS
      REAL EPS
      PARAMETER(NPTS=1024, MPTS=512, EPS=0.02,NSHFT=10)
      INTEGER i,idum,j
      REAL data1(NPTS),data2(MPTS),gasdev,prob,shift,t
C     generate Gaussian distributed data
      idum=-5
      do 11 i=1,NPTS
        data1(i)=gasdev(idum)
11    continue
      do 12 i=1,MPTS
        data2(i)=(NSHFT/2.0)*EPS+gasdev(idum)
12    continue
      write(*,'(/1x,t4,a,t18,a,t25,a)') 'Shift','T','Probability'
      do 14 i=1,NSHFT+1
        call ttest(data1,NPTS,data2,MPTS,t,prob)
        shift=(i-1)*EPS
        write(*,'(1x,f6.2,2f12.2)') shift,t,prob
        do 13 j=1,NPTS
          data1(j)=data1(j)+EPS
13      continue
14    continue
      END
