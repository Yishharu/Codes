      PROGRAM xbessi
C     driver for routine bessi
      INTEGER i,n,nval
      REAL bessi,value,x
      CHARACTER text*27
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Modified Bessel Function In') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t12,a,t20,a,t34,a)')
     *     'N','X','Actual','BESSI(N,X)'
      do 11 i=1,nval
        read(7,*) n,x,value
        write(*,'(1x,i4,f8.2,2e16.7)') n,x,value,bessi(n,x)
11    continue
      close(7)
      END
