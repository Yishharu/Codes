      PROGRAM xbessk
C     driver for routine bessk
      INTEGER i,n,nval
      REAL bessk,value,x
      CHARACTER text*27
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Modified Bessel Function Kn') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t12,a,t20,a,t35,a)')
     *     'N','X','Actual','BESSK(N,X)'
      do 11 i=1,nval
        read(7,*) n,x,value
        write(*,'(1x,i4,f8.2,2e16.7)') n,x,value,bessk(n,x)
11    continue
      close(7)
      END
