      PROGRAM xcorrel
C     driver for routine correl
      INTEGER N,N2
      REAL PI
      PARAMETER(N=64,N2=128,PI=3.1415927)
      INTEGER i,j
      REAL cmp,data1(N),data2(N),ans(N2)
      do 11 i=1,N
        data1(i)=0.0
        if ((i.gt.(N/2-N/8)).and.(i.lt.(N/2+N/8))) data1(i)=1.0
        data2(i)=data1(i)
11    continue
      call correl(data1,data2,N,ans)
C     calculate directly
      write(*,'(/1x,t4,a,t13,a,t25,a/)') 'n','CORREL','Direct Calc.'
      do 13 i=0,16
        cmp=0.0
        do 12 j=1,N
          cmp=cmp+data1(mod(i+j-1,N)+1)*data2(j)
12      continue
        write(*,'(1x,i3,3x,f12.6,f15.6)') i,ans(i+1),cmp
13    continue
      END
