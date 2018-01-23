      PROGRAM xsvdfit
C     driver for routine svdfit
      INTEGER NPOL,NPT
      REAL SPREAD
      PARAMETER(NPT=100,SPREAD=0.02,NPOL=5)
      INTEGER i,idum,mp,np
      REAL chisq,gasdev
      REAL x(NPT),y(NPT),sig(NPT),a(NPOL),cvm(NPOL,NPOL)
      REAL u(NPT,NPOL),v(NPOL,NPOL),w(NPOL)
      EXTERNAL fpoly,fleg
C     polynomial fit
      idum=-911
      mp=NPT
      np=NPOL
      do 11 i=1,NPT
        x(i)=0.02*i
        y(i)=1.0+x(i)*(2.0+x(i)*(3.0+x(i)*(4.0+x(i)*5.0)))
        y(i)=y(i)*(1.0+SPREAD*gasdev(idum))
        sig(i)=y(i)*SPREAD
11    continue
      call svdfit(x,y,sig,NPT,a,NPOL,u,v,w,mp,np,chisq,fpoly)
      call svdvar(v,NPOL,np,w,cvm,NPOL)
      write(*,*) 'Polynomial fit:'
      do 12 i=1,NPOL
        write(*,'(1x,f12.6,a,f10.6)') a(i),'  +-',sqrt(cvm(i,i))
12    continue
      write(*,'(1x,a,f12.6/)') 'Chi-squared',chisq
      call svdfit(x,y,sig,NPT,a,NPOL,u,v,w,mp,np,chisq,fleg)
      call svdvar(v,NPOL,np,w,cvm,NPOL)
      write(*,*) 'Legendre polynomial fit'
      do 13 i=1,NPOL
        write(*,'(1x,f12.6,a,f10.6)') a(i),'  +-',sqrt(cvm(i,i))
13    continue
      write(*,'(1x,a,f12.6/)') 'Chi-squared',chisq
      END
