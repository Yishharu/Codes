(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE tqli(VAR d,e: RealArrayNP;
                     n: integer;
                 VAR z: RealArrayNPbyNP);
LABEL 10,20;
VAR
   m,l,iter,i,k: integer;
   s,r,p,g,f,dd,c,b: real;

FUNCTION sign(a,b: real): real;
BEGIN
   IF b < 0 THEN sign := -abs(a) ELSE sign := abs(a)
END;

BEGIN
   FOR i := 2 TO n DO e[i-1] := e[i];
   e[n] := 0.0;
   FOR l := 1 TO n DO BEGIN
      iter := 0;
10:   FOR m := l TO n-1 DO BEGIN
         dd := abs(d[m])+abs(d[m+1]);
         IF abs(e[m])+dd = dd THEN GOTO 20
      END;
      m := n;
20:   IF m <> l THEN BEGIN
         IF iter = 30 THEN BEGIN
            writeln('pause in routine TQLI');
            writeln('too many iterations');
            readln
         END;
         iter := iter+1;
         g := (d[l+1]-d[l])/(2.0*e[l]);
         r := sqrt(sqr(g)+1.0);
         g := d[m]-d[l]+e[l]/(g+sign(r,g));
         s := 1.0;
         c := 1.0;
         p := 0.0;
         FOR i := m-1 DOWNTO l DO BEGIN
            f := s*e[i];
            b := c*e[i];
            IF abs(f) >= abs(g) THEN BEGIN
               c := g/f;
               r := sqrt(sqr(c)+1.0);
               e[i+1] := f*r;
               s := 1.0/r;
               c := c*s
            END
            ELSE BEGIN
               s := f/g;
               r := sqrt(sqr(s)+1.0);
               e[i+1] := g*r;
               c := 1.0/r;
               s := s*c
            END;
            g := d[i+1]-p;
            r := (d[i]-g)*s+2.0*c*b;
            p := s*r;
            d[i+1] := g+p;
            g := c*r-b;
            FOR k := 1 TO n DO BEGIN
               f := z[k,i+1];
               z[k,i+1] := s*z[k,i]+c*f;
               z[k,i] := c*z[k,i]-s*f
            END
         END;
         d[l] := d[l]-p;
         e[l] := g;
         e[m] := 0.0;
         GOTO 10
      END
   END
END;
