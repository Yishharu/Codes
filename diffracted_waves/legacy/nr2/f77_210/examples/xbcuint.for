      PROGRAM xbcuint
C     driver for routine bcuint
      INTEGER i
      REAL ansy,ansy1,ansy2,ey,ey1,ey2
      REAL x1,x1l,x1u,x1x2,x2,x2l,x2u,xxyy
      REAL y(4),y1(4),y2(4),y12(4),xx(4),yy(4)
      DATA xx/0.0,2.0,2.0,0.0/
      DATA yy/0.0,0.0,2.0,2.0/
      x1l=xx(1)
      x1u=xx(2)
      x2l=yy(1)
      x2u=yy(4)
      do 11 i=1,4
        xxyy=xx(i)*yy(i)
        y(i)=xxyy**2
        y1(i)=2.0*yy(i)*xxyy
        y2(i)=2.0*xx(i)*xxyy
        y12(i)=4.0*xxyy
11    continue
      write(*,'(/1x,t6,a,t14,a,t22,a,t28,a,t38,a,t44,a,t54,a,t60,a/)')
     *     'X1','X2','Y','EXPECT','Y1','EXPECT','Y2','EXPECT'
      do 12 i=1,10
        x1=0.2*i
        x2=x1
        call bcuint(y,y1,y2,y12,x1l,x1u,x2l,x2u,x1,x2,ansy,ansy1,ansy2)
        x1x2=x1*x2
        ey=x1x2**2
        ey1=2.0*x2*x1x2
        ey2=2.0*x1*x1x2
        write(*,'(1x,8f8.4)') x1,x2,ansy,ey,ansy1,ey1,ansy2,ey2
12    continue
      END
