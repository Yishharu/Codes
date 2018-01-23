(* BEGINENVIRON
CONST
   n =
   m =
   np =
   mp =
TYPE
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
   IntegerArrayN = ARRAY [1..n] OF integer;
   IntegerArrayM = ARRAY [1..m] OF integer;
   IntegerArrayNP = ARRAY [1..np] OF integer;
ENDENVIRON *)
PROCEDURE simplx(VAR a: RealArrayMPbyNP;
          m,n,m1,m2,m3: integer;
             VAR icase: integer;
             VAR izrov: IntegerArrayN;
             VAR iposv: IntegerArrayM);
LABEL 1,2,3,4,5,99;
CONST
   eps = 1.0e-6;
VAR
   nl2,nl1,m12,kp,kh,k,is,ir,ip,i: integer;
   q1,bmax: real;
   l1: ^IntegerArrayNP;
   l2,l3: ^IntegerArrayM;

PROCEDURE simp1(VAR a: RealArrayMPbyNP;
                   mm: integer;
               VAR ll: IntegerArrayNP;
             nll,iabf: integer;
               VAR kp: integer;
             VAR bmax: real);
VAR
   k: integer;
   test: real;
BEGIN
   kp := ll[1];
   bmax := a[mm+1,kp+1];
   FOR k := 2 TO nll DO BEGIN
      IF iabf = 0 THEN
         test := a[mm+1,ll[k]+1]-bmax
      ELSE
         test := abs(a[mm+1,ll[k]+1])-abs(bmax);
      IF test > 0.0 THEN BEGIN
         bmax := a[mm+1,ll[k]+1];
         kp := ll[k]
      END
   END
END;

PROCEDURE simp2(VAR a: RealArrayMPbyNP;
                  m,n: integer;
               VAR l2: IntegerArrayM;
                  nl2: integer;
               VAR ip: integer;
                   kp: integer;
               VAR q1: real);
LABEL 1,2,99;
CONST
   eps = 1.0e-6;
VAR
   k,ii,i: integer;
   qp,q0,q: real;
BEGIN
   ip := 0;
   FOR i := 1 TO nl2 DO
      IF a[l2[i]+1,kp+1] < -eps THEN GOTO 1;
   GOTO 99;
1: q1 := -a[l2[i]+1,1]/a[l2[i]+1,kp+1];
   ip := l2[i];
   FOR i := i+1 TO nl2 DO BEGIN
      ii := l2[i];
      IF a[ii+1,kp+1] < -eps THEN BEGIN
         q := -a[ii+1,1]/a[ii+1,kp+1];
         IF q < q1 THEN BEGIN
            ip := ii;
            q1 := q
         END
         ELSE IF q = q1 THEN BEGIN
            FOR k := 1 TO n DO BEGIN
               qp := -a[ip+1,k+1]/a[ip+1,kp+1];
               q0 := -a[ii+1,k+1]/a[ii+1,kp+1];
               IF q0 <> qp THEN GOTO 2
            END;
2:          IF q0 < qp THEN ip := ii
         END
      END
   END;
99:
END;

PROCEDURE simp3(VAR a: RealArrayMPbyNP;
          i1,k1,ip,kp: integer);
VAR
   kk,ii: integer;
   piv: real;
BEGIN
   piv := 1.0/a[ip+1,kp+1];
   FOR ii := 1 TO i1+1 DO BEGIN
      IF ii-1 <> ip THEN BEGIN
         a[ii,kp+1] := a[ii,kp+1]*piv;
         FOR kk := 1 TO k1+1 DO
            IF kk-1 <> kp THEN
               a[ii,kk] := a[ii,kk] -a[ip+1,kk]*a[ii,kp+1]
      END
   END;
   FOR kk := 1 TO k1+1 DO
      IF kk-1 <> kp THEN
         a[ip+1,kk] := -a[ip+1,kk]*piv;
   a[ip+1,kp+1] := piv
END;

BEGIN
   IF m <> m1+m2+m3 THEN BEGIN
      writeln('pause in routine SIMPLX');
      writeln('bad input constraint counts');
      readln
   END;
   new(l1);
   new(l2);
   new(l3);
   nl1 := n;
   FOR k := 1 TO n DO BEGIN
      l1^[k] := k;
      izrov[k] := k
   END;
   nl2 := m;
   FOR i := 1 TO m DO BEGIN
      IF a[i+1,1] < 0.0 THEN BEGIN
         writeln('pause in routine SIMPLX');
         writeln('bad input tableau');
         readln
      END;
      l2^[i] := i;
      iposv[i] := n+i
   END;
   FOR i := 1 TO m2 DO l3^[i] := 1;
   ir := 0;
   IF m2+m3 = 0 THEN
      GOTO 5;
   ir := 1;
   FOR k := 1 TO n+1 DO BEGIN
      q1 := 0.0;
      FOR i := m1+1 TO m DO
         q1 := q1+a[i+1,k];
      a[m+2,k] := -q1
   END;
3: simp1(a,m+1,l1^,nl1,0,kp,bmax);
   IF (bmax <= eps) AND (a[m+2,1] < -eps) THEN BEGIN
      icase := -1;
      GOTO 99
   END
   ELSE IF (bmax <= eps)
      AND (a[m+2,1] <= eps) THEN BEGIN
      m12 := m1+m2+1;
      IF m12 <= m THEN BEGIN
         FOR ip := m12 TO m DO BEGIN
            IF iposv[ip] = ip+n THEN BEGIN
               simp1(a,ip,l1^,nl1,1,kp,bmax);
               IF bmax > 0.0 THEN GOTO 1
            END
         END
      END;
      ir := 0;
      m12 := m12-1;
      IF m1+1 > m12 THEN GOTO 5;
      FOR i := m1+1 TO m12 DO
         IF l3^[i-m1] = 1 THEN
            FOR k := 1 TO n+1 DO a[i+1,k] := -a[i+1,k];
      GOTO 5
   END;
   simp2(a,m,n,l2^,nl2,ip,kp,q1);
   IF ip = 0 THEN BEGIN
      icase := -1;
      GOTO 99
   END;
1: simp3(a,m+1,n,ip,kp);
   IF iposv[ip] >= n+m1+m2+1 THEN BEGIN
      FOR k := 1 TO nl1 DO
         IF l1^[k] = kp THEN GOTO 2;
2:    nl1 := nl1-1;
      FOR is := k TO nl1 DO l1^[is] := l1^[is+1]
   END
   ELSE BEGIN
      IF iposv[ip] < n+m1+1 THEN GOTO 4;
      kh := iposv[ip]-m1-n;
      IF l3^[kh] = 0 THEN GOTO 4;
      l3^[kh] := 0
   END;
   a[m+2,kp+1] := a[m+2,kp+1]+1.0;
   FOR i := 1 TO m+2 DO a[i,kp+1] := -a[i,kp+1];
4: is := izrov[kp];
   izrov[kp] := iposv[ip];
   iposv[ip] := is;
   IF ir <> 0 THEN
      GOTO 3;
5: simp1(a,0,l1^,nl1,0,kp,bmax);
   IF bmax <= 0.0 THEN BEGIN
      icase := 0;
      GOTO 99
   END;
   simp2(a,m,n,l2^,nl2,ip,kp,q1);
   IF ip = 0 THEN BEGIN
      icase := 1;
      GOTO 99
   END;
   simp3(a,m,n,ip,kp);
   GOTO 4;
99:
   dispose(l3);
   dispose(l2);
   dispose(l1)
END;
