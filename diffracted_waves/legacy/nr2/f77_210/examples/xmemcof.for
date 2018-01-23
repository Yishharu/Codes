      PROGRAM xmemcof
C     driver for routine memcof
      INTEGER N,M
      PARAMETER(N=1000,M=10)
      INTEGER i
      REAL pm,data(N),cof(M)
      open(7,file='SPCTRL.DAT',status='OLD')
      read(7,*) (data(i),i=1,N)
      close(7)
      call memcof(data,N,M,pm,cof)
      write(*,'(/1x,a/)') 'Coeff. for spectral estim. of SPCTRL.DAT'
      do 11 i=1,M
        write(*,'(1x,a,i2,a,f12.6)') 'a[',i,'] =',cof(i)
11    continue
      write(*,'(/1x,a,f12.6/)') 'a0 =',pm
      END
