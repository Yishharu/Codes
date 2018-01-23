      PROGRAM xfred2
C     driver for routine fred2
      INTEGER N
      REAL PI
      PARAMETER(N=8,PI=3.1415927)
      INTEGER i
      REAL a,ak,b,g,t(N),f(N),w(N)
      EXTERNAL g,ak
      a=0.
      b=PI/2.
      call fred2(N,a,b,t,f,w,g,ak)
C     compare with exact solution
      write(*,*) 'Abscissa, Calc soln, True soln'
      do 11 i=1,N
        write(*,100) t(i),f(i),sqrt(t(i))
11    continue
100   format(3f10.6)
      END

      REAL FUNCTION g(t)
      REAL PI
      PARAMETER(PI=3.1415927)
      REAL t
      g=sqrt(t)-(PI/2.)**2.25*t**.75/2.25
      return
      END

      REAL FUNCTION ak(t,s)
      REAL t,s
      ak=(t*s)**.75
      return
      END
