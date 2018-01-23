      PROGRAM xbeta
C     driver for routine beta
      INTEGER i,nval
      REAL beta,value,w,z
      CHARACTER text*13
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Beta Function') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a1,t11,a1,t24,a6,t43,a9)')
     *     'W','Z','Actual','BETA(W,Z)'
      do 11 i=1,nval
        read(7,*) w,z,value
        write(*,'(2f6.2,2e20.6)') w,z,value,beta(w,z)
11    continue
      close(7)
      END
