      PROGRAM xvegas
C     driver for routine vegas
      INTEGER idum,init,itmax,j,ncall,ndim,nprn
      REAL avgi,chi2a,sd,xoff
      COMMON /ranno/ idum
      COMMON /tofxn/ xoff,ndim
      REAL region(20)
      EXTERNAL fxn
      write(*,*) 'IDUM='
      read(*,*) idum
      idum=-abs(idum)
1     write(*,*) 'ENTER NDIM,XOFF,NCALL,ITMAX,NPRN'
      read(*,*,END=999) ndim,xoff,ncall,itmax,nprn
      avgi=0.
      sd=0.
      chi2a=0.
      do 11 j=1,ndim
        region(j)=0.
        region(j+ndim)=1.
11    continue
      init = -1
      call vegas(region,ndim,fxn,init,ncall,itmax,nprn,avgi,sd,chi2a)
      write(*,*) 'Number of iterations performed:',itmax
      write(*,*) 'Integral, Standard Dev., Chi-sq.',avgi,sd,chi2a
      init = 1
      call vegas(region,ndim,fxn,init,ncall,itmax,nprn,avgi,sd,chi2a)
      write(*,*) 'Additional iterations performed:',itmax
      write(*,*) 'Integral, Standard Dev., Chi-sq.',avgi,sd,chi2a
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END

      REAL FUNCTION fxn(pt,wgt)
      INTEGER j,ndim
      REAL sum,xoff,wgt
      COMMON /tofxn/ xoff,ndim
      REAL pt(*)
      sum=0.
      do 11 j=1,ndim
        sum=sum+100.*(pt(j)-xoff)**2
11    continue
      if (sum.lt.80.) then
        fxn=exp(-sum)
      else
        fxn=0.
      endif
      fxn=fxn*(5.64189**ndim)
      return
      END
