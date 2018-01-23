      PROGRAM xsplin2
C     driver for routine splin2
      INTEGER M,N
      PARAMETER(M=10,N=10)
      INTEGER i,j
      REAL f,ff,x1x2,xx1,xx2,x1(M),x2(N),y(M,N),y2(M,N)
      do 11 i=1,M
        x1(i)=0.2*i
11    continue
      do 12 i=1,N
        x2(i)=0.2*i
12    continue
      do 14 i=1,M
        do 13 j=1,N
          x1x2=x1(i)*x2(j)
          y(i,j)=x1x2*exp(-x1x2)
13      continue
14    continue
      call splie2(x1,x2,y,M,N,y2)
      write(*,'(/1x,t9,a,t21,a,t31,a,t43,a)')
     *     'x1','x2','splin2','actual'
      do 15 i=1,10
        xx1=0.1*i
        xx2=xx1**2
        call splin2(x1,x2,y,y2,M,N,xx1,xx2,f)
        x1x2=xx1*xx2
        ff=x1x2*exp(-x1x2)
        write(*,'(1x,4f12.6)') xx1,xx2,f,ff
15    continue
      END
