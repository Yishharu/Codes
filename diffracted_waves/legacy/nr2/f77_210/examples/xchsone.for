      PROGRAM xchsone
C     driver for routine chsone
      INTEGER NBINS,NPTS
      PARAMETER(NBINS=10,NPTS=2000)
      INTEGER i,ibin,idum,j
      REAL chsq,df,expdev,prob,x,bins(NBINS),ebins(NBINS)
      idum=-15
      do 11 j=1,NBINS
        bins(j)=0.0
11    continue
      do 12 i=1,NPTS
        x=expdev(idum)
        ibin=x*NBINS/3.0+1
        if (ibin.le.NBINS) bins(ibin)=bins(ibin)+1.0
12    continue
      do 13 i=1,NBINS
        ebins(i)=3.0*NPTS/NBINS*exp(-3.0*(i-0.5)/NBINS)
13    continue
      call chsone(bins,ebins,NBINS,0,df,chsq,prob)
      write(*,'(1x,t10,a,t25,a)') 'Expected','Observed'
      do 14 i=1,NBINS
        write(*,'(1x,2f15.2)') ebins(i),bins(i)
14    continue
      write(*,'(/1x,t9,a,e12.4)') 'Chi-squared:',chsq
      write(*,'(1x,t9,a,e12.4)') 'Probability:',prob
      END
