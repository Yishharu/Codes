      PROGRAM xarcode
C     driver for routines arcmak, arcode
      INTEGER MC,MD,MQ,NWK,MAXBUF,MAXLINE
      PARAMETER (MC=512,MD=MC-1,MQ=2*MC-1,NWK=20,MAXBUF=200,MAXLINE=80)
      INTEGER nch,ncum,nrad,minint,jdif,nc,ilob,iupb,ncumfq
      INTEGER i,j,k,lc,n,nt,nfreq(256)
      COMMON /arccom/ ncumfq(MC+2),iupb(NWK),ilob(NWK),nch,nrad,
     *     minint,jdif,nc,ncum
      SAVE /arccom/
      CHARACTER*1 code(MAXBUF)
      CHARACTER*80 lin
      CHARACTER*200 mess,ness
      open(unit=7,file='TEXT.DAT',status='old')
      do 11 j=1,256
        nfreq(j)=0
11    continue
1     continue
      do 12 j=1,MAXLINE
        lin(j:j)=char(32)
12    continue
      read(7,'(a)',END=3) lin
      do 13 n=MAXLINE,1,-1
        if (lin(n:n).ne.char(32)) goto 2
13    continue
2     do 14 k=1,min(MAXLINE,n)
        j=ichar(lin(k:k))-31
        if (j.ge.1) nfreq(j)=nfreq(j)+1
14    continue
      goto 1
3     close(unit=7)
      nch=96
      nrad=256
C     here is the initialization that constructs the code
      call arcmak(nfreq,nch,nrad)
C     now ready to prompt for lines to encode
4     write(*,*) 'ENTER A LINE:'
      do 15 j=1,MAXLINE
        mess(j:j)=char(32)
15    continue
      read(*,'(a)',END=999) mess
      do 16 n=MAXLINE,1,-1
        if (mess(n:n).ne.char(32)) goto 5
16    continue
C     shift from 256 character alphabet to 96 printing characters
5     do 17 j=1,n
        mess(j:j)=char(ichar(mess(j:j))-32)
17    continue
C     message initialization
      lc=1
      call arcode(0,code,MAXBUF,lc,0)
C     here we arithmetically encode mess(1:n)
      do 18 j=1,n
        call arcode(ichar(mess(j:j)),code,MAXBUF,lc,1)
18    continue
      call arcode(nch,code,MAXBUF,lc,1)
C     message termination
      write(*,*) 'LENGTH OF LINE INPUT, CODED=',n,lc-1
C     here we decode the message, hopefully to get the original back
      lc=1
      call arcode(0,code,MAXBUF,lc,0)
      do 19 j=1,MAXBUF
        call arcode(i,code,MAXBUF,lc,-1)
        if (i.eq.nch) goto 6
        ness(j:j)=char(i)
19    continue
      pause 'ARCODE - NEVER GET HERE'
6     nt=j-1
      write(*,*) 'DECODED OUTPUT:'
      write(*,'(1x,80a1)') (char(ichar(ness(j:j))+32),j=1,nt)
      if (nt.ne.n) write(*,*) 'ERROR ! J DECODED .NE. N INPUT',j,n
      goto 4
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
