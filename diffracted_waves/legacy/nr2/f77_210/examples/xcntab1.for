      PROGRAM xcntab1
C     driver for routine cntab1
      INTEGER NDAT,NMON
      PARAMETER(NDAT=9,NMON=12)
      INTEGER i,j,nmbr(NDAT,NMON)
      REAL ccc,chisq,cramrv,df,prob
      CHARACTER fate(NDAT)*15,mon(NMON)*5,text*64
      open(7,file='TABLE.DAT',status='OLD')
      read(7,*)
      read(7,'(a)') text
      read(7,'(15x,12a5/)') (mon(i),i=1,12)
      do 11 i=1,NDAT
        read(7,'(a15,12i5)') fate(i),(nmbr(i,j),j=1,12)
11    continue
      close(7)
      write(*,'(/1x,a/)') text
      write(*,'(1x,15x,12a5)') (mon(i),i=1,12)
      do 12 i=1,NDAT
        write(*,'(1x,a,12i5)') fate(i),(nmbr(i,j),j=1,12)
12    continue
      call cntab1(nmbr,NDAT,NMON,chisq,df,prob,cramrv,ccc)
      write(*,'(/1x,a,t20,f20.2)') 'Chi-squared',chisq
      write(*,'(1x,a,t20,f20.2)') 'Degrees of Freedom',df
      write(*,'(1x,a,t20,f20.4)') 'Probability',prob
      write(*,'(1x,a,t20,f20.4)') 'Cramer-V',cramrv
      write(*,'(1x,a,t20,f20.4)') 'Contingency Coeff.',ccc
      END
