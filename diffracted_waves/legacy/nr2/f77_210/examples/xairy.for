      PROGRAM xairy
C     driver for routine airy
      INTEGER i,nval
      REAL ai,bi,aip,bip,x,xai,xbi,xaip,xbip
      CHARACTER text*14
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Airy Functions') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t3,a1)') 'X'
      write(*,'(1x,t5,a2,t21,a2,t37,a3,t53,a3)') 'AI','BI','AIP','BIP'
      write(*,'(1x,t5,a3,t21,a3,t37,a4,t53,a4)')
     *     'XAI','XBI','XAIP','XBIP'
      do 11 i=1,nval
        read(7,*) x,ai,bi,aip,bip
        call airy(x,xai,xbi,xaip,xbip)
        write(*,'(f6.2/1p4e16.6/1p4e16.6)')
     *       x,ai,bi,aip,bip,xai,xbi,xaip,xbip
11    continue
      close(7)
      END
