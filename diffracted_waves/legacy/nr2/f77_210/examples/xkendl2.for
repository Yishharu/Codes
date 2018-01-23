      PROGRAM xkendl2
C     driver for routine kendl2
      INTEGER IP,JP,NDAT
      PARAMETER(NDAT=1000,IP=8,JP=8)
      INTEGER i,ifunc,irbit1,irbit2,iseed,j,k,l,m,n
      REAL prob,tau,z,tab(IP,JP)
      CHARACTER text(8)*3
      DATA text/'000','001','010','011','100','101','110','111'/
      write(*,*) 'Are ones followed by zeros and vice-versa?'
      i=IP
      j=JP
      do 17 ifunc=1,2
        iseed=2468
        write(*,'(/1x,a,i1/)') 'Test of IRBIT',ifunc
        do 12 k=1,i
          do 11 l=1,j
            tab(k,l)=0.0
11        continue
12      continue
        do 15 m=1,NDAT
          k=1
          do 13 n=0,2
            if (ifunc.eq.1) then
              k=k+irbit1(iseed)*(2**n)
            else
              k=k+irbit2(iseed)*(2**n)
            endif
13        continue
          l=1
          do 14 n=0,2
            if (ifunc.eq.1) then
              l=l+irbit1(iseed)*(2**n)
            else
              l=l+irbit2(iseed)*(2**n)
            endif
14        continue
          tab(k,l)=tab(k,l)+1.0
15      continue
        call kendl2(tab,i,j,IP,JP,tau,z,prob)
        write(*,'(4x,8a6/)') (text(n),n=1,8)
        do 16 n=1,8
          write(*,'(1x,a,8i6)') text(n),(nint(tab(n,m)),m=1,8)
16      continue
        write(*,'(/7x,a,t24,a,t38,a)') 'Kendall Tau','Std. Dev.',
     *       'Probability'
        write(*,'(1x,3f15.6/)') tau,z,prob
        write(*,*) 'Press RETURN to continue ...'
        read(*,*)
17    continue
      END
