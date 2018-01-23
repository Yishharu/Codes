      PROGRAM xellpi
C     driver for routine ellpi
      REAL FAC
      PARAMETER (FAC=3.1415926535/180.)
      INTEGER i,nval
      REAL ak,alpha,ellpi,en,phi,value
      CHARACTER text*37
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Legendre Elliptic Integral Third Kind') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t4,a3,t10,a3,t15,a10,t29,a6,t47,a16)')
     *     'PHI','-EN','SIN(ALPHA)','Actual','ELLPI(PHI,EN,AK)'
      do 11 i=1,nval
        read(7,*) phi,en,alpha,value
        alpha=alpha*FAC
        ak=sin(alpha)
        en=-en
        phi=phi*FAC
        write(*,'(3f6.2,2e20.6)') phi,en,ak,value,ellpi(phi,en,ak)
11    continue
      close(7)
      END
