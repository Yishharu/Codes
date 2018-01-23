      PROGRAM xbessy1
C     driver for routine bessy1
      INTEGER i,nval
      REAL bessy1,value,x
      CHARACTER text*18
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Bessel Function Y1') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a1,t12,a6,t22,a9)')
     *     'X','Actual','BESSY1(X)'
      do 11 i=1,nval
        read(7,*) x,value
        write(*,'(f6.2,2f12.7)') x,value,bessy1(x)
11    continue
      close(7)
      END
