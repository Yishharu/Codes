      PROGRAM xsncndn
C     driver for routine sncndn
      INTEGER i,nval
      REAL cn,dn,em,emmc,resul1,resul2,sn,uu,value
      CHARACTER text*26
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Jacobian Elliptic Function') go to 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t4,a,t13,a,t21,a,t38,a,t49,a,t60,a)')
     *     'Mc','U','Actual','SN','SN^2+CN^2',
     *     '(Mc)*(SN^2)+DN^2'
      do 11 i=1,nval
        read(7,*) em,uu,value
        emmc=1.0-em
        call sncndn(uu,emmc,sn,cn,dn)
        resul1=sn*sn+cn*cn
        resul2=em*sn*sn+dn*dn
        write(*,'(1x,f5.2,f8.2,2e15.5,f12.5,f14.5)')
     *       emmc,uu,value,sn,resul1,resul2
11    continue
      close(7)
      END
