      PROGRAM xigray
C     driver for routine igray
      INTEGER igray,jp,n,ng,nmax,nmin,nni,nxor
1     write(*,*) 'INPUT NMIN,NMAX:'
      read(*,*,END=999) nmin,nmax
      jp=max(1,(nmax-nmin)/11)
      write(*,*) 'n, Gray(n), Gray(Gray(n)), Gray(n).xor.Gray(n+1)'
      do 11 n=nmin,nmax
        ng=igray(n,1)
        nni=igray(ng,-1)
        if (nni.ne.n) write(*,*) 'WRONG ! AT ',n,ng,nni
        if (mod(n-nmin,jp).eq.0) then
          nxor=ieor(ng,igray(n+1,1))
          write(*,*) n,ng,nni,nxor
        endif
11    continue
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
