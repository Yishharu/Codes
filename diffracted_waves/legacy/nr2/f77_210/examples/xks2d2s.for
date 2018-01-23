      PROGRAM xks2d2s
C     driver for routine ks2d2s
      INTEGER NMAX
      PARAMETER(NMAX=1000)
      INTEGER idum,j,jtrial,n1,n2,ntrial
      REAL d,gasdev,prob,shrink,u,v,x1(NMAX),y1(NMAX),x2(NMAX),y2(NMAX)
1     write(*,*) 'INPUT N1,N2'
      read(*,*,END=999) n1,n2
      if (n1.gt.NMAX) then
        write(*,*) 'n1 too large.'
        goto 1
      endif
      if (n2.gt.NMAX) then
        write(*,*) 'n2 too large.'
        goto 1
      endif
      write(*,*) 'WHAT SHRINKAGE?'
      read(*,*,END=999) shrink
      write(*,*) 'HOW MANY TRIALS?'
      read(*,*,END=999) ntrial
      if (ntrial.gt.NMAX) then
        write(*,*) 'Too many trials.'
        goto 1
      endif
      idum=-287-ntrial-n1-n2
      do 13 jtrial=1,ntrial
        do 11 j=1,n1
          u=gasdev(idum)
          v=gasdev(idum)*shrink
          x1(j)=u+v
          y1(j)=u-v
11      continue
        do 12 j=1,n2
          u=gasdev(idum)*shrink
          v=gasdev(idum)
          x2(j)=u+v
          y2(j)=u-v
12      continue
        call ks2d2s(x1,y1,n1,x2,y2,n2,d,prob)
        write(*,'(1x,a7,2f12.6)') 'D,PROB= ',d,prob
13    continue
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
