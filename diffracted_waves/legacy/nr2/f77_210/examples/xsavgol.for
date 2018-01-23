      PROGRAM xsavgol
C     driver for routine savgol
      INTEGER NMAX,NTEST
      PARAMETER(NMAX=1000,NTEST=6)
      INTEGER i,j,m,nl,np,nr,nltest(NTEST),nrtest(NTEST),mtest(NTEST)
      REAL c(NMAX),sum
      CHARACTER*39 ans(2*NTEST)
      DATA mtest /2,2,2,2,4,4/
      DATA nltest /2,3,4,5,4,5/
      DATA nrtest /2,1,0,5,4,5/
      DATA ans /'                         -0.086  0.343 ',
     *     ' 0.486  0.343 -0.086',
     *     '                 -0.143  0.171  0.343  ','0.371  0.257',
     *     '          0.086 -0.143 -0.086  0.257  0','.886',
     *     ' -0.084  0.021  0.103  0.161  0.196  0.',
     *     '207  0.196  0.161  0.103  0.021 -0.084',
     *     '          0.035 -0.128  0.070  0.315  0',
     *     '.417  0.315  0.070 -0.128  0.035',
     *     '  0.042 -0.105 -0.023  0.140  0.280  0.',
     *     '333  0.280  0.140 -0.023 -0.105  0.042'/
      write(*,*) 'M nl nr'
      write(*,'(t24,a)') 'Sample Savitzky-Golay Coefficients'
      do 13 i=1,NTEST
        m=mtest(i)
        nl=nltest(i)
        nr=nrtest(i)
        np=nl+nr+1
        call savgol(c,np,nl,nr,0,m)
        sum=0.
        do 11 j=1,np
          sum=sum+c(j)
11      continue
        write(*,'(1x,3i2)') m,nl,nr
        write(*,'(1x,a2,$)') '  '
        do 12 j=nl,4
          write(*,'(1x,a7,$)') ' '
12      continue
        write(*,'(11f7.3)') (c(j),j=nl+1,1,-1),(c(np-j+1),j=1,nr)
        write(*,'(1x,a6,f7.3)') 'Sum = ',sum
        write(*,'(1x,a12,/,4x,t4,a39,t43,a39)') 'Compare ans:',
     *       ans(2*i-1),ans(2*i)
13    continue
      END
