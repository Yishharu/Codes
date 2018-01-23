      PROGRAM xmgfas
C     driver for routine mgfas
      INTEGER JMAX,NSTEP
      PARAMETER(JMAX=33,NSTEP=4)
      INTEGER i,j,midl
      DOUBLE PRECISION f(JMAX,JMAX),u(JMAX,JMAX)
      do 12 i=1,JMAX
        do 11 j=1,JMAX
          u(i,j)=0.d0
11      continue
12    continue
      midl=JMAX/2+1
      u(midl,midl)=2.d0
      call mgfas(u,JMAX,2)
      write(*,'(1x,a)') 'MGFAS Solution:'
      do 13 i=1,JMAX,NSTEP
        write(*,'(1x,9f8.4)') (u(i,j),j=1,JMAX,NSTEP)
13    continue
      write(*,'(/1x,a)') 'Test that solution satisfies Difference Eqns:'
      do 15 i=NSTEP+1,JMAX-1,NSTEP
        do 14 j=NSTEP+1,JMAX-1,NSTEP
          f(i,j)=u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1)-4.d0*u(i,j)
     *         +u(i,j)**2/(JMAX-1)**2
14      continue
        write(*,'(7x,7f8.4)')
     *       (f(i,j)*(JMAX-1)*(JMAX-1),j=NSTEP+1,JMAX-1,NSTEP)
15    continue
      END

      FUNCTION maloc(len)
      INTEGER maloc,len,NG,MEMLEN
      PARAMETER (NG=5,MEMLEN=17*2**(2*NG)/3+18*2**NG+10*NG-86/3)
      INTEGER mem
      DOUBLE PRECISION z
      COMMON /memory/ z(MEMLEN),mem
      if (mem+len+1.gt.MEMLEN) pause 'insufficient memory in maloc'
      z(mem+1)=len
      maloc=mem+2
      mem=mem+len+1
      return
      END
