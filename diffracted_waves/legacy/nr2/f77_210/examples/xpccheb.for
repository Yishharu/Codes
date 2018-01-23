      PROGRAM xpccheb
C     driver for routine pccheb
      INTEGER NCHECK,NFEW,NMANY,NMAX
      REAL PI
      PARAMETER(NCHECK=15,NFEW=13,NMANY=17,NMAX=100,PI=3.14159265)
      INTEGER i,j
      REAL a,b,fac,f,sum,sume,py,py2,c(NMAX),d(NMAX),e(NMAX),ee(NMAX)
C     put power series of cos(PI*y) into e
      fac=1.
      do 11 j=1,NMANY
        i=mod(j-1,4)
        if (i.eq.1.or.i.eq.3) then
          e(j)=0.
        else if (i.eq.0) then
          e(j)=1./fac
        else
          e(j)=-1./fac
        endif
        fac=fac*j
        ee(j)=e(j)
11    continue
      a=-PI
      b=PI
      call pcshft((-2.-b-a)/(b-a),(2.-b-a)/(b-a),e,NMANY)
C     i.e., inverse of PCSHFT(A,B,...) which we do below
      call pccheb(e,c,NMANY)
      write(*,*) 'Index, series, Chebyshev coefficients'
      do 12 j=1,NMANY,2
        write(*,'(i3,2e15.6)') j,e(j),c(j)
12    continue
      call chebpc(c,d,NFEW)
      call pcshft(a,b,d,NFEW)
      write(*,*) 'Index, new series, coefficient ratios'
      do 13 j=1,NFEW,2
        write(*,'(i3,2e15.6)') j,d(j),d(j)/(ee(j)+1.e-30)
13    continue
      write(*,'(7x,a)')
     *'Point tested, function value, error power series, error Cheb.'
      do 15 i=0,15
        py=(a+i*(b-a)/15.)
        py2=py*py
        sum=0.
        sume=0.
        fac=1.
        do 14 j=1,NFEW,2
          sum=sum+fac*d(j)
          sume=sume+fac*ee(j)
          fac=fac*py2
14      continue
        f=cos(py)
      write(*,'(1x,a,4e15.6)') 'check:',py,f,sume-f,sum-f
15    continue
      END
