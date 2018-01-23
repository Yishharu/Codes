      PROGRAM xpowell
C     driver for routine powell
      INTEGER NDIM
      REAL FTOL
      PARAMETER(NDIM=3,FTOL=1.0E-6)
      INTEGER i,iter,np
      REAL fret,p(NDIM),xi(NDIM,NDIM)
      np=NDIM
      DATA xi/1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,1.0/
      DATA p/1.5,1.5,2.5/
      call powell(p,xi,NDIM,np,FTOL,iter,fret)
      write(*,'(/1x,a,i3)') 'Iterations:',iter
      write(*,'(/1x,a/1x,3f12.6)') 'Minimum found at: ',(p(i),i=1,NDIM)
      write(*,'(/1x,a,f12.6)') 'Minimum function value =',fret
      write(*,'(/1x,a)') 'True minimum of function is at:'
      write(*,'(1x,3f12.6/)') 1.0,2.0,3.0
      END

      REAL FUNCTION func(x)
      REAL bessj0,x(3)
      func=0.5-bessj0((x(1)-1.0)**2+(x(2)-2.0)**2+(x(3)-3.0)**2)
      END
