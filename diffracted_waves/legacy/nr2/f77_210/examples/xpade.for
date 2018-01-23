      PROGRAM xpade
C     driver for routine pade
      INTEGER NMAX
      PARAMETER(NMAX=100)
      INTEGER j,k,n
      REAL resid
      DOUBLE PRECISION b,d,fac,fn,ratval,x,c(NMAX),cc(NMAX)
1     write(*,*) 'Enter n for PADE routine:'
      read(*,*,END=999) n
      fac=1
      do 11 j=1,2*n+1
        c(j)=fac/dble(j)
        cc(j)=c(j)
        fac=-fac
11    continue
      call pade(c,n,resid)
      write(*,'(1x,a,1pd16.8)') 'Norm of residual vector=',resid
      write(*,*) 'point, func. value, pade series, power series'
      do 13 j=1,21
        x=(j-1)*0.25
        b=0.
        do 12 k=2*n+1,1,-1
          b=b*x+cc(k)
12      continue
        d=ratval(x,c,n,n)
        write(*,'(1p4d16.8)') x,fn(x),d,b
13    continue
      goto 1
999   END

      DOUBLE PRECISION FUNCTION fn(x)
      DOUBLE PRECISION x
      if (x.eq.0.) then
        fn=1.
      else
        fn=log(1.+x)/x
      endif
      return
      END
