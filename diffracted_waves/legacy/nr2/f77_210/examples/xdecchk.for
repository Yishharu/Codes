      PROGRAM xdecchk
C     driver for routine decchk
      INTEGER j,k,l,n,nbad,ntot
      LOGICAL decchk,iok,jok
      CHARACTER lin*128,ch*1,chh*1,tf*1
C     test all jump transpositions of the form 86jlk41
      ntot=0
      nbad=0
      do 13 j=48,57
        do 12 k=48,57
          do 11 l=48,57
            if (j.ne.k) then
              ntot=ntot+1
              lin(1:7)='86'//char(j)//char(l)//char(k)//'41'
              iok=decchk(lin(1:7),7,ch)
              iok=decchk(lin(1:7)//ch,8,chh)
              lin(1:7)='86'//char(k)//char(l)//char(j)//'41'
              jok=decchk(lin(1:7)//ch,8,chh)
              if ((.not.iok).or.jok) then
                nbad=nbad+1
              endif
            endif
11        continue
12      continue
13    continue
      write(*,'(1x,a,t30,i3)') 'Total tries:',ntot
      write(*,'(1x,a,t30,i3)') 'Bad tries:',nbad
      write(*,'(1x,a,t30,f3.2)') 'Fraction good:',
     *  float(ntot-nbad)/float(ntot)
C     construct check digits for some user-supplied strings
1     write(*,*) 'enter string terminated by x:'
      read(*,'(a20)',END=999) lin
      do 14 j=1,128
        if (lin(j:j).eq.'x') goto 2
14    continue
2     n=j-1
      if (n.eq.0) goto 999
      iok=decchk(lin(1:n),n,ch)
      jok=decchk(lin(1:n)//ch,n+1,chh)
      if (jok) then
        tf='T'
      else
        tf='F'
      endif
      write(*,*) lin(1:n)//ch,' checks as ',tf
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
