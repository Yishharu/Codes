      PROGRAM xdf1dim
C     driver for routine df1dim
      INTEGER NDIM,NMAX
      PARAMETER(NDIM=3,NMAX=50)
      INTEGER i,j,ncom
      REAL pcom,xicom
      COMMON /f1com/ pcom(NMAX),xicom(NMAX),ncom
      REAL df1dim,p(NDIM),xi(NDIM)
      EXTERNAL df1dim
      DATA p/0.0,0.0,0.0/
      ncom=NDIM
      write(*,'(/1x,a)') 'Enter vector direction along which to'
      write(*,'(1x,a)') 'plot the function. Minimum is in the'
      write(*,'(1x,a)') 'direction 1.0,1.0,1.0 - Enter X,Y,Z:'
      read(*,*) (xi(i),i=1,3)
      do 11 j=1,NDIM
        pcom(j)=p(j)
        xicom(j)=xi(j)
11    continue
      call scrsho(df1dim)
      END

      SUBROUTINE dfunc(x,df)
      INTEGER i
      REAL x(3),df(3)
      do 11 i=1,3
        df(i)=(x(i)-1.0)**2
11    continue
      return
      END
