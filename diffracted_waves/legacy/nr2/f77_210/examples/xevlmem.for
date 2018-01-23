      PROGRAM xevlmem
C     driver for routine evlmem
      INTEGER N,NFDT,M
      PARAMETER(N=1000,M=10,NFDT=16)
      INTEGER i
      REAL evlmem,fdt,pm,data(N),cof(M)
      open(7,file='SPCTRL.DAT',status='old')
      read(7,*) (data(i),i=1,N)
      close(7)
      call memcof(data,N,M,pm,cof)
      write(*,*) 'Power spectrum estimate of DATA in SPCTRL.DAT'
      write(*,'(1x,t6,a,t20,a)') 'f*delta','power'
      do 11 i=0,NFDT
        fdt=0.5*i/NFDT
        write(*,'(1x,2f12.6)') fdt,evlmem(fdt,cof,M,pm)
11    continue
      END
