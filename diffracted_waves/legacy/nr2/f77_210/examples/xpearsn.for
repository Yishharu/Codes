      PROGRAM xpearsn
C     driver for routine pearsn
      INTEGER i
      REAL prob,r,z
      REAL dose(10),spore(10)
      DATA dose/56.1,64.1,70.0,66.6,82.,91.3,90.,99.7,115.3,110./
      DATA spore/0.11,0.4,0.37,0.48,0.75,0.66,0.71,1.2,1.01,0.95/
      write(*,'(1x,a)')
     *     'Effect of Gamma Rays on Man-in-the-Moon Marigolds'
      write(*,'(1x,a,t29,a)') 'Count Rate (cpm)','Pollen Index'
      do 11 i=1,10
        write(*,'(1x,f10.2,f25.2)') dose(i),spore(i)
11    continue
      call pearsn(dose,spore,10,r,prob,z)
      write(*,'(/1x,t24,a,t38,a)') 'PEARSN','Expected'
      write(*,'(1x,a,t18,2e15.6)') 'Corr. Coeff.',r,0.906959
      write(*,'(1x,a,t18,2e15.6)') 'Probability',prob,0.292650e-3
      write(*,'(1x,a,t18,2e15.6/)') 'Fisher''s Z',z,1.51011
      END
