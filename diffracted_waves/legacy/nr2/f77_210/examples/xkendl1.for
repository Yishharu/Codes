      PROGRAM xkendl1
C     driver for routine kendl1
      INTEGER NDAT
      PARAMETER(NDAT=200)
      INTEGER i,idum,j
      REAL prob,ran0,ran1,ran2,ran3,ran4,tau,z
      REAL data1(NDAT),data2(NDAT)
      CHARACTER text(5)*4
      DATA text/'RAN0','RAN1','RAN2','RAN3','RAN4'/
      write(*,'(/1x,a/)') 'Pair correlations of RAN0 ... RAN4'
      write(*,'(2x,a,t16,a,t34,a,t50,a,/)')
     *     'Program','Kendall Tau','Std. Dev.','Probability'
      do 12 i=1,5
        idum=-1357
        do 11 j=1,NDAT
          if (i.eq.1) then
            data1(j)=ran0(idum)
            data2(j)=ran0(idum)
          else if (i.eq.2) then
            data1(j)=ran1(idum)
            data2(j)=ran1(idum)
          else if (i.eq.3) then
            data1(j)=ran2(idum)
            data2(j)=ran2(idum)
          else if (i.eq.4) then
            data1(j)=ran3(idum)
            data2(j)=ran3(idum)
          else if (i.eq.5) then
            data1(j)=ran4(idum)
            data2(j)=ran4(idum)
          endif
11      continue
        call kendl1(data1,data2,NDAT,tau,z,prob)
        write(*,'(1x,t4,a,3f17.6)') text(i),tau,z,prob
12    continue
      END
