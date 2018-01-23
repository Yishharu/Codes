      PROGRAM xplgndr
C     driver for routine plgndr
      INTEGER i,j,m,n,nval
      REAL fac,plgndr,value,x
      CHARACTER text*27
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Legendre Polynomials') go to 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t9,a,t20,a,t35,a,t49,a)')
     *     'N','M','X','Actual','PLGNDR(N,M,X)'
      do 12 i=1,nval
        read(7,*) n,m,x,value
        fac=1.0
        if (m.gt.0) then
          do 11 j=n-m+1,n+m
            fac=fac*j
11        continue
        endif
        fac=2.0*fac/(2.0*n+1.0)
        value=value*sqrt(fac)
        write(*,'(1x,2i4,3e17.6)') n,m,x,value,plgndr(n,m,x)
12    continue
      close(7)
      END
