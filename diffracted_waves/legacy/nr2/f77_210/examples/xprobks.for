      PROGRAM xprobks
C     driver for routine probks
      INTEGER i,j,npts
      REAL alam,eps,probks,scale,value
      CHARACTER text(50)*1
      write(*,*) 'Probability func. for Kolmogorov-Smirnov statistic'
      write(*,'(/1x,t3,a,t15,a,t27,a)') 'Lambda:','Value:','Graph:'
      npts=20
      eps=0.1
      scale=40.0
      do 12 i=1,npts
        alam=i*eps
        value=probks(alam)
        text(1)='*'
        do 11 j=1,50
          if (j.le.nint(scale*value)) then
            text(j)='*'
          else
            text(j)=' '
          endif
11      continue
        write(*,'(1x,f9.6,f12.6,4x,50a1)') alam,value,
     *       (text(j),j=1,50)
12    continue
      END
