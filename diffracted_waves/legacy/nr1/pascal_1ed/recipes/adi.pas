(* BEGINENVIRON
CONST
   jmaxp =
TYPE
   DoubleArrayJMAXbyJMAX = ARRAY [1..jmaxp,1..jmaxp] OF double;
ENDENVIRON *)
PROCEDURE adi(VAR a,b,c,d,e,f,g,u: DoubleArrayJMAXbyJMAX;
                           jmax,k: integer;
                   alpha,beta,eps: double);
LABEL 99;
CONST
   jj = 50;
   kk = 6;
   nrr = 32;
   maxits = 100;
TYPE
   DoubleArrayJJ = ARRAY [1..jj] OF double;
   DoubleArrayKK = ARRAY [1..kk] OF double;
   DoubleArrayNRR = ARRAY [1..nrr] OF double;
   DoubleArrayJJbyJJ = ARRAY [1..jj,1..jj] OF double;
   DoubleArrayNRRbyKK = ARRAY [1..nrr,1..kk] OF double;
VAR
   i,nr,nits,next,n,l,kits,k1,j,twopwr: integer;
   rfact,resid,disc,anormg,anorm,ab: double;
   aa,bb,cc,rr,uu: ^DoubleArrayJJ;
   psi: ^DoubleArrayJJbyJJ;
   alph,bet: ^DoubleArrayKK;
   r: ^DoubleArrayNRR;
   s: ^DoubleArrayNRRbyKK;

PROCEDURE tridag(VAR a,b,c,r,u: DoubleArrayJJ;
                             n: integer);
VAR
   j: integer;
   bet: double;
   gam: ^DoubleArrayJJ;
BEGIN
   new(gam);
   IF b[1] = 0.0 THEN BEGIN
      writeln('pause 1 in TRIDAG');
      readln
   END;
   bet := b[1];
   u[1] := r[1]/bet;
   FOR j := 2 TO n DO BEGIN
      gam^[j] := c[j-1]/bet;
      bet := b[j]-a[j]*gam^[j];
      IF bet = 0.0 THEN BEGIN
         writeln('pause 2 in TRIDAG');
         readln
      END;
      u[j] := (r[j]-a[j]*u[j-1])/bet
   END;
   FOR j := n-1 DOWNTO 1 DO
      u[j] := u[j]-gam^[j+1]*u[j+1];
   dispose(gam)
END;

BEGIN
   IF jmax > jj THEN BEGIN
      writeln('Pause in routine ADI - increase jj');
      readln
   END;
   IF k > (kk-1) THEN BEGIN
      writeln('Pause in routine ADI - increase kk');
      readln
   END;
   new(aa);
   new(bb);
   new(cc);
   new(rr);
   new(uu);
   new(psi);
   new(alph);
   new(bet);
   new(r);
   new(s);
   k1 := k+1;
   nr := 1;
   FOR i := 1 TO k DO
      nr := 2*nr;
   alph^[1] := alpha;
   bet^[1] := beta;
   FOR j := 1 TO k DO BEGIN
      alph^[j+1] := sqrt(alph^[j]*bet^[j]);
      bet^[j+1] := 0.5*(alph^[j]+bet^[j])
   END;
   s^[1,1] := sqrt(alph^[k1]*bet^[k1]);
   FOR j := 1 TO k DO BEGIN
      ab := alph^[k1-j]*bet^[k1-j];
      twopwr := 1;
      FOR i := 1 TO j-1 DO twopwr := 2*twopwr;
      FOR n := 1 TO twopwr DO BEGIN
         disc := sqrt(sqr(s^[n,j])-ab);
         s^[2*n,j+1] := s^[n,j]+disc;
         s^[2*n-1,j+1] := ab/s^[2*n,j+1]
      END
   END;
   FOR n := 1 TO nr DO r^[n] := s^[n,k1];
   anormg := 0.0;
   FOR j := 2 TO jmax-1 DO BEGIN
      FOR l := 2 TO jmax-1 DO BEGIN
         anormg := anormg+abs(g[j,l]);
         psi^[j,l] := -d[j,l]*u[j,l-1]
                  +(r^[1]-e[j,l])*u[j,l]-f[j,l]*u[j,l+1]
      END
   END;
   nits := maxits DIV nr;
   FOR kits := 1 TO nits DO BEGIN
      FOR n := 1 TO nr DO BEGIN
         IF n = nr THEN next := 1 ELSE next := n+1;
         rfact := r^[n]+r^[next];
         FOR l := 2 TO jmax-1 DO BEGIN
            FOR j := 2 TO jmax-1 DO BEGIN
               aa^[j-1] := a[j,l];
               bb^[j-1] := b[j,l]+r^[n];
               cc^[j-1] := c[j,l];
               rr^[j-1] := psi^[j,l]-g[j,l]
            END;
            tridag(aa^,bb^,cc^,rr^,uu^,jmax-2);
            FOR j := 2 TO jmax-1 DO
               psi^[j,l] := -psi^[j,l] +2.0*r^[n]*uu^[j-1]
         END;
         FOR j := 2 TO jmax-1 DO BEGIN
            FOR l := 2 TO jmax-1 DO BEGIN
               aa^[l-1] := d[j,l];
               bb^[l-1] := e[j,l]+r^[n];
               cc^[l-1] := f[j,l];
               rr^[l-1] := psi^[j,l]
            END;
            tridag(aa^,bb^,cc^,rr^,uu^,jmax-2);
            FOR l := 2 TO jmax-1 DO BEGIN
               u[j,l] := uu^[l-1];
               psi^[j,l] := -psi^[j,l]+rfact*uu^[l-1]
            END
         END
      END;
      anorm := 0.0;
      FOR j := 2 TO jmax-1 DO BEGIN
         FOR l := 2 TO jmax-1 DO BEGIN
            resid := a[j,l]*u[j-1,l]+(b[j,l]+e[j,l])*u[j,l]+c[j,l]*u[j+1,l]
                     +d[j,l]*u[j,l-1]+f[j,l]*u[j,l+1]+g[j,l];
            anorm := anorm+abs(resid)
         END
      END;
      IF anorm < eps*anormg THEN GOTO 99
   END;
   writeln('Pause in routine ADI - too many iterations');
99:
   dispose(s);
   dispose(r);
   dispose(bet);
   dispose(alph);
   dispose(psi);
   dispose(uu);
   dispose(rr);
   dispose(cc);
   dispose(bb);
   dispose(aa)
END;
