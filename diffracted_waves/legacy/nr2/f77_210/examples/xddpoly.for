      PROGRAM xddpoly
C     driver for routine ddpoly
      INTEGER NC,NCM1,NP
      PARAMETER(NC=6,NCM1=5,NP=20)
      INTEGER i,j
      REAL x,factrl,c(NC),pd(NCM1),d(NCM1,NP)
      CHARACTER a(NCM1)*15
      DATA a/'polynomial:','first deriv:','second deriv:',
     *     'third deriv:','fourth deriv:'/
      DATA c/-1.0,5.0,-10.0,10.0,-5.0,1.0/
      do 12 i=1,NP
        x=0.1*i
        call ddpoly(c,NC,x,pd,NC-1)
        do 11 j=1,NC-1
          d(j,i)=pd(j)
11      continue
12    continue
      do 14 i=1,NC-1
        write(*,'(1x,t7,a)') a(i)
        write(*,'(1x,t13,a,t25,a,t40,a)') 'X','DDPOLY','actual'
        do 13 j=1,NP
          x=0.1*j
          write(*,'(1x,3f15.6)') x,d(i,j),
     *         factrl(NC-1)/factrl(NC-i)*((x-1.0)**(NC-i))
13      continue
        write(*,*) 'press ENTER to continue...'
        read(*,*)
14    continue
      END
