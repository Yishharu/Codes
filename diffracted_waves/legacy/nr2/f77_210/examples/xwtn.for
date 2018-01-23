      PROGRAM xwtn
C     driver for routine wtn
      INTEGER NCMAX,NX,NY
      REAL EPS
      PARAMETER(NCMAX=50,NX=128,NY=256,EPS=1.e-06)
      INTEGER ncof,ioff,joff,i,j,nerror,ntot
      REAL a(NX,NY),aorg(NX,NY),cc,cr
      COMMON /pwtcom/ cc(NCMAX),cr(NCMAX),ncof,ioff,joff
      INTEGER ndim(2)
      EXTERNAL pwt
      DATA ndim /NX,NY/
      nerror=0
      ntot=NX*NY
      do 12 i=1,NX
        do 11 j=1,NY
          if (i.eq.j) then
            a(i,j)=-1.
          else
            a(i,j)=1./sqrt(abs(float(i-j)))
          endif
          aorg(i,j)=a(i,j)
11      continue
12    continue
      call pwtset(12)
      call wtn(a,ndim,2,1,pwt)
C     here, one might set the smallest components to zero, encode and transmit
C     the remaining components as a compressed form of the "image"
      call wtn(a,ndim,2,-1,pwt)
      do 14 i=1,NX
        do 13 j=1,NY
          if (abs(aorg(i,j)-aorg(i,j)).ge.EPS) then
            write(*,*) 'Compare Error at element ',i,j
            nerror=nerror+1
          endif
13      continue
14    continue
      if (nerror.ne.0) then
        write(*,*) 'Number of comparision errors: ',nerror
      else
        write(*,*) 'Transform-inverse transform check OK'
      endif
      END
