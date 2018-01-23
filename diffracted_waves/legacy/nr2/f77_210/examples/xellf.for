      PROGRAM xellf
C     driver for routine ellf
      REAL FAC
      PARAMETER (FAC=3.1415926535/180.)
      INTEGER i,nval
      REAL ak,alpha,ellf,phi,value
      CHARACTER text*37
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Legendre Elliptic Integral First Kind') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t4,a3,t9,a10,t23,a6,t41,a12)')
     *     'PHI','SIN(ALPHA)','Actual','ELLF(PHI,AK)'
      do 11 i=1,nval
        read(7,*) phi,alpha,value
        alpha=alpha*FAC
        ak=sin(alpha)
        phi=phi*FAC
        write(*,'(2f6.2,2e20.6)') phi,ak,value,ellf(phi,ak)
11    continue
      close(7)
      END
