      PROGRAM xrealft
C     driver for routine realft
      INTEGER NP
      REAL EPS,PI,WIDTH
      PARAMETER(EPS=1.0e-3,NP=32,WIDTH=50.0,PI=3.14159)
      INTEGER i,j,n,nlim
      REAL big,per,scal,small,data(NP),size(NP)
      n=NP/2
1     write(*,'(1x,a,i2,a)') 'Period of sinusoid in channels (2-',
     *     NP,', OR 0 TO STOP)'
      read(*,*) per
      if (per.le.0.) stop
      do 11 i=1,NP
        data(i)=cos(2.0*PI*(i-1)/per)
11    continue
      call realft(data,NP,+1)
      size(1)=data(1)
      big=size(1)
      do 12 i=2,n
        size(i)=sqrt(data(2*i-1)**2+data(2*i)**2)
        if (size(i).gt.big) big=size(i)
12    continue
      scal=WIDTH/big
      do 13 i=1,n
        nlim=scal*size(i)+EPS
        write(*,'(1x,i4,1x,60a1)') i,('*',j=1,nlim+1)
13    continue
      write(*,*) 'press continue ...'
      read(*,*)
      call realft(data,NP,-1)
      big=-1.0e10
      small=1.0e10
      do 14 i=1,NP
        if (data(i).lt.small) small=data(i)
        if (data(i).gt.big) big=data(i)
14    continue
      scal=WIDTH/(big-small)
      do 15 i=1,NP
        nlim=scal*(data(i)-small)+EPS
        write(*,'(1x,i4,1x,60a1)') i,('*',j=1,nlim+1)
15    continue
      goto 1
      END
