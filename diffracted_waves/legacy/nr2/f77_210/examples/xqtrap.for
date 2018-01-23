      PROGRAM xqtrap
C     driver for routine qtrap
      REAL PIO2
      PARAMETER(PIO2=1.5707963)
      REAL a,b,fint,func,s
      EXTERNAL func
      a=0.0
      b=PIO2
      write(*,'(1x,a)') 'Integral of FUNC computed with QTRAP'
      write(*,'(1x,a,f10.6)') 'Actual value of integral is',
     *     fint(b)-fint(a)
      call qtrap(func,a,b,s)
      write(*,'(1x,a,f10.6)') 'Result from routine QTRAP is',s
      END

      REAL FUNCTION func(x)
      REAL x
      func=(x**2)*(x**2-2.0)*sin(x)
      END

      REAL FUNCTION fint(x)
C     integral of FUNC
      REAL x
      fint=4.0*x*((x**2)-7.0)*sin(x)-((x**4)-14.0*(x**2)+28.0)*cos(x)
      END
