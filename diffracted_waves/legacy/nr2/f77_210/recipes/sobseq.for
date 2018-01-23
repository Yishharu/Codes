      SUBROUTINE sobseq(n,x)
      INTEGER n,MAXBIT,MAXDIM
      REAL x(*)
      PARAMETER (MAXBIT=30,MAXDIM=6)
      INTEGER i,im,in,ipp,j,k,l,ip(MAXDIM),iu(MAXDIM,MAXBIT),iv(MAXBIT*
     *MAXDIM),ix(MAXDIM),mdeg(MAXDIM)
      REAL fac
      SAVE ip,mdeg,ix,iv,in,fac
      EQUIVALENCE (iv,iu)
      DATA ip /0,1,1,2,1,4/, mdeg /1,2,3,3,4,4/, ix /6*0/
      DATA iv /6*1,3,1,3,3,1,1,5,7,7,3,3,5,15,11,5,15,13,9,156*0/
      if (n.lt.0) then
        do 11 k=1,MAXDIM
          ix(k)=0
11      continue
        in=0
        if(iv(1).ne.1)return
        fac=1./2.**MAXBIT
        do 15 k=1,MAXDIM
          do 12 j=1,mdeg(k)
            iu(k,j)=iu(k,j)*2**(MAXBIT-j)
12        continue
          do 14 j=mdeg(k)+1,MAXBIT
            ipp=ip(k)
            i=iu(k,j-mdeg(k))
            i=ieor(i,i/2**mdeg(k))
            do 13 l=mdeg(k)-1,1,-1
              if(iand(ipp,1).ne.0)i=ieor(i,iu(k,j-l))
              ipp=ipp/2
13          continue
            iu(k,j)=i
14        continue
15      continue
      else
        im=in
        do 16 j=1,MAXBIT
          if(iand(im,1).eq.0)goto 1
          im=im/2
16      continue
        pause 'MAXBIT too small in sobseq'
1       im=(j-1)*MAXDIM
        do 17 k=1,min(n,MAXDIM)
          ix(k)=ieor(ix(k),iv(im+k))
          x(k)=ix(k)*fac
17      continue
        in=in+1
      endif
      return
      END
