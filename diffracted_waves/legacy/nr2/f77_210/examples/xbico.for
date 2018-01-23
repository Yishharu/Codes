      PROGRAM xbico
C     driver for routine bico
      INTEGER i,k,n,nval
      REAL binco,bico
      CHARACTER text*21
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Binomial Coefficients') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t6,a1,t12,a1,t19,a6,t28,a9)')
     *     'N','K','Actual','BICO(N,K)'
      do 11 i=1,nval
        read(7,*) n,k,binco
        write(*,'(2i6,2f12.0)') n,k,binco,bico(n,k)
11    continue
      close(7)
      END
