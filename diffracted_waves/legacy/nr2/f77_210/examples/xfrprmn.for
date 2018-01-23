      PROGRAM xfrprmn
C     driver for routine frprmn
      INTEGER NDIM
      REAL FTOL,PIO2
      PARAMETER(NDIM=3,FTOL=1.0E-6,PIO2=1.5707963)
      INTEGER iter,k
      REAL angl,fret,p(NDIM)
      write(*,'(/1x,a)') 'Program finds the minimum of a function'
      write(*,'(1x,a)') 'with different trial starting vectors.'
      write(*,'(1x,a)') 'True minimum is (0.5,0.5,0.5)'
      do 11 k=0,4
        angl=PIO2*k/4.0
        p(1)=2.0*cos(angl)
        p(2)=2.0*sin(angl)
        p(3)=0.0
        write(*,'(/1x,a,3(f6.4,a))') 'Starting vector: (',
     *       p(1),',',p(2),',',p(3),')'
        call frprmn(p,NDIM,FTOL,iter,fret)
        write(*,'(1x,a,i3)') 'Iterations:',iter
        write(*,'(1x,a,3(f6.4,a))') 'Solution vector: (',
     *       p(1),',',p(2),',',p(3),')'
        write(*,'(1x,a,e14.6)') 'Func. value at solution',fret
11    continue
      END

      REAL FUNCTION func(x)
      REAL bessj0,x(3)
      func=1.0-bessj0(x(1)-0.5)*bessj0(x(2)-0.5)*bessj0(x(3)-0.5)
      END

      SUBROUTINE dfunc(x,df)
      INTEGER NMAX
      PARAMETER (NMAX=50)
      REAL bessj0,bessj1,x(3),df(NMAX)
      df(1)=bessj1(x(1)-0.5)*bessj0(x(2)-0.5)*bessj0(x(3)-0.5)
      df(2)=bessj0(x(1)-0.5)*bessj1(x(2)-0.5)*bessj0(x(3)-0.5)
      df(3)=bessj0(x(1)-0.5)*bessj0(x(2)-0.5)*bessj1(x(3)-0.5)
      return
      END
