      PROGRAM xtptest
C     driver for routine tptest
      INTEGER NPTS,NSHFT
      REAL ANOISE,EPS
      PARAMETER(NPTS=500,EPS=0.01,NSHFT=10,ANOISE=0.3)
      INTEGER i,idum,j
      REAL ave1,ave2,ave3,gasdev,offset,prob1,prob2,shift,
     *     t1,t2,var1,var2,var3
      REAL data1(NPTS),data2(NPTS),data3(NPTS)
      idum=-5
      write(*,'(1x,t18,a,t46,a)') 'Correlated:','Uncorrelated:'
      write(*,'(1x,t4,a,t18,a,t25,a,t46,a,t53,a)')
     *     'Shift','T','Probability','T','Probability'
      offset=(NSHFT/2)*EPS
      do 11 j=1,NPTS
        data1(j)=gasdev(idum)
        data2(j)=data1(j)+ANOISE*gasdev(idum)
        data3(j)=gasdev(idum)
        data3(j)=data3(j)+ANOISE*gasdev(idum)
11    continue
      call avevar(data1,NPTS,ave1,var1)
      call avevar(data2,NPTS,ave2,var2)
      call avevar(data3,NPTS,ave3,var3)
      do 12 j=1,NPTS
        data1(j)=data1(j)-ave1+offset
        data2(j)=data2(j)-ave2
        data3(j)=data3(j)-ave3
12    continue
      do 14 i=1,NSHFT+1
        shift=i*EPS
        do 13 j=1,NPTS
          data2(j)=data2(j)+EPS
          data3(j)=data3(j)+EPS
13      continue
        call tptest(data1,data2,NPTS,t1,prob1)
        call tptest(data1,data3,NPTS,t2,prob2)
        write(*,'(1x,f6.2,2x,2f12.4,4x,2f12.4)')
     *       shift,t1,prob1,t2,prob2
14    continue
      END
