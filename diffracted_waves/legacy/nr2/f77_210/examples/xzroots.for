      PROGRAM xzroots
C     driver for routine zroots
      INTEGER M,M1
      PARAMETER(M=4,M1=M+1)
      INTEGER i
      COMPLEX a(M1),roots(M)
      LOGICAL polish
      DATA a/(0.0,2.0),(0.0,0.0),(-1.0,-2.0),(0.0,0.0),(1.0,0.0)/
      write(*,'(/1x,a)') 'Roots of the polynomial x^4-(1+2i)*x^2+2i'
      polish=.false.
      call zroots(a,M,roots,polish)
      write(*,'(/1x,a)') 'Unpolished roots:'
      write(*,'(1x,t10,a,t25,a,t37,a)') 'Root #','Real','Imag.'
      do 11 i=1,M
        write(*,'(1x,i11,5x,2f12.6)') i,roots(i)
11    continue
      write(*,'(/1x,a)') 'Corrupted roots:'
      do 12 i=1,M
        roots(i)=roots(i)*(1.0+0.01*i)
12    continue
      write(*,'(1x,t10,a,t25,a,t37,a)') 'Root #','Real','Imag.'
      do 13 i=1,M
        write(*,'(1x,i11,5x,2f12.6)') i,roots(i)
13    continue
      polish=.true.
      call zroots(a,M,roots,polish)
      write(*,'(/1x,a)') 'Polished roots:'
      write(*,'(1x,t10,a,t25,a,t37,a)') 'Root #','Real','Imag.'
      do 14 i=1,M
        write(*,'(1x,i11,5x,2f12.6)') i,roots(i)
14    continue
      END
