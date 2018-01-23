      PROGRAM xfredin
C     driver for routine fredin
      INTEGER N
      REAL PI
      PARAMETER(N=8,PI=3.1415927)
      REAL a,ak,ans,b,fredin,g,x,t(N),f(N),w(N)
      EXTERNAL g,ak
      a=0.
      b=PI/2.
      call fred2(N,a,b,t,f,w,g,ak)
100   format(3f10.6)
1     write(*,*) 'Enter T between 0 and PI/2'
      read(*,*,END=99) x
      ans=fredin(x,N,a,b,t,f,w,g,ak)
      write(*,*) 'T, Calculated answer, True answer'
      write(*,100) x,ans,sqrt(x)
      go to 1
99    stop
      END

      REAL FUNCTION g(t)
      REAL PI
      PARAMETER(PI=3.1415927)
      REAL t
      g=sqrt(t)-(PI/2.)**2.25*t**.75/2.25
      return
      END

      REAL FUNCTION ak(t,s)
      REAL s,t
      ak=(t*s)**.75
      return
      END
