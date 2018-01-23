      PROGRAM xratint
C     driver for routine ratint
      INTEGER NPT
      REAL EPSSQ
      PARAMETER(NPT=6,EPSSQ=1.0)
      INTEGER i
      REAL dyy,f,xx,yexp,yy,z,x(NPT),y(NPT)
      f(z)=z*exp(-z)/((z-1.0)**2+EPSSQ)
      do 11 i=1,NPT
        x(i)=i*2.0/NPT
        y(i)=f(x(i))
11    continue
      write(*,'(/1x,a/)') 'Diagonal rational function interpolation'
      write(*,'(1x,t6,a,t13,a,t26,a,t40,a)')
     *     'x','interp.','accuracy','actual'
      do 12 i=1,10
        xx=0.2*i
        call ratint(x,y,NPT,xx,yy,dyy)
        yexp=f(xx)
        write(*,'(1x,f6.2,f12.6,e15.4,f12.6)') xx,yy,dyy,yexp
12    continue
      END
