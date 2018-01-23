      PROGRAM xfour1
C     driver for routine four1
      INTEGER NN,NN2
      PARAMETER (NN=32,NN2=2*NN)
      REAL data(NN2),dcmp(NN2)
      INTEGER i,isign,j
      write(*,*) 'h(t)=real-valued even-function'
      write(*,*) 'H(n)=H(N-n) and real?'
      do 11 i=1,2*NN-1,2
        data(i)=1.0/(((i-NN-1.0)/NN)**2+1.0)
        data(i+1)=0.0
11    continue
      isign=1
      call four1(data,NN,isign)
      call prntft(data,NN2)
      write(*,*) 'h(t)=imaginary-valued even-function'
      write(*,*) 'H(n)=H(N-n) and imaginary?'
      do 12 i=1,2*NN-1,2
        data(i+1)=1.0/(((i-NN-1.0)/NN)**2+1.0)
        data(i)=0.0
12    continue
      isign=1
      call four1(data,NN,isign)
      call prntft(data,NN2)
      write(*,*) 'h(t)=real-valued odd-function'
      write(*,*) 'H(n)=-H(N-n) and imaginary?'
      do 13 i=1,2*NN-1,2
        data(i)=(i-NN-1.0)/NN/(((i-NN-1.0)/NN)**2+1.0)
        data(i+1)=0.0
13    continue
      data(1)=0.0
      isign=1
      call four1(data,NN,isign)
      call prntft(data,NN2)
      write(*,*) 'h(t)=imaginary-valued odd-function'
      write(*,*) 'H(n)=-H(N-n) and real?'
      do 14 i=1,2*NN-1,2
        data(i+1)=(i-NN-1.0)/NN/(((i-NN-1.0)/NN)**2+1.0)
        data(i)=0.0
14    continue
      data(2)=0.0
      isign=1
      call four1(data,NN,isign)
      call prntft(data,NN2)
C     transform, inverse-transform test
      do 15 i=1,2*NN-1,2
        data(i)=1.0/((0.5*(i-NN-1)/NN)**2+1.0)
        dcmp(i)=data(i)
        data(i+1)=(0.25*(i-NN-1)/NN)*
     *       exp(-(0.5*(i-NN-1.0)/NN)**2)
        dcmp(i+1)=data(i+1)
15    continue
      isign=1
      call four1(data,NN,isign)
      isign=-1
      call four1(data,NN,isign)
      write(*,'(/1x,t10,a,t44,a)') 'Original Data:',
     *     'Double Fourier Transform:'
      write(*,'(/1x,t5,a,t11,a,t24,a,t41,a,t53,a/)')
     *     'k','Real h(k)','Imag h(k)','Real h(k)','Imag h(k)'
      do 16 i=1,NN,2
        j=(i+1)/2
        write(*,'(1x,i4,2x,2f12.6,5x,2f12.6)') j,dcmp(i),
     *       dcmp(i+1),data(i)/NN,data(i+1)/NN
16    continue
      END

      SUBROUTINE prntft(data,nn2)
      INTEGER n,nn2,m,mm
      REAL data(nn2)
      write(*,'(/1x,t5,a,t11,a,t23,a,t39,a,t52,a)')
     *     'n','Real H(n)','Imag H(n)','Real H(N-n)','Imag H(N-n)'
      write(*,'(1x,i4,2x,2f12.6,5x,2f12.6)') 0,data(1),data(2),
     *     data(1),data(2)
      do 11 n=3,(nn2/2)+1,2
        m=(n-1)/2
        mm=nn2+2-n
        write(*,'(1x,i4,2x,2f12.6,5x,2f12.6)') m,data(n),
     *       data(n+1),data(mm),data(mm+1)
11    continue
      write(*,'(/1x,a)') ' press RETURN to continue ...'
      read(*,*)
      return
      END
