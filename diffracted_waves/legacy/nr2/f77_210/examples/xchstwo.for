      PROGRAM xchstwo
C     driver for routine chstwo
      INTEGER NBINS,NPTS
      PARAMETER(NBINS=10,NPTS=2000)
      INTEGER i,ibin,idum,j
      REAL chsq,df,expdev,prob,x,bins1(NBINS),bins2(NBINS)
      idum=-17
      do 11 j=1,NBINS
        bins1(j)=0.0
        bins2(j)=0.0
11    continue
      do 12 i=1,NPTS
        x=expdev(idum)
        ibin=x*NBINS/3.0+1
        if (ibin.le.NBINS) bins1(ibin)=bins1(ibin)+1.0
        x=expdev(idum)
        ibin=x*NBINS/3.0+1
        if (ibin.le.NBINS) bins2(ibin)=bins2(ibin)+1.0
12    continue
      call chstwo(bins1,bins2,NBINS,0,df,chsq,prob)
      write(*,'(1x,t10,a,t25,a)') 'Dataset 1','Dataset 2'
      do 13 i=1,NBINS
        write(*,'(1x,2f15.2)') bins1(i),bins2(i)
13    continue
      write(*,'(/1x,t10,a,e12.4)') 'Chi-squared:',chsq
      write(*,'(1x,t10,a,e12.4)') 'Probability:',prob
      END
