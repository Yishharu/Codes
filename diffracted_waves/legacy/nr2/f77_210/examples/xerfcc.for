      PROGRAM xerfcc
C     driver for routine erfcc
      INTEGER i,nval
      REAL erfcc,value,x
      CHARACTER text*14
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Error Function') goto 10
      read(7,*) nval
      write(*,*) 'Complementary error function'
      write(*,'(1x,t5,a1,t12,a6,t23,a8)')
     *     'X','Actual','ERFCC(X)'
      do 11 i=1,nval
        read(7,*) x,value
        value=1.0-value
        write(*,'(f6.2,2f12.7)') x,value,erfcc(x)
11    continue
      close(7)
      END
