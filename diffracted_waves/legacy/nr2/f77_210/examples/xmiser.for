      PROGRAM xmiser
C     driver for routine miser
      INTEGER idum,j,n,ndim,nt,ntries
      REAL ave,dith,sumav,sumsd,var,xoff
      COMMON /ranno/ idum
      COMMON /tofunc/ xoff,ndim
      REAL region(20)
      EXTERNAL func
      write(*,*) 'IDUM='
      read(*,*) idum
      idum=-abs(idum)
1     write(*,*) 'ENTER N,NDIM,XOFF,DITH,NTRIES'
      read(*,*,END=999) n,ndim,xoff,dith,ntries
      sumav=0.
      sumsd=0.
      do 12 nt=1,ntries
        do 11 j=1,ndim
          region(j)=0.
          region(j+ndim)=1.
11      continue
        call miser(func,region,ndim,n,dith,ave,var)
        sumav=sumav+(ave-1.)**2
        sumsd=sumsd+sqrt(abs(var))
12    continue
      sumav=sqrt(sumav/ntries)
      sumsd=sumsd/ntries
      write(*,*) 'FRACTIONAL ERROR: ACTUAL,INDICATED=',sumav,sumsd
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END

      REAL FUNCTION func(pt)
      INTEGER j,ndim
      REAL sum,xoff
      COMMON /tofunc/ xoff,ndim
      REAL pt(*)
      sum=0.
      do 11 j=1,ndim
        sum=sum+100.*(pt(j)-xoff)**2
11    continue
      if (sum.lt.80.) then
        func=exp(-sum)
      else
        func=0.
      endif
      func=func*(5.64189**ndim)
      return
      END
