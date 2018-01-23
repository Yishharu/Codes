      PROGRAM xbessjy
C     driver for routine bessjy
      INTEGER i,nval
      REAL rj,ry,rjp,ryp,x,xnu,xrj,xry,xrjp,xryp
      CHARACTER text*25
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Ordinary Bessel Functions') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t3,a3,t8,a1)') 'XNU','X'
      write(*,'(1x,t5,a2,t21,a2,t37,a3,t53,a3)') 'RJ','RY','RJP','RYP'
      write(*,'(1x,t5,a3,t21,a3,t37,a4,t53,a4)')
     *     'XRJ','XRY','XRJP','XRYP'
      do 11 i=1,nval
        read(7,*) xnu,x,rj,ry,rjp,ryp
        call bessjy(x,xnu,xrj,xry,xrjp,xryp)
        write(*,'(2f6.2/1p4e16.6/1p4e16.6)')
     *       xnu,x,rj,ry,rjp,ryp,xrj,xry,xrjp,xryp
11    continue
      close(7)
      END
