      PROGRAM xjacobi
C     driver for routine jacobi
      INTEGER NP,NMAT
      PARAMETER(NP=10,NMAT=3)
      INTEGER i,ii,j,jj,k,kk,l,ll,nrot,num(3)
      REAL ratio,d(NP),v(NP,NP),r(NP)
      REAL a(3,3),b(5,5),c(10,10),e(NP,NP)
      DATA num/3,5,10/
      DATA a/1.0,2.0,3.0,2.0,2.0,3.0,3.0,3.0,3.0/
      DATA b/-2.0,-1.0,0.0,1.0,2.0,-1.0,-1.0,0.0,1.0,2.0,
     *     0.0,0.0,0.0,1.0,2.0,1.0,1.0,1.0,1.0,2.0,
     *     2.0,2.0,2.0,2.0,2.0/
      DATA c/5.0,4.3,3.0,2.0,1.0,0.0,-1.0,-2.0,-3.0,-4.0,
     *     4.3,5.1,4.0,3.0,2.0,1.0,0.0,-1.0,-2.0,-3.0,
     *     3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,-1.0,-2.0,
     *     2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,-1.0,
     *     1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,
     *     0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,
     *     -1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,
     *     -2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,
     *     -3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,
     *     -4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0/
      do 24 i=1,NMAT
        if (i.eq.1) then
          do 12 ii=1,3
            do 11 jj=1,3
              e(ii,jj)=a(ii,jj)
11          continue
12        continue
          call jacobi(e,3,NP,d,v,nrot)
        else if (i.eq.2) then
          do 14 ii=1,5
            do 13 jj=1,5
              e(ii,jj)=b(ii,jj)
13          continue
14        continue
          call jacobi(e,5,NP,d,v,nrot)
        else if (i.eq.3) then
          do 16 ii=1,10
            do 15 jj=1,10
              e(ii,jj)=c(ii,jj)
15          continue
16        continue
          call jacobi(e,10,NP,d,v,nrot)
        endif
        write(*,'(/1x,a,i2)') 'Matrix Number ',i
        write(*,'(1x,a,i3)') 'Number of JACOBI rotations: ',nrot
        write(*,'(/1x,a)') 'Eigenvalues:'
        do 17 j=1,num(i)
          write(*,'(1x,5f12.6)') d(j)
17      continue
        write(*,'(/1x,a)') 'Eigenvectors:'
        do 18 j=1,num(i)
          write(*,'(1x,t5,a,i3)') 'Number',j
          write(*,'(1x,5f12.6)') (v(k,j),k=1,num(i))
18      continue
C     eigenvector test
        write(*,'(/1x,a)') 'Eigenvector Test'
        do 23 j=1,num(i)
          do 21 l=1,num(i)
            r(l)=0.0
            do 19 k=1,num(i)
              if (k.gt.l) then
                kk=l
                ll=k
              else
                kk=k
                ll=l
              endif
              if (i.eq.1) then
                r(l)=r(l)+a(ll,kk)*v(k,j)
              else if (i.eq.2) then
                r(l)=r(l)+b(ll,kk)*v(k,j)
              else if (i.eq.3) then
                r(l)=r(l)+c(ll,kk)*v(k,j)
              endif
19          continue
21        continue
          write(*,'(/1x,a,i3)') 'Vector Number',j
          write(*,'(/1x,t7,a,t18,a,t31,a)')
     *         'Vector','Mtrx*Vec.','Ratio'
          do 22 l=1,num(i)
            ratio=r(l)/v(l,j)
            write(*,'(1x,3f12.6)') v(l,j),r(l),ratio
22        continue
23      continue
        write(*,*) 'press RETURN to continue...'
        read(*,*)
24    continue
      END
