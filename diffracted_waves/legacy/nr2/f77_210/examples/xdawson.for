      PROGRAM xdawson
C     driver for routine dawson
      INTEGER i,nval
      REAL dawson,value,x
      CHARACTER text*15
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Dawson integral') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t13,a,t28,a)')
     *     'X','Actual','Dawson(X)'
      do 11 i=1,nval
        read(7,*) x,value
        write(*,'(f6.2,2e16.6)') x,value,dawson(x)
11    continue
      close(7)
      END
