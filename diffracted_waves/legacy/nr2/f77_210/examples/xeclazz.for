      PROGRAM xeclazz
C     driver for routine eclazz
      LOGICAL equiv
      INTEGER N
      PARAMETER(N=15)
      INTEGER i,j,k,lclas,nclass,nf(N),nflag(N),nsav(N)
      EXTERNAL equiv
      call eclazz(nf,N,equiv)
      do 11 i=1,N
        nflag(i)=1
11    continue
      write(*,'(/1x,a)') 'Numbers from 1-15 divided according to'
      write(*,'(1x,a/)') 'their value modulo 4:'
      lclas=0
      do 13 i=1,N
        nclass=nf(i)
        if (nflag(nclass).ne.0) then
          nflag(nclass)=0
          lclas=lclas+1
          k=0
          do 12 j=i,N
            if (nf(j).eq.nf(i)) then
              k=k+1
              nsav(k)=j
            endif
12        continue
          write(*,'(1x,a,i2,a,3x,5i3)') 'Class',
     *         lclas,':',(nsav(j),j=1,k)
        endif
13    continue
      END

      LOGICAL FUNCTION equiv(i,j)
      INTEGER i,j
      equiv=.false.
      if (mod(i,4).eq.mod(j,4)) equiv=.true.
      return
      END
