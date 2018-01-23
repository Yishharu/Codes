      PROGRAM xrlft3
C     driver for routine rlft3
      INTEGER NX,NY,NZ
      REAL EPS
      PARAMETER(NX=16,NY=8,NZ=32,EPS=0.0008)
      INTEGER icompare,idum,i,j,k,ierr
      REAL data1(NX,NY,NZ),data2(NX,NY,NZ),fnorm,ran1
      COMPLEX speq1(NY,NZ)
      INTEGER nn1,nn2,nn3
      idum=-3
      nn1=NX
      nn2=NY
      nn3=NZ
      fnorm=float(nn1)*float(nn2)*float(nn3)/2.
      do 13 i=1,nn1
        do 12 j=1,nn2
          do 11 k=1,nn3
            data1(i,j,k)=2.*ran1(idum)-1.
            data2(i,j,k)=data1(i,j,k)*fnorm
11        continue
12      continue
13    continue
      call rlft3(data1,speq1,nn1,nn2,nn3,1)
C     here would be any processing in Fourier space
      call rlft3(data1,speq1,nn1,nn2,nn3,-1)
      ierr=icompare('data',data1,data2,nn1*nn2*nn3,EPS)
      if (ierr.eq.0) then
        write(*,*) 'Data compares OK to tolerance',EPS
      else
        write(*,*) 'Comparison errors occured at tolerance',EPS
        write(*,*) 'Total number of errors is',ierr
      endif
      END

      INTEGER FUNCTION icompare(string,arr1,arr2,len,eps)
      INTEGER IPRNT
      PARAMETER(IPRNT=20)
      CHARACTER*(*) string
      INTEGER j,len
      REAL eps,arr1(len),arr2(len)
      write(*,*) string
      icompare=0
      do 11 j=1,len
        if ((arr2(j).eq.0.and.abs(arr1(j)-arr2(j)).gt.eps).or.
     *       (abs((arr1(j)-arr2(j))/arr2(j)).gt.eps)) then
          icompare=icompare+1
          if (icompare.le.IPRNT) write(*,*) j,arr1(j),arr2(j)
        endif
11    continue
      return
      END
