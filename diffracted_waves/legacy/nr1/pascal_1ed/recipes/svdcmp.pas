(* BEGINENVIRON
CONST
   mp =
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE svdcmp(VAR a: RealArrayMPbyNP;
                   m,n: integer;
                 VAR w: RealArrayNP;
                 VAR v: RealArrayNPbyNP);
LABEL 1,2,3;
VAR
   nm,l,k,j,jj,its,i,mnmin: integer;
   z,y,x,scale,s,h,g,f,c,anorm: real;
   rv1: ^RealArrayNP;

FUNCTION sign(a,b: real): real;
BEGIN
   IF b >= 0.0 THEN sign := abs(a) ELSE sign := -abs(a)
END;

FUNCTION max(a,b: real): real;
BEGIN
   IF a > b THEN max := a ELSE max := b
END;

FUNCTION pythag(a,b: real): real;
VAR
   at,bt: real;
BEGIN
   at := abs(a);
   bt := abs(b);
   IF at > bt THEN
      pythag := at*sqrt(1.0+sqr(bt/at))
   ELSE
      IF bt = 0.0 THEN
         pythag := 0.0
      ELSE
         pythag := bt*sqrt(1.0+sqr(at/bt))
END;

BEGIN
   new(rv1);
   g := 0.0;
   scale := 0.0;
   anorm := 0.0;
   FOR i := 1 TO n DO BEGIN
      l := i+1;
      rv1^[i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF i <= m THEN BEGIN
         FOR k := i TO m DO
            scale := scale+abs(a[k,i]);
         IF scale <> 0.0 THEN BEGIN
            FOR k := i TO m DO BEGIN
               a[k,i] := a[k,i]/scale;
               s := s+a[k,i]*a[k,i]
            END;
            f := a[i,i];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,i] := f-g;
            FOR j := l TO n DO BEGIN
               s := 0.0;
               FOR k := i TO m DO
                  s := s+a[k,i]*a[k,j];
               f := s/h;
               FOR k := i TO m DO
                  a[k,j] := a[k,j]+ f*a[k,i]
            END;
            FOR k := i TO m DO
               a[k,i] := scale*a[k,i]
         END
      END;
      w[i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF (i <= m) AND (i <> n) THEN BEGIN
         FOR k := l TO n DO
            scale := scale+abs(a[i,k]);
         IF scale <> 0.0 THEN BEGIN
            FOR k := l TO n DO BEGIN
               a[i,k] := a[i,k]/scale;
               s := s+a[i,k]*a[i,k]
            END;
            f := a[i,l];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,l] := f-g;
            FOR k := l TO n DO
               rv1^[k] := a[i,k]/h;
            FOR j := l TO m DO BEGIN
               s := 0.0;
               FOR k := l TO n DO
                  s := s+a[j,k]*a[i,k];
               FOR k := l TO n DO
                  a[j,k] := a[j,k] +s*rv1^[k]
            END;
            FOR k := l TO n DO
               a[i,k] := scale*a[i,k]
         END
      END;
      anorm := max(anorm,(abs(w[i])+abs(rv1^[i])))
   END;
   FOR i := n DOWNTO 1 DO BEGIN
      IF i < n THEN BEGIN
         IF g <> 0.0 THEN BEGIN
            FOR j := l TO n DO
               v[j,i] := (a[i,j]/a[i,l])/g;
            FOR j := l TO n DO BEGIN
               s := 0.0;
               FOR k := l TO n DO
                  s := s+a[i,k]*v[k,j];
               FOR k := l TO n DO
                  v[k,j] := v[k,j]+s*v[k,i]
            END
         END;
         FOR j := l TO n DO BEGIN
            v[i,j] := 0.0;
            v[j,i] := 0.0
         END
      END;
      v[i,i] := 1.0;
      g := rv1^[i];
      l := i
   END;
   IF m < n THEN
      mnmin := m
   ELSE
      mnmin := n;
   FOR i := mnmin DOWNTO 1 DO BEGIN
      l := i+1;
      g := w[i];
      FOR j := l TO n DO a[i,j] := 0.0;
      IF g <> 0.0 THEN BEGIN
         g := 1.0/g;
         FOR j := l TO n DO BEGIN
            s := 0.0;
            FOR k := l TO m DO
               s := s+a[k,i]*a[k,j];
            f := (s/a[i,i])*g;
            FOR k := i TO m DO
               a[k,j] := a[k,j]+f*a[k,i]
         END;
         FOR j := i TO m DO
            a[j,i] := a[j,i]*g
      END
      ELSE
         FOR j := i TO m DO a[j,i] := 0.0;
      a[i,i] := a[i,i]+1.0
   END;
   FOR k := n DOWNTO 1 DO BEGIN
      FOR its := 1 TO 30 DO BEGIN
         FOR l := k DOWNTO 1 DO BEGIN
            nm := l-1;
            IF abs(rv1^[l])+anorm = anorm THEN GOTO 2;
            IF nm > 0 THEN
               IF abs(w[nm])+anorm = anorm THEN GOTO 1
         END;
1:       c := 0.0;
         s := 1.0;
         FOR i := l TO k DO BEGIN
            f := s*rv1^[i];
            rv1^[i] := c*rv1^[i];
            IF abs(f)+anorm = anorm THEN GOTO 2;
            g := w[i];
            h := pythag(f,g);
            w[i] := h;
            h := 1.0/h;
            c := (g*h);
            s := -(f*h);
            FOR j := 1 TO m DO BEGIN
               y := a[j,nm];
               z := a[j,i];
               a[j,nm] := (y*c)+(z*s);
               a[j,i] := -(y*s)+(z*c)
            END
         END;
2:       z := w[k];
         IF l = k THEN BEGIN
            IF z < 0.0 THEN BEGIN
               w[k] := -z;
               FOR j := 1 TO n DO v[j,k] := -v[j,k]
            END;
            GOTO 3
         END;
         IF its = 30 THEN BEGIN
            writeln ('no convergence in 30 SVDCMP iterations');
            readln
         END;
         x := w[l];
         nm := k-1;
         y := w[nm];
         g := rv1^[nm];
         h := rv1^[k];
         f := ((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y);
         g := pythag(f,1.0);
         f := ((x-z)*(x+z)+h*((y/(f+sign(g,f)))-h))/x;
         c := 1.0;
         s := 1.0;
         FOR j := l TO nm DO BEGIN
            i := j+1;
            g := rv1^[i];
            y := w[i];
            h := s*g;
            g := c*g;
            z := pythag(f,h);
            rv1^[j] := z;
            c := f/z;
            s := h/z;
            f := (x*c)+(g*s);
            g := -(x*s)+(g*c);
            h := y*s;
            y := y*c;
            FOR jj := 1 TO n DO BEGIN
               x := v[jj,j];
               z := v[jj,i];
               v[jj,j] := (x*c)+(z*s);
               v[jj,i] := -(x*s)+(z*c)
            END;
            z := pythag(f,h);
            w[j] := z;
            IF z <> 0.0 THEN BEGIN
               z := 1.0/z;
               c := f*z;
               s := h*z
            END;
            f := (c*g)+(s*y);
            x := -(s*g)+(c*y);
            FOR jj := 1 TO m DO BEGIN
               y := a[jj,j];
               z := a[jj,i];
               a[jj,j] := (y*c)+(z*s);
               a[jj,i] := -(y*s)+(z*c)
            END
         END;
         rv1^[l] := 0.0;
         rv1^[k] := f;
         w[k] := x
      END;
3: END;
   dispose(rv1)
END;
