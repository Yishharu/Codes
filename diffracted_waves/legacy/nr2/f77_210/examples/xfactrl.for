      PROGRAM xfactrl
C     driver for routine factrl
      INTEGER i,n,nval
      REAL actual,factrl
      CHARACTER text*11
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'N-factorial') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t6,a1,t21,a6,t38,a9)')
     *     'N','Actual','FACTRL(N)'
      do 11 i=1,nval
        read(7,*) n,actual
        if (actual.lt.(1.0e10)) then
          write(*,'(i6,2f20.0)') n,actual,factrl(n)
        else
          write(*,'(i6,2e20.7)') n,actual,factrl(n)
        endif
11    continue
      close(7)
      END
