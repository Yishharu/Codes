      PROGRAM xks2d1s
C     driver for routine ks2d1s
      INTEGER NMAX
      PARAMETER(NMAX=1000)
      INTEGER idum,j,jtrial,n1,ntrial
      REAL d,ran1,prob,factor,u,v,x1(NMAX),y1(NMAX)
      EXTERNAL quadvl
1     write(*,*) 'HOW MANY POINTS?'
      read(*,*,END=999) n1
      if (n1.gt.NMAX) then
        write(*,*) 'n1 too large.'
        goto 1
      endif
2     write(*,*) 'WHAT FACTOR NONLINEARITY (0 to 1)?'
      read(*,*,END=999) factor
      if (factor.lt.0.) then
        write(*,*) 'factor less than 0'
        goto 2
      endif
      if (factor.gt.1.) then
        write(*,*) 'factor greater than 1'
        goto 2
      endif
      write(*,*) 'HOW MANY TRIALS?'
      read(*,*,END=999) ntrial
      idum=-289-ntrial-n1
      do 12 jtrial=1,ntrial
        do 11 j=1,n1
          u=ran1(idum)
          u=u*((1.-factor)+u*factor)
          x1(j)=2.*u-1.
          v=ran1(idum)
          v=v*((1.-factor)+v*factor)
          y1(j)=2.*v-1.
11      continue
        call ks2d1s(x1,y1,n1,quadvl,d,prob)
        write(*,'(1x,a7,2f12.6)') 'D,PROB= ',d,prob
12    continue
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
