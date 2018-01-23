FUNCTION cel(qqc,pp,aa,bb: real): real;
LABEL 99;
CONST
   ca = 0.0003;
   pio2 = 1.5707963268;
VAR
   a,b,e,f,g: real;
   em,p,q,qc: real;
BEGIN
   IF qqc = 0.0 THEN BEGIN
      writeln('pause in routine CEL');
      readln
   END;
   qc := abs(qqc);
   a := aa;
   b := bb;
   p := pp;
   e := qc;
   em := 1.0;
   IF p > 0.0 THEN BEGIN
      p := sqrt(p);
      b := b/p
   END
   ELSE BEGIN
      f := qc*qc;
      q := 1.0-f;
      g := 1.0-p;
      f := f-p;
      q := q*(b-a*p);
      p := sqrt(f/g);
      a := (a-b)/g;
      b := -q/(g*g*p)+a*p
   END;
   WHILE true DO BEGIN
      f := a;
      a := a+b/p;
      g := e/p;
      b := b+f*g;
      b := b+b;
      p := g+p;
      g := em;
      em := qc+em;
      IF abs(g-qc) <= g*ca THEN GOTO 99;
      qc := sqrt(e);
      qc := qc+qc;
      e := qc*em
   END;
99:
   cel := pio2*(b+a*em)/(em*(em+p))
END;
