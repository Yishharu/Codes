      PROGRAM xexpdev
C     driver for routine expdev
      INTEGER NPTS
      REAL EE
      PARAMETER(NPTS=10000,EE=2.718281828)
      INTEGER i,idum,j
      REAL expdev,expect,total,y,trig(21),x(21)
      do 11 i=1,21
        trig(i)=(i-1)/20.0
        x(i)=0.0
11    continue
      idum=-1
      do 13 i=1,NPTS
        y=expdev(idum)
        do 12 j=2,21
          if ((y.lt.trig(j)).and.(y.gt.trig(j-1))) then
            x(j)=x(j)+1.0
          endif
12      continue
13    continue
      total=0.0
      do 14 i=2,21
        total=total+x(i)
14    continue
      write(*,'(1x,a,i6,a)') 'Exponential distribution with',
     *     NPTS,' points:'
      write(*,'(1x,t5,a,t19,a,t31,a)')
     *     'interval','observed','expected'
      do 15 i=2,21
        x(i)=x(i)/total
        expect=exp(-(trig(i-1)+trig(i))/2.0)
        expect=expect*0.05*EE/(EE-1)
        write(*,'(1x,2f6.2,2f12.4)')
     *       trig(i-1),trig(i),x(i),expect
15    continue
      END
