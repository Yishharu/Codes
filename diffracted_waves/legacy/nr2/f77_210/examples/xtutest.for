      PROGRAM xtutest
C     driver for routine tutest
      INTEGER NPTS,NSHFT,MPTS
      REAL EPS,VAR1,VAR2
      PARAMETER(NPTS=5000,MPTS=1000,EPS=0.02,VAR1=1.0,
     *     VAR2=4.0,NSHFT=10)
      INTEGER i,idum,j
      REAL data1(NPTS),data2(MPTS),fctr1,fctr2,gasdev,prob,shift,t
C     generate two Gaussian distributions of different variance
      idum=-51773
      fctr1=sqrt(VAR1)
      do 11 i=1,NPTS
        data1(i)=fctr1*gasdev(idum)
11    continue
      fctr2=sqrt(VAR2)
      do 12 i=1,MPTS
        data2(i)=(NSHFT/2.0)*EPS+fctr2*gasdev(idum)
12    continue
      write(*,'(1x,a,f6.2)') 'Distribution #1 : variance = ',VAR1
      write(*,'(1x,a,f6.2/)') 'Distribution #2 : variance = ',VAR2
      write(*,'(1x,t4,a,t18,a,t25,a)') 'Shift','T','Probability'
      do 14 i=1,NSHFT+1
        call tutest(data1,NPTS,data2,MPTS,t,prob)
        shift=(i-1)*EPS
        write(*,'(1x,f6.2,2f12.2)') shift,t,prob
        do 13 j=1,NPTS
          data1(j)=data1(j)+EPS
13      continue
14    continue
      END
