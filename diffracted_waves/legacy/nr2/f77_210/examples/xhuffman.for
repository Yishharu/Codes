      PROGRAM xhuffman
C     driver for routines hufmak, hufenc, hufdec
      INTEGER MC,MQ,MAXBUF,MAXLINE
      PARAMETER (MC=512,MQ=2*MC-1,MAXBUF=200,MAXLINE=80)
      INTEGER icod,ncod,nprob,left,iright,nch,nodemax
      COMMON /hufcom/ icod(MQ),ncod(MQ),nprob(MQ),left(MQ),
     *     iright(MQ),nch,nodemax
      SAVE /hufcom/
      INTEGER i,ilong,j,k,n,nb,nh,nlong,nt,nfreq(256)
      CHARACTER*200 mess,code,ness
      CHARACTER*80 lin
C     construct a letter frequency table from the file TEXT.DAT
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
C     here is the initialization that constructs the code
      call hufmak(nfreq,nch,ilong,nlong)
      write(*,*)
     *     'index, ','character, ','nfreq, ','bits in code, ','code int'
      do 15 j=1,nch
        if (nfreq(j).ne.0.)
     *       write(*,*) j,' ',char(j+31),' ',nfreq(j),ncod(j),icod(j)
15    continue
C     now ready to prompt for lines to encode
4     write(*,*) 'ENTER A LINE:'
      do 16 j=1,MAXLINE
        mess(j:j)=char(32)
16    continue
      read(*,'(a)',END=999) mess
      do 17 n=MAXLINE,1,-1
        if (mess(n:n).ne.char(32)) goto 5
17    continue
C     shift from 256 character alphabet to 96 printing characters
5     do 18 j=1,n
        mess(j:j)=char(ichar(mess(j:j))-32)
18    continue
C     here we Huffman encode mess(1:n)
      nb=0
      do 19 j=1,n
        call hufenc(ichar(mess(j:j)),code,MAXLINE,nb)
19    continue
      nh=nb/8+1
C     message termination (encode a single long character)
      call hufenc(ilong,code,MAXLINE,nb)
C     here we decode the message, hopefully to get the original back
      nb=0
      do 21 j=1,MAXLINE
        call hufdec(i,code,nh,nb)
        if (i.eq.nch) goto 6
        ness(j:j)=char(i)
21    continue
      pause 'HUFFMAN - NEVER GET HERE'
6     nt=j-1
      write(*,*) 'LENGTH OF LINE INPUT,CODED=',n,nh
      write(*,*) 'DECODED OUTPUT:'
      write(*,'(1x,80a1)') (char(ichar(ness(j:j))+32),j=1,nt)
      if (nt.ne.n) write(*,*) 'ERROR ! N DECODED .NE. N INPUT'
      if (nt-n.eq.1) write(*,*) 'MAY BE HARMLESS SPURIOUS CHARACTER.'
      goto 4
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
