      PROGRAM xrd
C     driver for routine rd
      INTEGER i,nval
      REAL rd,value,x,y,z
      CHARACTER text*32
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Elliptic Integral Second Kind RD') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t7,a1,t15,a1,t23,a1,t36,a6,t54,a9)')
     *     'X','Y','Z','Actual','RD(X,Y,Z)'
      do 11 i=1,nval
        read(7,*) x,y,z,value
        write(*,'(3f8.2,2e20.6)') x,y,z,value,rd(x,y,z)
11    continue
      close(7)
      END
