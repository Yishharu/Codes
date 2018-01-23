      PROGRAM xmedfit
C     driver for routine medfit
      INTEGER NPT
      REAL SPREAD
      PARAMETER(NPT=100,SPREAD=0.1)
      INTEGER i,idum,mwt
      REAL a,abdev,b,chi2,gasdev,q,siga,sigb,x(NPT),y(NPT),sig(NPT)
      idum=-1984
      do 11 i=1,NPT
        x(i)=0.1*i
        y(i)=-2.0*x(i)+1.0+SPREAD*gasdev(idum)
        sig(i)=SPREAD
11    continue
      mwt=1
      call fit(x,y,NPT,sig,mwt,a,b,siga,sigb,chi2,q)
      write(*,'(/1x,a)') 'According to routine FIT the result is:'
      write(*,'(1x,t5,a,f8.4,t20,a,f8.4)') 'A = ',a,'Uncertainty: ',
     *     siga
      write(*,'(1x,t5,a,f8.4,t20,a,f8.4)') 'B = ',b,'Uncertainty: ',
     *     sigb
      write(*,'(1x,t5,a,f8.4,a,i4,a)') 'Chi-squared: ',chi2,
     *     ' for ',NPT,' points'
      write(*,'(1x,t5,a,f8.4)') 'Goodness-of-fit: ',q
      write(*,'(/1x,a)') 'According to routine MEDFIT the result is:'
      call medfit(x,y,NPT,a,b,abdev)
      write(*,'(1x,t5,a,f8.4)') 'A = ',a
      write(*,'(1x,t5,a,f8.4)') 'B = ',b
      write(*,'(1x,t5,a,f8.4)') 'Absolute deviation (per DATA point): '
     *     ,abdev
      write(*,'(1x,t5,a,f8.4,a)') '(note: Gaussian SPREAD is',SPREAD,')'
      END
