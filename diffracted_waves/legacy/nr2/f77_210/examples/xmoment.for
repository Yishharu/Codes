      PROGRAM xmoment
C     driver for routine moment
      REAL PI
      INTEGER NBIN,NDAT,NPTS
      PARAMETER(PI=3.14159265,NPTS=10000,NBIN=100,NDAT=NPTS+NBIN)
      INTEGER i,j,k,nlim
      REAL adev,ave,curt,data(NDAT),sdev,skew,var,x
      i=1
      do 12 j=1,NBIN
        x=PI*j/NBIN
        nlim=nint(sin(x)*PI/2.0*NPTS/NBIN)
        do 11 k=1,nlim
          data(i)=x
          i=i+1
11      continue
12    continue
      write(*,'(1x,a/)') 'Moments of a sinusoidal distribution'
      call moment(data,i-1,ave,adev,sdev,var,skew,curt)
      write(*,'(1x,t29,a,t42,a/)') 'Calculated','Expected'
      write(*,'(1x,a,t25,2f12.4)') 'Mean :',ave,PI/2.0
      write(*,'(1x,a,t25,2f12.4)') 'Average Deviation :',adev,0.570796
      write(*,'(1x,a,t25,2f12.4)') 'Standard Deviation :',sdev,0.683667
      write(*,'(1x,a,t25,2f12.4)') 'Variance :',var,0.467401
      write(*,'(1x,a,t25,2f12.4)') 'Skewness :',skew,0.0
      write(*,'(1x,a,t25,2f12.4)') 'Kurtosis :',curt,-0.806249
      END
