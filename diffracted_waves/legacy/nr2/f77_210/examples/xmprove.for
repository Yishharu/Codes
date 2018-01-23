      PROGRAM xmprove
C     driver for routine mprove
      INTEGER N,NP
      PARAMETER(N=5,NP=5)
      INTEGER i,j,idum,indx(N)
      REAL d,a(NP,NP),b(N),x(N),aa(NP,NP),ran3
      DATA a/1.0,2.0,1.0,4.0,5.0,2.0,3.0,1.0,5.0,1.0,
     *     3.0,4.0,1.0,1.0,2.0,4.0,5.0,1.0,2.0,3.0,
     *     5.0,1.0,1.0,3.0,4.0/
      DATA b/1.0,1.0,1.0,1.0,1.0/
      do 12 i=1,N
        x(i)=b(i)
        do 11 j=1,N
          aa(i,j)=a(i,j)
11      continue
12    continue
      call ludcmp(aa,N,NP,indx,d)
      call lubksb(aa,N,NP,indx,x)
      write(*,'(/1x,a)') 'Solution vector for the equations:'
      write(*,'(1x,5f12.6)') (x(i),i=1,N)
C     now phoney up x and let mprove fix it
      idum=-13
      do 13 i=1,N
        x(i)=x(i)*(1.0+0.2*ran3(idum))
13    continue
      write(*,'(/1x,a)') 'Solution vector with noise added:'
      write(*,'(1x,5f12.6)') (x(i),i=1,N)
      call mprove(a,aa,N,NP,indx,b,x)
      write(*,'(/1x,a)') 'Solution vector recovered by MPROVE:'
      write(*,'(1x,5f12.6)') (x(i),i=1,N)
      END
