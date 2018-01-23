(* BEGINENVIRON
CONST
   ncityp =
TYPE
   RealArrayNCITY = ARRAY [1..ncityp] OF real;
   IntegerArrayNCITY = ARRAY [1..ncityp] OF integer;
VAR
   MetropJdum: integer;
BEGIN
   MetropJdum := -1.0;
ENDENVIRON *)
PROCEDURE anneal(VAR x,y : RealArrayNCITY;
               VAR iorder: IntegerArrayNCITY;
                    ncity: integer);
LABEL 99;
CONST
   tfactr = 0.9;
TYPE
   IntegerArray6 = ARRAY [1..6] OF integer;
VAR
   ans : boolean;
   path,de,t : real;
   nover,nlimit,i1,i2,idum,iseed: integer;
   i,j,k,nsucc,nn,idec : integer;
   n : IntegerArray6;

FUNCTION alen(x1,x2,y1,y2: real): real;
BEGIN
   alen := sqrt(sqr(x2-x1)+sqr(y2-y1))
END;

PROCEDURE revcst(VAR x,y: RealArrayNCITY;
              VAR iorder: IntegerArrayNCITY;
                   ncity: integer;
                   VAR n: IntegerArray6;
                  VAR de: real);
VAR
   xx,yy : ARRAY [1..6] OF real;
   j,ii : integer;
BEGIN
   n[3] := 1 + ((n[1]+ncity-2) MOD ncity);
   n[4] := 1 + (n[2] MOD ncity);
   FOR j := 1 to 4 DO BEGIN
      ii := iorder[n[j]];
      xx[j] := x[ii];
      yy[j] := y[ii]
   END;
   de := -alen(xx[1],xx[3],yy[1],yy[3])-alen(xx[2],xx[4],yy[2],yy[4])
      +alen(xx[1],xx[4],yy[1],yy[4])+alen(xx[2],xx[3],yy[2],yy[3])
END;

PROCEDURE reverse(VAR iorder: IntegerArrayNCITY;
                       ncity: integer;
                       VAR n: IntegerArray6);
VAR
   nn,j,k,l,itmp : integer;
BEGIN
   nn := (1+((n[2]-n[1]+ncity) MOD ncity)) DIV 2;
   FOR j := 1 to nn DO BEGIN
      k := 1 + ((n[1]+j-2) MOD ncity);
      l := 1 + ((n[2]-j+ncity) MOD ncity);
      itmp := iorder[k];
      iorder[k] := iorder[l];
      iorder[l] := itmp
   END
END;

PROCEDURE trncst(VAR x,y: RealArrayNCITY;
              VAR iorder: IntegerArrayNCITY;
                   ncity: integer;
                   VAR n: IntegerArray6;
                  VAR de: real);
VAR
   xx,yy : ARRAY [1..6] OF real;
   j,ii : integer;
BEGIN
   n[4] := 1 + (n[3] MOD ncity);
   n[5] := 1 + ((n[1]+ncity-2) MOD ncity);
   n[6] := 1 + (n[2] MOD ncity);
   FOR j := 1 to 6 DO BEGIN
      ii := iorder[n[j]];
      xx[j] := x[ii];
      yy[j] := y[ii]
   END;
   de := -alen(xx[2],xx[6],yy[2],yy[6])-alen(xx[1],xx[5],yy[1],yy[5])
      -alen(xx[3],xx[4],yy[3],yy[4])+alen(xx[1],xx[3],yy[1],yy[3])
      +alen(xx[2],xx[4],yy[2],yy[4])+alen(xx[5],xx[6],yy[5],yy[6])
END;

PROCEDURE trnspt(VAR iorder: IntegerArrayNCITY;
                      ncity: integer;
                      VAR n: IntegerArray6);
VAR
   jorder : ^IntegerArrayNCITY;
   m1,m2,m3,nn,j,jj : integer;
BEGIN
   new(jorder);
   m1 := 1 + ((n[2]-n[1]+ncity) MOD ncity);
   m2 := 1 + ((n[5]-n[4]+ncity) MOD ncity);
   m3 := 1 + ((n[3]-n[6]+ncity) MOD ncity);
   nn := 1;
   FOR j := 1 to m1 DO BEGIN
      jj := 1 + ((j+n[1]-2) MOD ncity);
      jorder^[nn] := iorder[jj];
      nn := nn+1
   END;
   IF m2 > 0 THEN BEGIN
      FOR j := 1 to m2 DO BEGIN
         jj := 1+((j+n[4]-2) MOD ncity);
         jorder^[nn] := iorder[jj];
         nn := nn+1
      END
   END;
   IF m3 > 0 THEN BEGIN
      FOR j := 1 to m3 DO BEGIN
         jj := 1 + ((j+n[6]-2) MOD ncity);
         jorder^[nn] := iorder[jj];
         nn := nn+1
      END
   END;
   FOR j := 1 to ncity DO
      iorder[j] := jorder^[j];
   dispose(jorder)
END;

PROCEDURE metrop(de,t: real;
              VAR ans: boolean);
BEGIN
   ans := (de < 0.0) OR (ran3(MetropJdum) < exp(-de/t))
END;

BEGIN
   nover := 100*ncity;
   nlimit := 10*ncity;
   path := 0.0;
   t := 0.5;
   FOR i := 1 to ncity-1 DO BEGIN
      i1 := iorder[i];
      i2 := iorder[i+1];
      path := path+alen(x[i1],x[i2],y[i1],y[i2])
   END;
   i1 := iorder[ncity];
   i2 := iorder[1];
   path := path+alen(x[i1],x[i2],y[i1],y[i2]);
   idum := -1;
   iseed := 111;
   FOR j := 1 to 100 DO BEGIN
      nsucc := 0;
      k := 0;
      REPEAT
         k := k+1;
         REPEAT
            n[1] := 1+trunc(ncity*ran3(idum));
            n[2] := 1+trunc((ncity-1)*ran3(idum));
            IF n[2] >= n[1] THEN n[2] := n[2]+1;
            nn := 1+((n[1]-n[2]+ncity-1) MOD ncity);
         UNTIL nn >= 3;
         idec := irbit1(iseed);
         IF idec = 0 THEN BEGIN
            n[3] := n[2]+trunc(abs(nn-2)*ran3(idum))+1;
            n[3] := 1+((n[3]-1) MOD ncity);
            trncst(x,y,iorder,ncity,n,de);
            metrop(de,t,ans);
            IF ans THEN BEGIN
               nsucc := nsucc+1;
               path := path+de;
               trnspt(iorder,ncity,n)
            END
         END
         ELSE BEGIN
            revcst(x,y,iorder,ncity,n,de);
            metrop(de,t,ans);
            IF ans THEN BEGIN
               nsucc := nsucc+1;
               path := path+de;
               reverse(iorder,ncity,n)
            END
         END;
      UNTIL (nsucc >= nlimit) OR (k >= nover);
      writeln;
      writeln('T =',t:10:6,' Path Length =',path:12:6);
      writeln('Successful Moves: ',nsucc:6);
      t := t*tfactr;
      IF nsucc = 0 THEN GOTO 99
   END;
99:
END;
