      PROGRAM xbessy0
C     driver for routine bessy0
      INTEGER i,nval
      REAL bessy0,value,x
      CHARACTER text*18
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Bessel Function Y0') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a1,t12,a6,t22,a9)')
     *     'X','Actual','BESSY0(X)'
      do 11 i=1,nval
        read(7,*) x,value
        write(*,'(f6.2,2f12.7)') x,value,bessy0(x)
11    continue
      close(7)
      END
