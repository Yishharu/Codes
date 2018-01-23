      PROGRAM xbessik
C     driver for routine bessik
      INTEGER i,nval
      REAL ri,rk,rip,rkp,x,xnu,xri,xrk,xrip,xrkp
      CHARACTER text*25
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Modified Bessel Functions') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t3,a3,t8,a1)') 'XNU','X'
      write(*,'(1x,t5,a2,t21,a2,t37,a3,t53,a3)') 'RI','RK','RIP','RKP'
      write(*,'(1x,t5,a3,t21,a3,t37,a4,t53,a4)')
     *     'XRI','XRK','XRIP','XRKP'
      do 11 i=1,nval
        read(7,*) xnu,x,ri,rk,rip,rkp
        call bessik(x,xnu,xri,xrk,xrip,xrkp)
        write(*,'(2f6.2/1p4e16.6/1p4e16.6)')
     *       xnu,x,ri,rk,rip,rkp,xri,xrk,xrip,xrkp
11    continue
      close(7)
      END
