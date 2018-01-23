      PROGRAM xfourn
C     driver for routine fourn
      INTEGER NDAT,NDIM
      PARAMETER(NDIM=3,NDAT=1024)
      INTEGER i,idum,isign,j,k,l,nn(NDIM)
      REAL data1(NDAT),data2(NDAT),ran1
      idum=-23
      do 11 i=1,NDIM
        nn(i)=2*(2**i)
11    continue
      do 14 i=1,nn(3)
        do 13 j=1,nn(2)
          do 12 k=1,nn(1)
            l=k+(j-1)*nn(1)+(i-1)*nn(2)*nn(1)
            l=2*l-1
C     real part of component
            data1(l)=2.*ran1(idum)-1.
            data2(l)=data1(l)
C     imaginary part of component
            l=l+1
            data1(l)=2.*ran1(idum)-1.
            data2(l)=data1(l)
12        continue
13      continue
14    continue
      isign=+1
      call fourn(data2,nn,NDIM,isign)
C     here would be any processing to be done in Fourier space
      isign=-1
      call fourn(data2,nn,NDIM,isign)
      write(*,'(1x,a)') 'Double 3-dimensional Transform'
      write(*,'(/1x,t10,a,t35,a,t63,a)') 'Double Transf.',
     *     'Original Data','Ratio'
      write(*,'(1x,t8,a,t20,a,t33,a,t45,a,t57,a,t69,a/)')
     *     'Real','Imag.','Real','Imag.','Real','Imag.'
      do 15 i=1,4
        j=2*i
        k=2*j
        l=k+(j-1)*nn(1)+(i-1)*nn(2)*nn(1)
        l=2*l-1
        write(*,'(1x,6f12.2)') data2(l),data2(l+1),data1(l),
     *       data1(l+1),data2(l)/data1(l),data2(l+1)/data1(l+1)
15    continue
      write(*,'(/1x,a,i4)') 'The product of transform lengths is:',
     *     nn(1)*nn(2)*nn(3)
      END
