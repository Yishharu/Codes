      PROGRAM xpolin2
C     driver for routine polin2
      INTEGER N
      REAL PI
      PARAMETER(N=5,PI=3.141593)
      INTEGER i,j
      REAL dy,f,x1,x2,y,x1a(N),x2a(N),ya(N,N)
      do 12 i=1,N
        x1a(i)=i*PI/N
        do 11 j=1,N
          x2a(j)=1.0*j/N
          ya(i,j)=sin(x1a(i))*exp(x2a(j))
11      continue
12    continue
C     test 2-dimensional interpolation
      write(*,'(t9,a,t21,a,t32,a,t40,a,t58,a)')
     *     'x1','x2','f(x)','interpolated','error'
      do 14 i=1,4
        x1=(-0.1+i/5.0)*PI
        do 13 j=1,4
          x2=-0.1+j/5.0
          f=sin(x1)*exp(x2)
          call polin2(x1a,x2a,ya,N,N,x1,x2,y,dy)
          write(*,'(1x,4f12.6,f14.6)') x1,x2,f,y,dy
13      continue
        write(*,*) '***********************************'
14    continue
      END
