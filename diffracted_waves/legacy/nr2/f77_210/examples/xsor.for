      PROGRAM xsor
C     driver for routine sor
      INTEGER JMAX,NSTEP
      REAL PI
      PARAMETER(JMAX=33,NSTEP=4,PI=3.1415926)
      INTEGER i,j,midl
      DOUBLE PRECISION rjac,a(JMAX,JMAX),b(JMAX,JMAX),c(JMAX,JMAX),
     *     d(JMAX,JMAX),e(JMAX,JMAX),f(JMAX,JMAX),u(JMAX,JMAX)
      do 12 i=1,JMAX
        do 11 j=1,JMAX
          a(i,j)=1.d0
          b(i,j)=1.d0
          c(i,j)=1.d0
          d(i,j)=1.d0
          e(i,j)=-4.d0
          f(i,j)=0.d0
          u(i,j)=0.d0
11      continue
12    continue
      midl=JMAX/2+1
      f(midl,midl)=2.d0/(JMAX-1)**2
      rjac=cos(PI/JMAX)
      call sor(a,b,c,d,e,f,u,JMAX,rjac)
      write(*,'(1x,a)') 'SOR Solution:'
      do 13 i=1,JMAX,NSTEP
        write(*,'(1x,9f8.4)') (u(i,j),j=1,JMAX,NSTEP)
13    continue
      write(*,'(/1x,a)') 'Test that solution satisfies Difference Eqns:'
      do 15 i=NSTEP+1,JMAX-1,NSTEP
        do 14 j=NSTEP+1,JMAX-1,NSTEP
          f(i,j)=u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1)-4.d0*u(i,j)
14      continue
        write(*,'(7x,9f8.4)') (f(i,j),j=NSTEP+1,JMAX-1,NSTEP)
15    continue
      END
