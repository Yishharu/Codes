      PROGRAM xfpoly
C     driver for routine fpoly
      INTEGER NPOLY,NVAL
      REAL DX
      PARAMETER(NVAL=15,DX=0.1,NPOLY=5)
      INTEGER i,j
      REAL x,afunc(NPOLY)
      write(*,'(/1x,t29,a)') 'Powers of X'
      write(*,'(/1x,t9,a,t17,a,t27,a,t37,a,t47,a,t57,a)') 'X','X**0',
     *     'X**1','X**2','X**3','X**4'
      do 11 i=1,NVAL
        x=i*DX
        call fpoly(x,afunc,NPOLY)
        write(*,'(1x,6f10.4)') x,(afunc(j),j=1,NPOLY)
11    continue
      END
