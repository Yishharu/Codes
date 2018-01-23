FUNCTION el2(x,qqc,aa,bb: real): real;
LABEL 1;
CONST
   pi = 3.14159265;
   ca = 0.0003;
   cb = 1.0e-9;
VAR
   a,b,c,d,e,f,g: real;
   em,eye,p,qc,y,z: real;
   l: integer;
BEGIN
   IF x = 0.0 THEN el2 := 0.0
   ELSE IF qqc <> 0.0 THEN BEGIN
      qc := qqc;
      a := aa;
      b := bb;
      c := sqr(x);
      d := 1.0+c;
      p := sqrt((1.0+c*sqr(qc))/d);
      d := x/d;
      c := d/(2.0*p);
      z := a-b;
      eye := a;
      a := 0.5*(b+a);
      y := abs(1.0/x);
      f := 0.0;
      l := 0;
      em := 1.0;
      qc := abs(qc);
1:    b := eye*qc+b;
      e := em*qc;
      g := e/p;
      d := f*g+d;
      f := c;
      eye := a;
      p := g+p;
      c := 0.5*(d/p+c);
      g := em;
      em := qc+em;
      a := 0.5*(b/em+a);
      y := -e/y+y;
      IF y = 0.0 THEN y := sqrt(e)*cb;
      IF abs(g-qc) > ca*g THEN BEGIN
         qc := sqrt(e)*2.0;
         l := l+l;
         IF y < 0.0 THEN l := l+1;
         GOTO 1
      END;
      IF y < 0.0 THEN l := l+1;
      e := (arctan(em/y)+pi*l)*a/em;
      IF x < 0.0 THEN e := -e;
      el2 := e+c*z
   END
   ELSE BEGIN
      writeln('pause in routine EL2');
      readln
   END
END;
