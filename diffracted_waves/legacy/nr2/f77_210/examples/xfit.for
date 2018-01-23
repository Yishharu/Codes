      PROGRAM xfit
C     driver for routine fit
      INTEGER NPT
      REAL SPREAD
      PARAMETER(NPT=100,SPREAD=0.5)
      INTEGER i,idum,mwt
      REAL a,b,chi2,gasdev,q,siga,sigb,sig(NPT),x(NPT),y(NPT)
      idum=-117
      do 11 i=1,NPT
        x(i)=0.1*i
        y(i)=-2.0*x(i)+1.0+SPREAD*gasdev(idum)
        sig(i)=SPREAD
11    continue
      do 12 mwt=0,1
        call fit(x,y,NPT,sig,mwt,a,b,siga,sigb,chi2,q)
        if (mwt.eq.0) then
          write(*,'(//1x,a)') 'Ignoring standard deviation'
        else
          write(*,'(//1x,a)') 'Including standard deviation'
        endif
        write(*,'(1x,t5,a,f9.6,t24,a,f9.6)') 'A = ',a,'Uncertainty: ',
     *       siga
        write(*,'(1x,t5,a,f9.6,t24,a,f9.6)') 'B = ',b,'Uncertainty: ',
     *       sigb
        write(*,'(1x,t5,a,4x,f10.6)') 'Chi-squared: ',chi2
        write(*,'(1x,t5,a,f10.6)') 'Goodness-of-fit: ',q
12    continue
      END
