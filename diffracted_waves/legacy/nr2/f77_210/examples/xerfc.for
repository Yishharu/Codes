      PROGRAM xerfc
C     driver for routine erfc
      INTEGER i,nval
      REAL erfc,value,x
      CHARACTER text*14
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Error Function') goto 10
      read(7,*) nval
      write(*,*) 'Complementary error function'
      write(*,'(1x,t5,a1,t12,a6,t23,a7)')
     *     'X','Actual','ERFC(X)'
      do 11 i=1,nval
        read(7,*) x,value
        value=1.0-value
        write(*,'(f6.2,2f12.7)') x,value,erfc(x)
11    continue
      close(7)
      END
