      PROGRAM xeclass
C     driver for routine eclass
      INTEGER N,M
      PARAMETER(N=15,M=11)
      INTEGER i,j,k,lclas,nclass,
     *     lista(M),listb(M),nf(N),nflag(N),nsav(N)
      DATA lista/1,1,5,2,6,2,7,11,3,4,12/
      DATA listb/5,9,13,6,10,14,3,7,15,8,4/
      call eclass(nf,N,lista,listb,M)
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
