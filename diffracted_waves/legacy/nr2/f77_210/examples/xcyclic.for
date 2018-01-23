      PROGRAM xcyclic
C     driver for routine cyclic
      INTEGER N
      PARAMETER (N=20)
      REAL alpha,beta,d,ran2
      REAL a(N),b(N),c(N),r(N),x(N),aa(N,N)
      INTEGER indx(N)
      INTEGER i,j,idum
      idum= -23
      do 12 i=1,N
        do 11 j=1,N
          aa(i,j)=0.
11      continue
12    continue
      do 13 i=1,N
        b(i)=ran2(idum)
        aa(i,i)=b(i)
        r(i)=ran2(idum)
13    continue
      do 14 i=1,N-1
        a(i+1)=ran2(idum)
        aa(i+1,i)=a(i+1)
        c(i)=ran2(idum)
        aa(i,i+1)=c(i)
14    continue
      alpha=ran2(idum)
      aa(N,1)=alpha
      beta=ran2(idum)
      aa(1,N)=beta
      call cyclic(a,b,c,alpha,beta,r,x,N)
      call ludcmp(aa,N,N,indx,d)
      call lubksb(aa,N,N,indx,r)
      do 15 i=1,N
        write(*,*) i,(x(i)-r(i))/(x(i)+r(i))
15    continue
      END
