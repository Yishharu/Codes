(* BEGINENVIRON
CONST
   nyj =
   nyk =
   nci = nyj;
   ncj =
   nck =
   nsi = nyj;
   nsj =
TYPE
   IntegerArrayNYJ = ARRAY [1..nyj] OF integer;
   RealArrayNYJ = ARRAY [1..nyj] OF real;
   RealArrayNYJbyNYK = ARRAY [1..nyj,1..nyk] OF real;
   RealArrayNCIbyNCJbyNCK = ARRAY [1..nci,1..ncj,1..nck] OF real;
   RealArrayNSIbyNSJ = ARRAY [1..nsi,1..nsj] OF real;
ENDENVIRON *)
PROCEDURE solvde(itmax: integer;
            conv,slowc: real;
             VAR scalv: RealArrayNYJ;
            VAR indexv: IntegerArrayNYJ;
               ne,nb,m: integer;
                 VAR y: RealArrayNYJbyNYK;
                 VAR c: RealArrayNCIbyNCJbyNCK;
                 VAR s: RealArrayNSIbyNSJ);
LABEL 99;
VAR
   err,errj,fac,vmax,vz: real;
   ic1,ic2,ic3,ic4,it: integer;
   j,j1,j2,j3,j4,j5,j6,j7,j8,j9: integer;
   jc1,jcf,jv,k,k1,k2,km,kp,nvars: integer;
   ermax: ^RealArrayNYJ;
   kmax: ^IntegerArrayNYJ;

PROCEDURE bksub(ne,nb,jf,k1,k2: integer;
                         VAR c: RealArrayNCIbyNCJbyNCK);
VAR
   nbf,kp,k,j,i,im: integer;
   xx: real;
BEGIN
   nbf := ne-nb;
   im := 1;
   FOR k := k2 DOWNTO k1 DO BEGIN
      kp := k+1;
      IF k = k1 THEN
         im := nbf+1;
      FOR j := 1 TO nbf DO BEGIN
         xx := c[j,jf,kp];
         FOR i := im TO ne DO
            c[i,jf,k] := c[i,jf,k]-c[i,j,k]*xx
      END
   END;
   FOR k := k1 TO k2 DO BEGIN
      kp := k+1;
      FOR i := 1 TO nb DO
         c[i,1,k] := c[i+nbf,jf,k];
      FOR i := 1 TO nbf DO
         c[i+nb,1,k] := c[i,jf,kp]
   END
END;

PROCEDURE pinvs(ie1,ie2,je1,jsf,jc1,k: integer;
                                VAR c: RealArrayNCIbyNCJbyNCK;
                                VAR s: RealArrayNSIbyNSJ);
VAR
   js1,jpiv,jp,je2,jcoff,j,irow,ipiv,id,icoff,i: integer;
   pivinv,piv,dum,big: real;
   pscl: ^RealArrayNYJ;
   indxr: ^IntegerArrayNYJ;
BEGIN
   new(pscl);
   new(indxr);
   je2 := je1+ie2-ie1;
   js1 := je2+1;
   FOR i := ie1 TO ie2 DO BEGIN
      big := 0.0;
      FOR j := je1 TO je2 DO
         IF abs(s[i,j]) > big THEN big := abs(s[i,j]);
      IF big = 0.0 THEN BEGIN
         writeln('pause in routine PINVS');
         writeln('singular matrix - row all 0');
         readln
      END;
      pscl^[i] := 1.0/big;
      indxr^[i] := 0
   END;
   FOR id := ie1 TO ie2 DO BEGIN
      piv := 0.0;
      FOR i := ie1 TO ie2 DO BEGIN
         IF indxr^[i] = 0 THEN BEGIN
            big := 0.0;
            FOR j := je1 TO je2 DO BEGIN
               IF abs(s[i,j]) > big THEN BEGIN
                  jp := j;
                  big := abs(s[i,j])
               END
            END;
            IF big*pscl^[i] > piv THEN BEGIN
               ipiv := i;
               jpiv := jp;
               piv := big*pscl^[i]
            END
         END
      END;
      IF s[ipiv,jpiv] = 0.0 THEN BEGIN
         writeln('pause in routine PINVS');
         writeln('singular matrix');
         readln
      END;
      indxr^[ipiv] := jpiv;
      pivinv := 1.0/s[ipiv,jpiv];
      FOR j := je1 TO jsf DO
         s[ipiv,j] := s[ipiv,j]*pivinv;
      s[ipiv,jpiv] := 1.0;
      FOR i := ie1 TO ie2 DO BEGIN
         IF indxr^[i] <> jpiv THEN BEGIN
            IF s[i,jpiv] <> 0.0 THEN BEGIN
               dum := s[i,jpiv];
               FOR j := je1 TO jsf DO
                  s[i,j] := s[i,j]-dum*s[ipiv,j];
               s[i,jpiv] := 0.0
            END
         END
      END
   END;
   jcoff := jc1-js1;
   icoff := ie1-je1;
   FOR i := ie1 TO ie2 DO BEGIN
      irow := indxr^[i]+icoff;
      FOR j := js1 TO jsf DO
         c[irow,j+jcoff,k] := s[i,j]
   END;
   dispose(indxr);
   dispose(pscl)
