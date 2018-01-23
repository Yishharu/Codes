(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE tred2(VAR a: RealArrayNPbyNP;
                    n: integer;
              VAR d,e: RealArrayNP);
VAR
   l,k,j,i: integer;
   scale,hh,h,g,f: real;

FUNCTION sign(a,b: real): real;
BEGIN
   IF b < 0 THEN sign := -abs(a) ELSE sign := abs(a)
END;

BEGIN
   FOR i := n DOWNTO 2 DO BEGIN
      l := i-1;
      h := 0.0;
      scale := 0.0;
      IF l > 1 THEN BEGIN
         FOR k := 1 TO l DO
            scale := scale+abs(a[i,k]);
         IF scale = 0.0 THEN
            e[i] := a[i,l]
         ELSE BEGIN
            FOR k := 1 TO l DO BEGIN
               a[i,k] := a[i,k]/scale;
               h := h+sqr(a[i,k])
            END;
            f := a[i,l];
            g := -sign(sqrt(h),f);
            e[i] := scale*g;
            h := h-f*g;
            a[i,l] := f-g;
            f := 0.0;
            FOR j := 1 TO l DO BEGIN
               a[j,i] := a[i,j]/h;
               g := 0.0;
               FOR k := 1 TO j DO
                  g := g+a[j,k]*a[i,k];
               FOR k := j+1 TO l DO
                  g := g+a[k,j]*a[i,k];
               e[j] := g/h;
               f := f+e[j]*a[i,j]
            END;
            hh := f/(h+h);
            FOR j := 1 TO l DO BEGIN
               f := a[i,j];
               g := e[j]-hh*f;
               e[j] := g;
               FOR k := 1 TO j DO
                a[j,k] := a[j,k]-f*e[k]-g*a[i,k]
            END
         END
      END
      ELSE
         e[i] := a[i,l];
      d[i] := h
   END;
   d[1] := 0.0;
   e[1] := 0.0;
   FOR i := 1 TO n DO BEGIN
      l := i-1;
      IF d[i] <> 0.0 THEN BEGIN
         FOR j := 1 TO l DO BEGIN
            g := 0.0;
            FOR k := 1 TO l DO
               g := g+a[i,k]*a[k,j];
            FOR k := 1 TO l DO
               a[k,j] := a[k,j]-g*a[k,i]
         END
      END;
      d[i] := a[i,i];
      a[i,i] := 1.0;
      FOR j := 1 TO l DO BEGIN
         a[i,j] := 0.0;
         a[j,i] := 0.0
      END
   END
END;
