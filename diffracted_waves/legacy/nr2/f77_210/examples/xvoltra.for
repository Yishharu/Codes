      PROGRAM xvoltra
C     driver for routine voltra
      INTEGER N,M
      REAL H
      PARAMETER(N=30,H=.05,M=2)
      INTEGER nn
      REAL t0,t(N),f(M,N)
      EXTERNAL g,ak
      t0=0.
      call voltra(N,M,t0,H,t,f,g,ak)
C     exact soln is f(1)=exp(-t), f(2)=2sin(t)
      write(*,*)
     *'abscissa,voltra answer1,real answer1,voltra answer2,real answer2'
      do 11 nn=1,N
        write(*,100) t(nn),f(1,nn),exp(-t(nn)),f(2,nn),2.*sin(t(nn))
11    continue
100   format(5f10.6)
      END

      REAL FUNCTION g(k,t)
      INTEGER k
      REAL t
      if (k.eq.1) then
        g=cosh(t)+t*sin(t)
      else
        g=2.*sin(t)+t*(sin(t)**2+exp(t))
      endif
      return
      END

      REAL FUNCTION ak(k,l,t,s)
      INTEGER k,l
      REAL t,s
      if (k.eq.1) then
        if (l.eq.1) then
          ak=-exp(t-s)
        else
          ak=-cos(t-s)
        endif
      else
        if (l.eq.1) then
          ak=-exp(t+s)
        else
          ak=-t*cos(s)
        endif
      endif
      return
      END
