      PROGRAM xei
C     driver for routine ei
      INTEGER i,nval
      REAL ei,value,x
      CHARACTER text*23
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Exponential Integral Ei') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t13,a,t28,a)')
     *     'X','Actual','EI(X)'
      do 11 i=1,nval
        read(7,*) x,value
        write(*,'(f6.2,2e16.6)') x,value,ei(x)
11    continue
      close(7)
      END
