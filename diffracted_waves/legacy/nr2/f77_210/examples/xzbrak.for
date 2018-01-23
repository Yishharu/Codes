      PROGRAM xzbrak
C     driver for routine zbrak
      INTEGER N,NBMAX
      REAL X1,X2
      PARAMETER(N=100,NBMAX=20,X1=1.0,X2=50.0)
      INTEGER i,nb
      REAL bessj0,xb1(NBMAX),xb2(NBMAX)
      EXTERNAL bessj0
      nb=NBMAX
      call zbrak(bessj0,X1,X2,N,xb1,xb2,nb)
      write(*,'(/1x,a/)') 'Brackets for roots of BESSJ0:'
      write(*,'(/1x,t17,a,t27,a,t40,a,t50,a/)') 'lower','upper',
     *     'F(lower)','F(upper)'
      do 11 i=1,nb
        write(*,'(1x,a,i2,2(4x,2f10.4))') 'Root ',i,xb1(i),xb2(i),
     *       bessj0(xb1(i)),bessj0(xb2(i))
11    continue
      END
