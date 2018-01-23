      PROGRAM xbetai
C     driver for routine betai,betacf
      INTEGER i,nval
      REAL a,b,betai,value,x
      CHARACTER text*24
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Incomplete Beta Function') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t15,a,t27,a,t36,a,t47,a)')
     *     'A','B','X','Actual','BETAI(X)'
      do 11 i=1,nval
        read(7,*) a,b,x,value
        write(*,'(f6.2,4f12.6)') a,b,x,value,betai(a,b,x)
11    continue
      close(7)
      END