END;

PROCEDURE red(iz1,iz2,jz1,jz2,jm1: integer;
           jm2,jmf,ic1,jc1,jcf,kc: integer;
                            VAR c: RealArrayNCIbyNCJbyNCK;
                            VAR s: RealArrayNSIbyNSJ);
VAR
   loff,l,j,ic,i: integer;
   vx: real;
BEGIN
   loff := jc1-jm1;
   ic := ic1;
   FOR j := jz1 TO jz2 DO BEGIN
      FOR l := jm1 TO jm2 DO BEGIN
         vx := c[ic,l+loff,kc];
         FOR i := iz1 TO iz2 DO
            s[i,l] := s[i,l]-s[i,j]*vx
      END;
      vx := c[ic,jcf,kc];
      FOR i := iz1 TO iz2 DO
         s[i,jmf] := s[i,jmf]-s[i,j]*vx;
      ic := ic+1
   END
END;

BEGIN
   new(ermax);
   new(kmax);
   k1 := 1;
   k2 := m;
   nvars := ne*m;
   j1 := 1;
   j2 := nb;
   j3 := nb+1;
   j4 := ne;
   j5 := j4+j1;
   j6 := j4+j2;
   j7 := j4+j3;
   j8 := j4+j4;
   j9 := j8+j1;
   ic1 := 1;
   ic2 := ne-nb;
   ic3 := ic2+1;
   ic4 := ne;
   jc1 := 1;
   jcf := ic3;
   FOR it := 1 TO itmax DO BEGIN
      k := k1;
      difeq(k,k1,k2,j9,ic3,ic4,indexv,ne,s,y);
      pinvs(ic3,ic4,j5,j9,jc1,k1,c,s);
      FOR k := k1+1 TO k2 DO BEGIN
         kp := k-1;
         difeq(k,k1,k2,j9,ic1,ic4,indexv,ne,s,y);
         red(ic1,ic4,j1,j2,j3,j4,j9,ic3,jc1,jcf,kp,c,s);
         pinvs(ic1,ic4,j3,j9,jc1,k,c,s)
      END;
      k := k2+1;
      difeq(k,k1,k2,j9,ic1,ic2,indexv,ne,s,y);
      red(ic1,ic2,j5,j6,j7,j8,j9,ic3,jc1,jcf,k2,c,s);
      pinvs(ic1,ic2,j7,j9,jcf,k2+1,c,s);
      bksub(ne,nb,jcf,k1,k2,c);
      err := 0.0;
      FOR j := 1 TO ne DO BEGIN
         jv := indexv[j];
         errj := 0.0;
         km := 0;
         vmax := 0.0;
         FOR k := k1 TO k2 DO BEGIN
            vz := abs(c[j,1,k]);
            IF vz > vmax THEN BEGIN
               vmax := vz;
               km := k
            END;
            errj := errj+vz
         END;
         err := err+errj/scalv[jv];
         ermax^[j] := c[j,1,km]/scalv[jv];
         kmax^[j] := km
      END;
      err := err/nvars;
      fac := 1.0;
      IF err > slowc THEN
         fac := slowc/err;
      FOR jv := 1 TO ne DO BEGIN
         j := indexv[jv];
         FOR k := k1 TO k2 DO
            y[j,k] := y[j,k]-fac*c[jv,1,k]
      END;
      writeln;
      writeln('Iter.':8,'Error':9,'FAC':9);
      writeln(it:6,err:12:6,fac:11:6);
      writeln('Var.':8,'Kmax':8,'Max. Error':14);
      FOR j := 1 TO ne DO writeln(indexv[j]:6,
      kmax^[j]:9,ermax^[j]:14:6);
      IF err < conv THEN GOTO 99
   END;
   writeln('pause in routine SOLVDE');
   writeln('too many iterations');
   readln;
99:
   dispose(kmax);
   dispose(ermax)
END;
