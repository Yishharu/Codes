      PROGRAM xdfpmin
C     driver for routine dfpmin
      INTEGER NDIM
      REAL GTOL
      PARAMETER(NDIM=2,GTOL=1.0E-4)
      COMMON /stats/ nfunc,ndfunc
      INTEGER iter,ndfunc,nfunc
      REAL fret,p(NDIM)
      EXTERNAL func,dfunc
      write(*,'(/1x,a)') 'True minimum is at (-2.0,+-0.89442719)'
      nfunc=0
      ndfunc=0
      p(1)=.1
      p(2)=4.2
      write(*,'(/1x,a,2(f7.4,a))') 'Starting vector: (',
     *     p(1),',',p(2),')'
      call dfpmin(p,NDIM,GTOL,iter,fret,func,dfunc)
      write(*,'(1x,a,i3)') 'Iterations:',iter
      write(*,'(1x,a,i3)') 'Func. evals:',nfunc
      write(*,'(1x,a,i3)') 'Deriv. evals:',ndfunc
      write(*,'(1x,a,2(f9.6,a))') 'Solution vector: (',
     *     p(1),',',p(2),')'
      write(*,'(1x,a,e14.6)') 'Func. value at solution',fret
      END

      REAL FUNCTION func(x)
      INTEGER ndfunc,nfunc
      COMMON /stats/ nfunc,ndfunc
      REAL x(*)
      nfunc=nfunc+1
      func=10.*(x(2)**2*(3.-x(1))-x(1)**2*(3.+x(1)))**2+(2.+x(1))**2/
     *     (1.+(2.+x(1))**2)
      END

      SUBROUTINE dfunc(x,df)
      INTEGER NMAX
      PARAMETER (NMAX=50)
      INTEGER ndfunc,nfunc
      COMMON /stats/ nfunc,ndfunc
      REAL x(*),df(NMAX)
      ndfunc=ndfunc+1
      df(1)=20.*(x(2)**2*(3.-x(1))-x(1)**2*(3.+x(1)))*(-x(2)**2-6.*
     *     x(1)-3.*x(1)**2)+2.*(2.+x(1))/(1.+(2.+x(1))**2)-
     *     2.*(2.+x(1))**3/(1.+(2.+x(1))**2)**2
      df(2)=40.*(x(2)**2*(3.-x(1))-x(1)**2*(3.+x(1)))*x(2)*(3.-x(1))
      return
      END
