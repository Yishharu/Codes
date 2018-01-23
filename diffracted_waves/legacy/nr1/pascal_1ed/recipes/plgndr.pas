FUNCTION plgndr(l,m: integer;
                  x: real): real;
VAR
   fact,pll,pmm,pmmp1,somx2: real;
   i,ll: integer;
BEGIN
   IF (m < 0) OR (m > l) OR (abs(x) > 1.0) THEN BEGIN
      writeln('Pause in routine PLGNDR');
      writeln('bad arguments');
      readln
   END;
   pmm := 1.0;
   IF m > 0 THEN BEGIN
      somx2 := sqrt((1.0-x)*(1.0+x));
      fact := 1.0;
      FOR i := 1 TO m DO BEGIN
         pmm := -pmm*fact*somx2;
         fact := fact+2.0
      END
   END;
   IF l = m THEN plgndr := pmm
   ELSE BEGIN
      pmmp1 := x*(2*m+1)*pmm;
      IF l = m+1 THEN plgndr := pmmp1
      ELSE BEGIN
         FOR ll := m+2 TO l DO BEGIN
            pll := (x*(2*ll-1)*pmmp1-(ll+m-1)*pmm)/(ll-m);
            pmm := pmmp1;
            pmmp1 := pll
         END;
         plgndr := pll
      END
   END
END;
