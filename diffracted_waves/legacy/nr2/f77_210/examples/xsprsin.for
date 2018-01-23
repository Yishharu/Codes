      PROGRAM xsprsin
C     driver for routine sprsin
      INTEGER NP,NMAX
      PARAMETER(NP=5,NMAX=2*NP*NP+1)
      INTEGER i,j,msize,ija(NMAX)
      REAL a(NP,NP),aa(NP,NP),sa(NMAX)
      DATA a/3.0,0.0,0.0,0.0,0.0,
     *     0.0,4.0,7.0,0.0,0.0,
     *     1.0,0.0,5.0,0.0,0.0,
     *     0.0,0.0,9.0,0.0,6.0,
     *     0.0,0.0,0.0,2.0,5.0/
      call sprsin(a,NP,NP,0.5,NMAX,sa,ija)
      msize=ija(ija(1)-1)-1
      sa(NP+1)=0.0
      write(*,'(t4,a,t18,a,t24,a)') 'index','ija','sa'
      do 11 i=1,msize
        write(*,'(t2,i4,t16,i4,t20,f12.6)') i,ija(i),sa(i)
11    continue
      do 13 i=1,NP
        do 12 j=1,NP
          aa(i,j)=0.0
12      continue
13    continue
      do 15 i=1,NP
        aa(i,i)=sa(i)
        do 14 j=ija(i),ija(i+1)-1
          aa(i,ija(j))=sa(j)
14      continue
15    continue
      write(*,*) 'Original matrix:'
      write(*,'(5f7.1)') ((a(i,j),j=1,NP),i=1,NP)
      write(*,*) 'Reconstructed matrix:'
      write(*,'(5f7.1)') ((aa(i,j),j=1,NP),i=1,NP)
      END
