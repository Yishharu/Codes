      PROGRAM xran
C     driver for routines ran0, ran1, ran2, ran3
      REAL ran0,ran1,ran2,ran3
      EXTERNAL ran0,ran1,ran2,ran3
      write(*,*)
      write(*,*) 'Testing ran0:'
      call integ(ran0)
      write(*,*)
      write(*,*) 'Testing ran1:'
      call integ(ran1)
      write(*,*)
      write(*,*) 'Testing ran2:'
      call integ(ran2)
      write(*,*)
      write(*,*) 'Testing ran3:'
      call integ(ran3)
      END

      SUBROUTINE integ(func)
C     calculates pi statistically using volume of unit n-sphere
      REAL PI
      PARAMETER(PI=3.1415926)
      INTEGER i,idum,j,k,iy(3)
      REAL fnc,func,x1,x2,x3,x4,yprob(3)
      EXTERNAL func
      fnc(x1,x2,x3,x4)=sqrt(x1**2+x2**2+x3**2+x4**2)
      idum=-1
      do 11 i=1,3
        iy(i)=0
11    continue
      write(*,'(1x,t15,a)') 'Volume of unit n-sphere, n = 2, 3, 4'
      write(*,'(1x,/,t3,a,t17,a,t26,a,t37,a)')
     *     '# points','PI','(4/3)*PI','(1/2)*PI^2'
      do 14 j=1,15
        do 12 k=2**(j-1),0,-1
          x1=func(idum)
          x2=func(idum)
          x3=func(idum)
          x4=func(idum)
          if (fnc(x1,x2,0.0,0.0).lt.1.0) iy(1)=iy(1)+1
          if (fnc(x1,x2,x3,0.0).lt.1.0) iy(2)=iy(2)+1
          if (fnc(x1,x2,x3,x4).lt.1.0) iy(3)=iy(3)+1
12      continue
        do 13 i=1,3
          yprob(i)=1.0*(2**(i+1))*iy(i)/(2**j)
13      continue
        write(*,'(1x,i8,3f12.6)') 2**j,(yprob(i),i=1,3)
14    continue
      write(*,'(1x,/,t4,a,3f12.6,/)') 'actual',PI,4.0*PI/3.0,0.5*(PI**2)
      return
      END
