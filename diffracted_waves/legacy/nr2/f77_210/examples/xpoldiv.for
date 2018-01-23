      PROGRAM xpoldiv
C     driver for routine poldiv
      INTEGER N,NV
      PARAMETER(N=6,NV=4)
      INTEGER i
      REAL u(N),v(NV),q(N),r(N)
      DATA u/-1.0,5.0,-10.0,10.0,-5.0,1.0/
      DATA v/1.0,3.0,3.0,1.0/
      call poldiv(u,N,v,NV,q,r)
      write(*,'(//1x,6(7x,a)/)') 'X^0','X^1','X^2','X^3','X^4','X^5'
      write(*,*) 'Quotient polynomial coefficients:'
      write(*,'(1x,6f10.2/)') (q(i),i=1,6)
      write(*,*) 'Expected quotient coefficients:'
      write(*,'(1x,6f10.2///)') 31.0,-8.0,1.0,0.0,0.0,0.0
      write(*,*) 'Remainder polynomial coefficients:'
      write(*,'(1x,4f10.2/)') (r(i),i=1,4)
      write(*,*) 'Expected remainder coefficients:'
      write(*,'(1x,4f10.2//)') -32.0,-80.0,-80.0,0.0
      END
