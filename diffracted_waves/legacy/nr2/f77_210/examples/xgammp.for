      PROGRAM xgammp
C     driver for routine gammp
      INTEGER i,nval
      REAL a,gammp,value,x
      CHARACTER text*25
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Incomplete Gamma Function') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t16,a,t25,a,t35,a)')
     *     'A','X','Actual','GAMMP(A,X)'
      do 11 i=1,nval
        read(7,*) a,x,value
        write(*,'(1x,f6.2,3f12.6)') a,x,value,gammp(a,x)
11    continue
      close(7)
      END
