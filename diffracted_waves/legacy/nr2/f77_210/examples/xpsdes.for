      PROGRAM xpsdes
C     driver for routine psdes
      CHARACTER*10 hexout
      INTEGER*4 i,lword(4),irword(4),lans(4),irans(4)
      DATA lword /1,1,99,99/, irword /1,99,1,99/
      DATA lans /1615666638,-645954191,2015506589,-671910160/
      DATA irans /1352404003,-1502825446,1680869764,1505397227/
      do 11 i=1,4
        call psdes(lword(i),irword(i))
        write(*,*) 'PSDES now calculates:       ',
     *       hexout(lword(i)),'   ',hexout(irword(i))
        write(*,*) 'Known correct answers are:  ',
     *       hexout(lans(i)),'   ',hexout(irans(i))
11    continue
      END

      FUNCTION hexout(num)
C     utility routine for printing out hexadecimal values
C     (many compilers can do this using the nonstandard "Z" format)
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
