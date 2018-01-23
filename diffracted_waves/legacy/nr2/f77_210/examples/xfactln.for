      PROGRAM xfactln
C     driver for routine factln
      INTEGER i,n,nval
      REAL factln,value
      CHARACTER text*11
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'N-factorial') goto 10
      read(7,*) nval
      write(*,*) 'Log of N-factorial'
      write(*,'(1x,t6,a1,t18,a6,t34,a9)')
     *     'N','Actual','FACTLN(N)'
      do 11 i=1,nval
        read(7,*) n,value
        write(*,'(i6,2f18.6)') n,log(value),factln(n)
11    continue
      close(7)
      END
