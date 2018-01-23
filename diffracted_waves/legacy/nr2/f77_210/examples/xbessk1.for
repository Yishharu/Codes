      PROGRAM xbessk1
C     driver for routine bessk1
      INTEGER i,nval
      REAL bessk1,value,x
      CHARACTER text*27
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Modified Bessel Function K1') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t13,a,t28,a)')
     *     'X','Actual','BESSK1(X)'
      do 11 i=1,nval
        read(7,*) x,value
        write(*,'(f6.2,2e16.7)') x,value,bessk1(x)
11    continue
      close(7)
      END
