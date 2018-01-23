      PROGRAM xsort3
C     driver for routine sort3
      INTEGER NLEN
      PARAMETER(NLEN=64)
      INTEGER i,j,indx(NLEN)
      REAL a(NLEN),b(NLEN),c(NLEN),wksp(NLEN)
      CHARACTER msg1*33,msg2*31
      CHARACTER msg*64,amsg(64)*1,bmsg(64)*1,cmsg(64)*1
      EQUIVALENCE(msg,amsg(1)),(msg1,amsg(1)),(msg2,amsg(34))
      DATA msg1/'I''d rather have a bottle in front'/
      DATA msg2/' of me than a frontal lobotomy.'/
      write(*,*) 'Original message:'
      write(*,'(1x,64a1,/)') (amsg(j),j=1,64)
C     read array of random numbers
      open(7,file='TARRAY.DAT',status='OLD')
      read(7,*) (a(i),i=1,NLEN)
      close(7)
C     create array B and array C
      do 11 i=1,NLEN
        b(i)=i
        c(i)=NLEN+1-i
11    continue
C     sort array A while mixing B and C
      call sort3(NLEN,a,b,c,wksp,indx)
C     scramble message according to array B
      do 12 i=1,NLEN
        j=b(i)
        bmsg(i)=amsg(j)
12    continue
      write(*,*) 'Scrambled message:'
      write(*,'(1x,64a1,/)') (bmsg(j),j=1,64)
C     unscramble according to array C
      do 13 i=1,NLEN
        j=c(i)
        cmsg(j)=bmsg(i)
13    continue
      write(*,*) 'Mirrored message:'
      write(*,'(1x,64a1,/)') (cmsg(j),j=1,64)
      END
