      PROGRAM xrc
C     driver for routine rc
      INTEGER i,nval
      REAL rc,value,x,y
      CHARACTER text*31
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Elliptic Integral Degenerate RC') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t7,a1,t15,a1,t28,a6,t47,a7)')
     *     'X','Y','Actual','RC(X,Y)'
      do 11 i=1,nval
        read(7,*) x,y,value
        write(*,'(2f8.2,2e20.6)') x,y,value,rc(x,y)
11    continue
      close(7)
      END
