      PROGRAM xfourfs
C     driver for routine fourfs
      INTEGER NX,NY,NZ,NDAT
      PARAMETER (NX=8,NY=32,NZ=4,NDAT=2*NX*NY*NZ)
      INTEGER idum,i,j,k,l,kbf,nnv,idim(3),iunit(4)
      REAL diff,ran1,smax,sum,sum1,sum2,tot,data1(NDAT),data2(NDAT)
      COMPLEX cdata1(NX,NY,NZ),cdata2(NX,NY,NZ),ctdat(NZ,NY,NX)
      EQUIVALENCE (data1,cdata1,ctdat),(data2,cdata2)
      kbf=128
      nnv=3
      idim(1)=NX
      idim(2)=NY
      idim(3)=NZ
      tot=float(NX)*float(NY)*float(NZ)
      open (unit=10,form='unformatted',status='scratch')
      open (unit=11,form='unformatted',status='scratch')
      open (unit=12,form='unformatted',status='scratch')
      open (unit=13,form='unformatted',status='scratch')
      do 11 i=1,4
        iunit(i)=i+9
11    continue
      idum=-23
      do 14 i=1,idim(3)
        do 13 j=1,idim(2)
          do 12 k=1,idim(1)
            l=k+(j-1)*idim(1)+(i-1)*idim(2)*idim(1)
            l=2*l-1
            data1(l)=2.*ran1(idum)-1.
            data2(l)=data1(l)
            l=l+1
            data1(l)=2.*ran1(idum)-1.
            data2(l)=data1(l)
12        continue
13      continue
14    continue
      do 15 j=1,NDAT/2,kbf
        write(iunit(1)) (data1(j+i),i=0,kbf-1)
        write(iunit(2)) (data1(NDAT/2+j+i),i=0,kbf-1)
15    continue
      write(*,*) '**************** now doing fourfs ********'
      call fourfs(iunit,idim,nnv,1)
      do 16 j=1,NDAT/2,kbf
        read(iunit(3)) (data1(j+i),i=0,kbf-1)
        read(iunit(4)) (data1(NDAT/2+j+i),i=0,kbf-1)
16    continue
      write(*,*) '**************** now doing fourn *********'
      call fourn(data2,idim,nnv,1)
      sum=0.
      smax=0.
      sum2=0.
      do 19 i=1,NZ
        do 18 j=1,NY
          do 17 k=1,NX
            diff=abs(cdata2(k,j,i)-ctdat(i,j,k))
            sum2=sum2+real(ctdat(i,j,k))**2+aimag(ctdat(i,j,k))**2
            sum=sum+diff
            if (diff.gt.smax) smax=diff
17        continue
18      continue
19    continue
      sum2=sqrt(sum2/tot)
      sum=sum/tot
      write(*,'(1x,a,3f12.7)')
     *  '(r.m.s.) value, (max,ave) discrepancy=',sum2,smax,sum
      do 21 i=1,4
        rewind(unit=iunit(i))
21    continue
C     now check the inverse transforms
      idim(1)=NZ
      idim(2)=NY
      idim(3)=NX
      idum=iunit(1)
      iunit(1)=iunit(3)
      iunit(3)=idum
      idum=iunit(2)
      iunit(2)=iunit(4)
      iunit(4)=idum
      write(*,*) '**************** now doing fourfs ********'
      call fourfs(iunit,idim,nnv,-1)
      do 22 j=1,NDAT/2,kbf
        read(iunit(3)) (data1(j+i),i=0,kbf-1)
        read(iunit(4)) (data1(NDAT/2+j+i),i=0,kbf-1)
22    continue
      idim(1)=NX
      idim(2)=NY
      idim(3)=NZ
      write(*,*) '**************** now doing fourn *********'
      call fourn(data2,idim,nnv,-1)
      sum=0.
      smax=0.
      sum1=0.
      do 25 i=1,NZ
        do 24 j=1,NY
          do 23 k=1,NX
            sum1=sum1+real(cdata2(k,j,i))**2+aimag(cdata2(k,j,i))**2
            diff=abs(cdata2(k,j,i)-cdata1(k,j,i))
            sum=sum+diff
            if (diff.gt.smax) smax=diff
23        continue
24      continue
25    continue
      sum=sum/tot
      sum1=sqrt(sum1/tot)
      write(*,'(1x,a,3f12.7)')
     *  '(r.m.s.) value, (max,ave) discrepancy=',sum1,smax,sum
      write(*,*) 'ratio of r.m.s. values, expected ratio=',
     *  sum1/sum2,sqrt(tot)
      END
