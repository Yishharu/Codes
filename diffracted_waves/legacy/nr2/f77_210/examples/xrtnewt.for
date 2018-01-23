      PROGRAM xrtnewt
C     driver for routine rtnewt
      INTEGER N,NBMAX
      REAL X1,X2
      PARAMETER(N=100,NBMAX=20,X1=1.0,X2=50.0)
      INTEGER i,nb
      REAL bessj0,rtnewt,root,xacc,xb1(NBMAX),xb2(NBMAX)
      EXTERNAL funcd,bessj0
      nb=NBMAX
      call zbrak(bessj0,X1,X2,N,xb1,xb2,nb)
      write(*,'(/1x,a)') 'Roots of BESSJ0:'
      write(*,'(/1x,t19,a,t31,a/)') 'x','F(x)'
      do 11 i=1,nb
        xacc=(1.0e-6)*(xb1(i)+xb2(i))/2.0
        root=rtnewt(funcd,xb1(i),xb2(i),xacc)
        write(*,'(1x,a,i2,2x,f12.6,e16.4)') 'Root ',i,root,bessj0(root)
11    continue
      END

      SUBROUTINE funcd(x,fn,df)
      REAL bessj0,bessj1,df,fn,x
      fn=bessj0(x)
      df=-bessj1(x)
      return
      END
