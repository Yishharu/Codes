      PROGRAM xmrqcof
C     driver for routine mrqcof
      INTEGER NPT,MA
      REAL SPREAD
      PARAMETER(NPT=100,MA=6,SPREAD=0.1)
      INTEGER i,idum,j,ia(MA),mfit
      REAL chisq,gasdev,x(NPT),y(NPT),sig(NPT),a(MA),
     *     alpha(MA,MA),beta(MA),gues(MA)
      EXTERNAL fgauss
      DATA a/5.0,2.0,3.0,2.0,5.0,3.0/
      DATA gues/4.9,2.1,2.9,2.1,4.9,3.1/
      idum=-911
C     first try sum of two gaussians
      do 12 i=1,NPT
        x(i)=0.1*i
        y(i)=0.0
        do 11 j=1,4,3
          y(i)=y(i)+a(j)*exp(-((x(i)-a(j+1))/a(j+2))**2)
11      continue
        y(i)=y(i)*(1.0+SPREAD*gasdev(idum))
        sig(i)=SPREAD*y(i)
12    continue
      mfit=MA
      do 13 i=1,mfit
        ia(i)=1
13    continue
      do 14 i=1,mfit
        a(i)=gues(i)
14    continue
      call mrqcof(x,y,sig,NPT,a,ia,MA,alpha,beta,MA,chisq,fgauss)
      write(*,'(/1x,a)') 'matrix alpha'
      do 15 i=1,MA
        write(*,'(1x,6f12.4)') (alpha(i,j),j=1,MA)
15    continue
      write(*,'(1x,a)') 'vector beta'
      write(*,'(1x,6f12.4)') (beta(i),i=1,MA)
      write(*,'(1x,a,f12.4/)') 'Chi-squared:',chisq
C     next fix one line and improve the other
      mfit=3
      do 16 i=1,mfit
        ia(i)=0
16    continue
      do 17 i=1,MA
        a(i)=gues(i)
17    continue
      call mrqcof(x,y,sig,NPT,a,ia,MA,alpha,beta,MA,chisq,fgauss)
      write(*,'(1x,a)') 'matrix alpha'
      do 18 i=1,mfit
        write(*,'(1x,6f12.4)') (alpha(i,j),j=1,mfit)
18    continue
      write(*,'(1x,a)') 'vector beta'
      write(*,'(1x,6f12.4)') (beta(i),i=1,mfit)
      write(*,'(1x,a,f12.4/)') 'Chi-squared:',chisq
      END
