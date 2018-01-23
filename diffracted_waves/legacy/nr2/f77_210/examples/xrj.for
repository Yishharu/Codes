      PROGRAM xrj
C     driver for routine rj
      INTEGER i,nval
      REAL p,rj,value,x,y,z
      CHARACTER text*31
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Elliptic Integral Third Kind RJ') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t7,a1,t15,a1,t23,a1,t31,a1,t44,a6,t61,a11)')
     *     'X','Y','Z','P,','Actual','RJ(X,Y,Z,P)'
      do 11 i=1,nval
        read(7,*) x,y,z,p,value
        write(*,'(4f8.2,2e20.6)') x,y,z,p,value,rj(x,y,z,p)
11    continue
      close(7)
      END
