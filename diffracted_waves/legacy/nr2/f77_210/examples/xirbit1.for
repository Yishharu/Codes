      PROGRAM xirbit1
C     driver for routine irbit1
      INTEGER NBIN,NTRIES
      PARAMETER(NBIN=15,NTRIES=10000)
      INTEGER i,idum,iflg,ipts,irbit1,iseed,j,n
      REAL delay(NBIN)
      iseed=12345
      do 11 i=1,NBIN
        delay(i)=0.0
11    continue
      ipts=0
      do 13 i=1,NTRIES
        if (irbit1(iseed).eq.1) then
          ipts=ipts+1
          iflg=0
          do 12 j=1,NBIN
            idum=irbit1(iseed)
            if ((idum.eq.1).and.(iflg.eq.0)) then
              iflg=1
              delay(j)=delay(j)+1.0
            endif
12        continue
        endif
13    continue
      write(*,*) 'Distribution of runs of N zeros'
      write(*,'(1x,t7,a,t16,a,t38,a)') 'N','Probability','Expected'
      do 14 n=1,NBIN
        write(*,'(1x,i6,f18.6,f20.6)')
     *       n-1,delay(n)/ipts,1/(2.0**n)
14    continue
      END
