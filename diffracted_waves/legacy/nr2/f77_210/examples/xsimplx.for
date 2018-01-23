      PROGRAM xsimplx
C     driver for routine simplx
      INTEGER N,M,NP,MP,M1,M2,M3,NM1M2
      PARAMETER(N=4,M=4,NP=5,MP=6,M1=2,M2=1,M3=1,NM1M2=N+M1+M2)
      INTEGER i,icase,j,jj,jmax,izrov(N),iposv(M)
      REAL a(MP,NP),anum(NP)
      CHARACTER txt(NM1M2)*2,alpha(NP)*2
      LOGICAL rite
      DATA txt/'x1','x2','x3','x4','y1','y2','y3'/
      DATA a/0.0,740.0,0.0,0.5,9.0,0.0,1.0,-1.0,0.0,0.0,-1.0,0.0,
     *     1.0,0.0,-2.0,-1.0,-1.0,0.0,3.0,-2.0,0.0,1.0,-1.0,0.0,
     *     -0.5,0.0,7.0,-2.0,-1.0,0.0/
      call simplx(a,M,N,MP,NP,M1,M2,M3,icase,izrov,iposv)
      if (icase.eq.1) then
        write(*,*) 'Unbounded objective function'
      else if (icase.eq.-1) then
        write(*,*) 'No solutions satisfy constraints given'
      else
        jj=1
        do 11 i=1,N
          if (izrov(i).le.NM1M2) then
            alpha(jj)=txt(izrov(i))
            jj=jj+1
          endif
11      continue
        jmax=jj-1
        write(*,'(/3x,5a10)') '  ',(alpha(jj),jj=1,jmax)
        do 13 i=1,M+1
          if (i.eq.1) then
            alpha(1)='  '
            rite=.true.
          else if (iposv(i-1).le.NM1M2) then
            alpha(1)=txt(iposv(i-1))
            rite=.true.
          else
            rite=.false.
          endif
          if (rite) then
            anum(1)=a(i,1)
            jj=2
            do 12 j=2,N+1
              if (izrov(j-1).le.NM1M2) then
                anum(jj)=a(i,j)
                jj=jj+1
              endif
12          continue
            jmax=jj-1
            write(*,'(1x,a3,(5f10.2))') alpha(1),(anum(jj),jj=1,jmax)
          endif
13      continue
      endif
      END
