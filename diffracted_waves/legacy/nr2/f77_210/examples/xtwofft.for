      PROGRAM xtwofft
C     driver for routine twofft
      INTEGER N,N2
      REAL PER,PI
      PARAMETER(N=32,N2=2*N,PER=8.0,PI=3.14159)
      INTEGER i,isign
      REAL data1(N),data2(N),fft1(N2),fft2(N2),x
      do 11 i=1,N
        x=2.0*PI*i/PER
        data1(i)=nint(cos(x))
        data2(i)=nint(sin(x))
11    continue
      call twofft(data1,data2,fft1,fft2,N)
      write(*,*) 'Fourier transform of first function:'
      call prntft(fft1,N2)
      write(*,*) 'Fourier transform of second function:'
      call prntft(fft2,N2)
C     invert transform
      isign=-1
      call four1(fft1,N,isign)
      write(*,*) 'Inverted transform = first function:'
      call prntft(fft1,N2)
      call four1(fft2,N,isign)
      write(*,*) 'Inverted transform = second function:'
      call prntft(fft2,N2)
      END

      SUBROUTINE prntft(data,n2)
      INTEGER i,n2,nn2,m
      REAL data(n2)
      write(*,'(1x,t7,a,t13,a,t24,a,t35,a,t47,a)')
     *     'n','Real(n)','Imag.(n)','Real(N-n)','Imag.(N-n)'
      write(*,'(1x,i6,4f12.6)') 0,data(1),data(2),data(1),data(2)
      do 11 i=3,(n2/2)+1,2
        m=(i-1)/2
        nn2=n2+2-i
        write(*,'(1x,i6,4f12.6)') m,data(i),data(i+1),
     *       data(nn2),data(nn2+1)
11    continue
      write(*,'(/1x,a)') ' press RETURN to continue ...'
      read(*,*)
      return
      END
