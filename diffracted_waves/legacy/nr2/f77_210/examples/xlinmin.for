      PROGRAM xlinmin
C     driver for routine linmin
      INTEGER NDIM
      REAL PIO2
      PARAMETER(NDIM=3,PIO2=1.5707963)
      INTEGER i,j
      REAL fret,sr2,x,p(NDIM),xi(NDIM)
      write(*,'(/1x,a)') 'Minimum of a 3-D quadratic centered'
      write(*,'(1x,a)') 'at (1.0,1.0,1.0). Minimum is found'
      write(*,'(1x,a)') 'along a series of radials.'
      write(*,'(/1x,t10,a,t22,a,t34,a,t42,a/)') 'x','y','z','minimum'
      do 11 i=0,10
        x=PIO2*i/10.0
        sr2=sqrt(2.0)
        xi(1)=sr2*cos(x)
        xi(2)=sr2*sin(x)
        xi(3)=1.0
        p(1)=0.0
        p(2)=0.0
        p(3)=0.0
        call linmin(p,xi,NDIM,fret)
        write(*,'(1x,4f12.6)') (p(j),j=1,3),fret
11    continue
      END

      REAL FUNCTION func(x)
      INTEGER i
      REAL x(3)
      func=0.0
      do 11 i=1,3
        func=func+(x(i)-1.0)**2
11    continue
      END
