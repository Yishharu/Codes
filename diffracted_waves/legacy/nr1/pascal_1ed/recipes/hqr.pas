(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE hqr(VAR a: RealArrayNPbyNP;
                  n: integer;
          VAR wr,wi: RealArrayNP);
LABEL 2,3,4;
VAR
   nn,m,l,k,j,its,i,mmin: integer;
   z,y,x,w,v,u,t,s,r,q,p,anorm: real;

FUNCTION sign(a,b: real): real;
BEGIN
   IF b < 0.0 THEN sign := -abs(a) ELSE sign := abs(a)
END;

FUNCTION min(a,b: integer): integer;
BEGIN
   IF a < b THEN min := a ELSE min := b
END;

BEGIN
   anorm := abs(a[1,1]);
   FOR i := 2 TO n DO
      FOR j := i-1 TO n DO anorm := anorm+abs(a[i,j]);
   nn := n;
   t := 0.0;
   WHILE nn >= 1 DO BEGIN
      its := 0;
2:    FOR l := nn DOWNTO 2 DO BEGIN
         s := abs(a[l-1,l-1])+abs(a[l,l]);
         IF s = 0.0 THEN s := anorm;
         IF abs(a[l,l-1])+s = s THEN GOTO 3
      END;
      l := 1;
3:    x := a[nn,nn];
      IF l = nn THEN BEGIN
         wr[nn] := x+t;
         wi[nn] := 0.0;
         nn := nn-1
      END
      ELSE BEGIN
         y := a[nn-1,nn-1];
         w := a[nn,nn-1]*a[nn-1,nn];
         IF l = nn-1 THEN BEGIN
            p := 0.5*(y-x);
            q := sqr(p)+w;
            z := sqrt(abs(q));
            x := x+t;
            IF q >= 0.0 THEN BEGIN
               z := p+sign(z,p);
               wr[nn] := x+z;
               wr[nn-1] := wr[nn];
               IF z <> 0.0 THEN wr[nn] := x-w/z;
               wi[nn] := 0.0;
               wi[nn-1] := 0.0
            END
            ELSE BEGIN
               wr[nn] := x+p;
               wr[nn-1] := wr[nn];
               wi[nn] := z;
               wi[nn-1] := -z
            END;
            nn := nn-2
         END
         ELSE BEGIN
            IF its = 30 THEN BEGIN
               writeln('pause in routine HQR');
               writeln('too many iterations');
               readln
            END;
            IF (its = 10) OR (its = 20) THEN BEGIN
               t := t+x;
               FOR i := 1 TO nn DO
                  a[i,i] := a[i,i]-x;
               s := abs(a[nn,nn-1])+abs(a[nn-1,nn-2]);
               x := 0.75*s;
               y := x;
               w := -0.4375*sqr(s)
            END;
            its := its+1;
            FOR m := nn-2 DOWNTO l DO BEGIN
               z := a[m,m];
               r := x-z;
               s := y-z;
               p := (r*s-w)/a[m+1,m]+a[m,m+1];
               q := a[m+1,m+1]-z-r-s;
               r := a[m+2,m+1];
               s := abs(p)+abs(q)+abs(r);
               p := p/s;
               q := q/s;
               r := r/s;
               IF m = l THEN GOTO 4;
               u := abs(a[m,m-1])*(abs(q)+abs(r));
               v := abs(p)*(abs(a[m-1,m-1])+abs(z) +abs(a[m+1,m+1]));
               IF u+v = v THEN GOTO 4
            END;
4:          FOR i := m+2 TO nn DO BEGIN
               a[i,i-2] := 0.0;
               IF i <> m+2 THEN a[i,i-3] := 0.0
            END;
            FOR k := m TO nn-1 DO BEGIN
               IF k <> m THEN BEGIN
                  p := a[k,k-1];
                  q := a[k+1,k-1];
                  IF k <> nn-1 THEN
                     r := a[k+2,k-1]
                  ELSE
                     r := 0.0;
                  x := abs(p)+abs(q)+abs(r);
                  IF x <> 0.0 THEN BEGIN
                     p := p/x;
                     q := q/x;
                     r := r/x
                  END
               END;
               s := sign(sqrt(sqr(p)+sqr(q)+sqr(r)),p);
               IF s <> 0.0 THEN BEGIN
                  IF k = m THEN BEGIN
                     IF l <> m THEN
                        a[k,k-1] := -a[k,k-1];
                  END
                  ELSE
                     a[k,k-1] := -s*x;
                  p := p+s;
                  x := p/s;
                  y := q/s;
                  z := r/s;
                  q := q/p;
                  r := r/p;
                  FOR j := k TO nn DO BEGIN
                     p := a[k,j]+q*a[k+1,j];
                     IF k <> nn-1 THEN BEGIN
                        p := p+r*a[k+2,j];
                        a[k+2,j] := a[k+2,j]-p*z
                     END;
                     a[k+1,j] := a[k+1,j]-p*y;
                     a[k,j] := a[k,j]-p*x
                  END;
                  mmin := min(nn,k+3);
                  FOR i := l TO mmin DO BEGIN
                     p := x*a[i,k]+y*a[i,k+1];
                     IF k <> nn-1 THEN BEGIN
                        p := p+z*a[i,k+2];
                        a[i,k+2] := a[i,k+2]-p*r
                     END;
                     a[i,k+1] := a[i,k+1]-p*q;
                     a[i,k] := a[i,k]-p
                  END
               END
            END;
            GOTO 2
         END
      END
   END
END;
