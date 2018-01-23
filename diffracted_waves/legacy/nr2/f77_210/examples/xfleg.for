      PROGRAM xfleg
C     driver for routine fleg
      INTEGER NPOLY,NVAL
      REAL DX
      PARAMETER(NVAL=5,DX=0.2,NPOLY=5)
      INTEGER i,j
      REAL x,afunc(NPOLY),plgndr
      write(*,'(/1x,t25,a)') 'Legendre Polynomials'
      write(*,'(/1x,t8,a,t18,a,t28,a,t38,a,t48,a)')
     *     'N=1','N=2','N=3','N=4','N=5'
      do 11 i=1,NVAL
        x=i*DX
        call fleg(x,afunc,NPOLY)
        write(*,'(1x,a,f6.2)') 'X =',x
        write(*,'(1x,5f10.4,a)') (afunc(j),j=1,NPOLY),'  routine FLEG'
        write(*,'(1x,5f10.4,a/)') (plgndr(j-1,0,x),j=1,NPOLY),
     *       '  routine PLGNDR'
11    continue
      END
