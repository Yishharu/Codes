      PROGRAM xexpint
C     driver for routine expint
      INTEGER i,n,nval
      REAL expint,value,x
      CHARACTER text*23
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Exponential Integral En') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t12,a,t20,a,t33,a)')
     *     'N','X','Actual','EXPINT(N,X)'
      do 11 i=1,nval
        read(7,*) n,x,value
        write(*,'(1x,i4,f8.2,2e15.6)') n,x,value,expint(n,x)
11    continue
      close(7)
      END
