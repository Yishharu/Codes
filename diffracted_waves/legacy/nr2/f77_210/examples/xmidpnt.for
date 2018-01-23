      PROGRAM xmidpnt
C     driver for routine midpnt
      INTEGER NMAX
      PARAMETER(NMAX=10)
      INTEGER i
      REAL a,b,fint2,func2,s
      EXTERNAL fint2,func2
      a=0.0
      b=1.0
      write(*,*) 'Integral of FUNC2 computed with MIDPNT'
      write(*,*) 'Actual value of integral is',fint2(b)-fint2(a)
      write(*,'(1x,t7,a,t20,a)') 'n','Approx. Integral'
      do 11 i=1,NMAX
        call midpnt(func2,a,b,s,i)
        write(*,'(1x,i6,f24.6)') i,s
11    continue
      END

      REAL FUNCTION func2(x)
      REAL x
      func2=1.0/sqrt(x)
      END

      REAL FUNCTION fint2(x)
C     integral of FUNC2
      REAL x
      fint2=2.0*sqrt(x)
      END
