      PROGRAM xfasper
C     driver for routine fasper
      INTEGER NP,MP,NPR
      REAL TWOPI
      PARAMETER(NP=90,MP=4096,NPR=11,TWOPI=6.2831853)
      INTEGER idum,j,jmax,n,nout
      REAL gasdev,prob,x(NP),y(NP),px(MP),py(MP)
      idum=-4
      j=0
      do 11 n=1,NP+10
        if (n.ne.3.and.n.ne.4.and.n.ne.6.and.n.ne.21.and.
     *       n.ne.38.and.n.ne.51.and.n.ne.67.and.n.ne.68.and.
     *       n.ne.83.and.n.ne.93) then
          j=j+1
          x(j)=n
          y(j)=0.75*cos(0.6*x(j))+gasdev(idum)
        endif
11    continue
      call fasper(x,y,j,4.,1.,px,py,MP,nout,jmax,prob)
      write(*,*) 'FASPER results for test signal (cos(0.6x) + noise):'
      write(*,*) 'NOUT,JMAX,PROB=',nout,jmax,prob
      do 12 n=max(1,jmax-NPR/2),min(nout,jmax+NPR/2)
        write(*,*) n,TWOPI*px(n),py(n)
12    continue
      END
