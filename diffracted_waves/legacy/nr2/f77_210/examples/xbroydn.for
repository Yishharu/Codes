      PROGRAM xbroydn
C     driver for routine broydn
      INTEGER N
      PARAMETER(N=2)
      INTEGER i
      REAL x(N),f(N)
      LOGICAL check
      x(1)=2.
      x(2)=.5
      call broydn(x,N,check)
      call funcv(N,x,f)
      if (check) then
        write(*,*) 'Convergence problems.'
      endif
      write(*,'(1x,a5,t10,a1,t22,a1)') 'Index','x','f'
      do 11 i=1,N
        write(*,'(1x,i2,2x,2f12.6)') i,x(i),f(i)
11    continue
      END

      SUBROUTINE funcv(n,x,f)
      INTEGER n
      REAL x(n),f(n)
      f(1)=x(1)**2+x(2)**2-2.
      f(2)=exp(x(1)-1.)+x(2)**3-2.
      return
      END
