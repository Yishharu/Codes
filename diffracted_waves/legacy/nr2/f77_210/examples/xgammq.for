      PROGRAM xgammq
C     driver for routine gammq
      INTEGER i,nval
      REAL a,gammq,value,x
      CHARACTER text*25
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Incomplete Gamma Function') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t16,a,t25,a,t35,a)')
     *     'A','X','Actual','GAMMQ(A,X)'
      do 11 i=1,nval
        read(7,*) a,x,value
        write(*,'(1x,f6.2,3f12.6)') a,x,1.0-value,gammq(a,x)
11    continue
      close(7)
      END
