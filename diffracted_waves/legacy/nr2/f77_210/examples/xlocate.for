      PROGRAM xlocate
C     driver for routine locate
      INTEGER N
      PARAMETER(N=100)
      INTEGER i,j
      REAL x,xx(N)
C     create array to be searched
      do 11 i=1,N
        xx(i)=exp(i/20.0)-74.0
11    continue
      write(*,*) 'Result of:   j=0 indicates x too small'
      write(*,*) '           j=100 indicates x too large'
      write(*,'(t5,a7,t17,a1,t24,a5,t34,a7)') 'locate ','j',
     *     'xx(j)','xx(j+1)'
C     perform test
      do 12 i=1,19
        x=-100.0+200.0*i/20.0
        call locate(xx,N,x,j)
        if (j.eq.0) then
          write(*,'(1x,f10.4,i6,a12,f12.6)') x,j,'lower lim',xx(j+1)
        else if (j.eq.N) then
          write(*,'(1x,f10.4,i6,f12.6,a12)') x,j,xx(j),'upper lim'
        else
          write(*,'(1x,f10.4,i6,2f12.6)') x,j,xx(j),xx(j+1)
        endif
12    continue
      END
