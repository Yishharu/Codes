      PROGRAM xbessi1
C     driver for routine bessi1
      INTEGER i,nval
      REAL bessi1,value,x
      CHARACTER text*27
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Modified Bessel Function I1') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t13,a,t28,a)')
     *     'X','Actual','BESSI1(X)'
      do 11 i=1,nval
        read(7,*) x,value
        write(*,'(f6.2,2e16.7)') x,value,bessi1(x)
11    continue
      close(7)
      END
