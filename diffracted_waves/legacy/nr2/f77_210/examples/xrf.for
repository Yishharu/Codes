      PROGRAM xrf
C     driver for routine rf
      INTEGER i,nval
      REAL rf,value,x,y,z
      CHARACTER text*31
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Elliptic Integral First Kind RF') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t7,a1,t15,a1,t23,a1,t36,a6,t54,a9)')
     *     'X','Y','Z','Actual','RF(X,Y,Z)'
      do 11 i=1,nval
        read(7,*) x,y,z,value
        write(*,'(3f8.2,2e20.6)') x,y,z,value,rf(x,y,z)
11    continue
      close(7)
      END
