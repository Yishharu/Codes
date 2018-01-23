      PROGRAM xavevar
C     driver for routine avevar
      INTEGER NPTS
      REAL EPS
      PARAMETER(NPTS=1000, EPS=0.1)
      INTEGER i,idum,j
      REAL ave,gasdev,shift,var,data(NPTS)
C     generate Gaussian distributed data
      idum=-5
      write(*,'(1x,t4,a,t14,a,t26,a)') 'Shift','Average','Variance'
      do 12 i=1,11
        shift=(i-1)*EPS
        do 11 j=1,NPTS
          data(j)=shift+i*gasdev(idum)
11      continue
        call avevar(data,NPTS,ave,var)
        write(*,'(1x,f6.2,2f12.2)') shift,ave,var
12    continue
      END
