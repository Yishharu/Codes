      PROGRAM xmrqmin
C     driver for routine mrqmin
      INTEGER NPT,MA
      REAL SPREAD
      PARAMETER(NPT=100,MA=6,SPREAD=0.001)
      INTEGER i,ia(MA),idum,iter,itst,j,k,mfit
      REAL alamda,chisq,fgauss,gasdev,ochisq,x(NPT),y(NPT),sig(NPT),
     *     a(MA),covar(MA,MA),alpha(MA,MA),gues(MA)
      EXTERNAL fgauss
      DATA a/5.0,2.0,3.0,2.0,5.0,3.0/
      DATA gues/4.5,2.2,2.8,2.5,4.9,2.8/
      idum=-911
C     first try a sum of two Gaussians
      do 12 i=1,NPT
        x(i)=0.1*i
        y(i)=0.0
        do 11 j=1,MA,3
          y(i)=y(i)+a(j)*exp(-((x(i)-a(j+1))/a(j+2))**2)
11      continue
        y(i)=y(i)*(1.0+SPREAD*gasdev(idum))
        sig(i)=SPREAD*y(i)
12    continue
      mfit=MA
      do 13 i=1,mfit
        ia(i)=1
13    continue
      do 14 i=1,MA
        a(i)=gues(i)
14    continue
      do 16 iter=1,2
        alamda=-1
        call mrqmin(x,y,sig,NPT,a,ia,MA,covar,alpha,
     *       MA,chisq,fgauss,alamda)
        k=1
        itst=0
1       write(*,'(/1x,a,i2,t18,a,f10.4,t43,a,e9.2)') 'Iteration #',k,
     *       'Chi-squared:',chisq,'ALAMDA:',alamda
        write(*,'(1x,t5,a,t13,a,t21,a,t29,a,t37,a,t45,a)') 'A(1)',
     *       'A(2)','A(3)','A(4)','A(5)','A(6)'
        write(*,'(1x,6f8.4)') (a(i),i=1,6)
        k=k+1
        ochisq=chisq
        call mrqmin(x,y,sig,NPT,a,ia,MA,covar,alpha,
     *       MA,chisq,fgauss,alamda)
        if (chisq.gt.ochisq) then
          itst=0
        else if (abs(ochisq-chisq).lt.0.1) then
          itst=itst+1
        endif
        if (itst.lt.4) then
          goto 1
        endif
        alamda=0.0
        call mrqmin(x,y,sig,NPT,a,ia,MA,covar,alpha,
     *       MA,chisq,fgauss,alamda)
        write(*,*) 'Uncertainties:'
        write(*,'(1x,6f8.4/)') (sqrt(covar(i,i)),i=1,6)
        write(*,'(1x,a)') 'Expected results:'
        write(*,'(1x,f7.2,5f8.2/)') 5.0,2.0,3.0,2.0,5.0,3.0
        if (iter.eq.1) then
          write(*,*) 'press return to continue with constraint'
          read(*,*)
          write(*,*) 'Holding a(2) and a(5) constant'
          do 15 j=1,MA
            a(j)=a(j)+.1
15        continue
          a(2)=2.0
          ia(2)=0
          a(5)=5.0
          ia(5)=0
        endif
16    continue
      END
