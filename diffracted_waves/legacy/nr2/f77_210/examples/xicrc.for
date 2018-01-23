      PROGRAM xicrc
C     driver for routine icrc
      INTEGER i1,i2,j,n
      INTEGER icrc,iand
      CHARACTER*10 hexout
      CHARACTER*1 lin(80),chbyt(2)
1     write(*,*) 'ENTER LENGTH,STRING: '
      read(*,'(i3,80a1)',END=999) n,(lin(j),j=1,n)
      write(*,*) (lin(j),j=1,n)
      i1=icrc(chbyt,lin,n,0,1)
      lin(n+1)=chbyt(2)
      lin(n+2)=chbyt(1)
      i2=icrc(chbyt,lin,n+2,0,1)
      write(*,'(''    XMODEM: String CRC, Packet CRC='',2a12)')
     *     hexout(i1),hexout(i2)
      i1=icrc(chbyt,lin,n,255,-1)
      lin(n+1)=char(iand(255,not(ichar(chbyt(1)))))
      lin(n+2)=char(iand(255,not(ichar(chbyt(2)))))
      i2=icrc(chbyt,lin,n+2,255,-1)
      write(*,'(''      X.25: String CRC, Packet CRC='',2a12)')
     *     hexout(i1),hexout(i2)
      i1=icrc(chbyt,lin,n,0,-1)
      lin(n+1)=chbyt(1)
      lin(n+2)=chbyt(2)
      i2=icrc(chbyt,lin,n+2,0,-1)
      write(*,'('' CRC-CCITT: String CRC, Packet CRC='',2a12)')
     *     hexout(i1),hexout(i2)
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END

      FUNCTION hexout(num)
C     Numerical Recipes Fortran utility routine for printing out hexadecimal
      CHARACTER*10 hexout
      INTEGER NCOMP
      PARAMETER (NCOMP=268435455)
      INTEGER i,j,n,num
      CHARACTER*1 hexit(16)
      SAVE hexit
      DATA hexit /'0','1','2','3','4','5','6','7','8','9',
     *     'a','b','c','d','e','f'/
      n=num
      if (n.lt.0) then
        i=mod(n,16)
        if (i.lt.0) i=16+i
        n=n/16
        n=-n
        if (i.ne.0) then
          n=NCOMP-n
        else
          n=NCOMP+1-n
        endif
      else
        i=mod(n,16)
        n=n/16
      endif
      j=10
      hexout(j:j)=hexit(i+1)
2     if (n.gt.0) then
        i=mod(n,16)
        n=n/16
        j=j-1
        hexout(j:j)=hexit(i+1)
      goto 2
      endif
      j=j-1
      hexout(j:j)='x'
      j=j-1
      hexout(j:j)='0'
      do 11 i=j-1,1,-1
        hexout(i:i)=' '
11    continue
      return
      END
