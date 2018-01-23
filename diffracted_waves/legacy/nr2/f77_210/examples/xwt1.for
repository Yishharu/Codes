      PROGRAM xwt1
C     driver for routine wt1
      INTEGER NCMAX,NMAX,NCEN,NWID
      PARAMETER(NMAX=512,NCMAX=50,NCEN=333,NWID=33)
      INTEGER i,itest,k,ncof,ioff,joff,nused
      REAL u(NMAX),v(NMAX),w(NMAX),cc,cr,frac,select,thresh,tmp
      COMMON /pwtcom/ cc(NCMAX),cr(NCMAX),ncof,ioff,joff
      EXTERNAL pwt,daub4
1     write(*,*) 'Enter k (4, -4, 12, or 20) and frac (0. to 1.):'
      read(*,*,END=999) k,frac
      frac=min(1.,max(0.,frac))
      if (k.eq.-4) then
        itest=1
      else
        itest=0
      endif
      k=abs(k)
      if (k.ne.4.and.k.ne.12.and.k.ne.20) goto 1
      do 11 i=1,NMAX
        if (i.gt.NCEN-NWID.and.i.lt.NCEN+NWID) then
          v(i)=float(i-NCEN+NWID)*float(NCEN+NWID-i)/NWID**2
        else
          v(i)=0.
        endif
        w(i)=v(i)
11    continue
      if (itest.eq.0) then
        call pwtset(k)
        call wt1(v,NMAX,1,pwt)
      else
        call wt1(v,NMAX,1,daub4)
      endif
      do 12 i=1,NMAX
        u(i)=abs(v(i))
12    continue
      thresh=select(int((1.-frac)*NMAX),NMAX,u)
      nused=0
      do 13 i=1,NMAX
        if (abs(v(i)).le.thresh) then
          v(i)=0.
        else
          nused=nused+1
        endif
13    continue
      if (itest.eq.0) then
        call wt1(v,NMAX,-1,pwt)
      else
        call wt1(v,NMAX,-1,daub4)
      endif
      thresh=0.
      do 14 i=1,NMAX
        tmp=abs(v(i)-w(i))
        if (tmp.gt.thresh) thresh=tmp
14    continue
      write(*,*) 'k,NMAX,nused=',k,NMAX,nused
      write(*,*) 'discrepancy=',thresh
      goto 1
999   END
