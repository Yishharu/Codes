      PROGRAM xconvlv
C     driver for routine convlv
      INTEGER N,N2,M
      REAL PI
      PARAMETER(N=16,N2=32,M=9,PI=3.14159265)
      INTEGER i,isign,j
      REAL cmp,data(N),respns(M),resp(N),ans(N2)
      do 11 i=1,N
        data(i)=0.0
        if ((i.ge.(N/2-N/8)).and.(i.le.(N/2+N/8))) data(i)=1.0
11    continue
      do 12 i=1,M
        respns(i)=0.0
        if (i.gt.2 .and. i.lt.7) respns(i)=1.0
        resp(i)=respns(i)
12    continue
      isign=1
      call convlv(data,N,resp,M,isign,ans)
C     compare with a direct convolution
      write(*,'(/1x,t4,a,t13,a,t24,a)') 'I','CONVLV','Expected'
      do 14 i=1,N
        cmp=0.0
        do 13 j=1,M/2
          cmp=cmp+data(mod(i-j-1+N,N)+1)*respns(j+1)
          cmp=cmp+data(mod(i+j-1,N)+1)*respns(M-j+1)
13      continue
        cmp=cmp+data(i)*respns(1)
        write(*,'(1x,i3,3x,2f12.6)') i,ans(i),cmp
14    continue
      END
