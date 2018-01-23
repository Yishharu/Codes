      PROGRAM xsprsax
C     driver for routine sprsax
      INTEGER NP,NMAX
      PARAMETER(NP=5,NMAX=2*NP*NP+1)
      INTEGER i,j,msize,ija(NMAX)
      REAL a(NP,NP),sa(NMAX),ax(NP),b(NP),x(NP)
      DATA a/3.0,0.0,0.0,0.0,0.0,
     *     0.0,4.0,7.0,0.0,0.0,
     *     1.0,0.0,5.0,0.0,0.0,
     *     0.0,0.0,9.0,0.0,6.0,
     *     0.0,0.0,0.0,2.0,5.0/
      DATA x/1.0,2.0,3.0,4.0,5.0/
      call sprsin(a,NP,NP,0.5,NMAX,sa,ija)
      msize=ija(1)-2
      call sprsax(sa,ija,x,b,msize)
      do 12 i=1,msize
        ax(i)=0.0
        do 11 j=1,msize
          ax(i)=ax(i)+a(i,j)*x(j)
11      continue
12    continue
      write(*,'(t4,a,t18,a)') 'Reference','sprsax result'
      do 13 i=1,msize
        write(*,'(t4,f5.2,t22,f5.2)') ax(i),b(i)
13    continue
      END
