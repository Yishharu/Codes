      PROGRAM xbcucof
C     driver for routine bcucof
      INTEGER i,j
      REAL d1,d2,ee,x1x2
      REAL c(4,4),y(4),y1(4),y2(4)
      REAL y12(4),x1(4),x2(4)
      DATA x1/0.0,2.0,2.0,0.0/
      DATA x2/0.0,0.0,2.0,2.0/
      d1=x1(2)-x1(1)
      d2=x2(4)-x2(1)
      do 11 i=1,4
        x1x2=x1(i)*x2(i)
        ee=exp(-x1x2)
        y(i)=x1x2*ee
        y1(i)=x2(i)*(1.0-x1x2)*ee
        y2(i)=x1(i)*(1.0-x1x2)*ee
        y12(i)=(1.0-3.0*x1x2+x1x2**2)*ee
11    continue
      call bcucof(y,y1,y2,y12,d1,d2,c)
      write(*,*) 'Coefficients for bicubic interpolation'
      do 12 i=1,4
        write(*,'(1x,4e15.6)') (c(i,j),j=1,4)
12    continue
      END
