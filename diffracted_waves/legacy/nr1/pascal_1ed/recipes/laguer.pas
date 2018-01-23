(* BEGINENVIRON
CONST
   mp1 =
TYPE
   Complex = RECORD
                r,i: real
             END;
   ComplexArrayMp1 = ARRAY [1..mp1] OF Complex;
ENDENVIRON *)
PROCEDURE laguer(VAR a: ComplexArrayMp1;
                     m: integer;
                 VAR x: Complex;
                   eps: real;
                polish: boolean);
LABEL 99;
CONST
   epss = 6.0e-8;
   mxit = 100;
VAR
   j,iter: integer;
   err,dxold,cdx,abx,dum: real;
   sq,h,gp,gm,g2,g: Complex;
   b,d,dx,f,x1,cdum: Complex;

PROCEDURE cdiv(VAR a,b,c: Complex);
VAR
   t,den: real;
BEGIN
   IF abs(b.r) >= abs(b.i) THEN BEGIN
      t := b.i/b.r;
      den := b.r+t*b.i;
      c.r := (a.r+a.i*t)/den;
      c.i := (a.i-a.r*t)/den
   END
   ELSE BEGIN
      t := b.r/b.i;
      den := b.i+t*b.r;
      c.r := (a.r*t+a.i)/den;
      c.i := (a.i*t-a.r)/den
   END
END;

FUNCTION cabs(VAR a: Complex): real;
VAR
   x,y : real;
BEGIN
   x := abs(a.r);
   y := abs(a.i);
   IF x = 0.0 THEN
      cabs := y
   ELSE IF y = 0.0 THEN
      cabs := x
   ELSE IF x > y THEN
      cabs := x*sqrt(1.0+sqr(y/x))
   ELSE cabs := y*sqrt(1.0+sqr(x/y))
END;

PROCEDURE csqrt(VAR a,b: Complex);
VAR
   x,y,u,v,w,t : real;
BEGIN
   IF (a.r = 0.0) AND (a.i = 0.0) THEN BEGIN
      u := 0.0;
      v := 0.0
   END
   ELSE BEGIN
      x := abs(a.r);
      y := abs(a.i);
      IF x >= y THEN
         w := sqrt(x)*sqrt(0.5*(1.0+sqrt(1.0+sqr(y/x))))
      ELSE BEGIN
         t := x/y;
         w := sqrt(y)*sqrt(0.5*(t+sqrt(1.0+sqr(t))))
      END;
      IF a.r >= 0.0 THEN BEGIN
         u := w;
         v := a.i/(2.0*u)
      END
      ELSE BEGIN
         IF a.i >= 0.0 THEN v := w ELSE v := -w;
         u := a.i/(2.0*v)
      END
   END;
   b.r := u;
   b.i := v;
END;

BEGIN
   dxold := cabs(x);
   FOR iter := 1 to mxit DO BEGIN
      b := a[m+1];
      err := cabs(b);
      d.r := 0.0;
      d.i := 0.0;
      f.r := 0.0;
      f.i := 0.0;
      abx := cabs(x);
      FOR j := m DOWNTO 1 DO BEGIN
         dum := f.r;
         f.r := x.r*f.r-x.i*f.i+d.r;
         f.i := x.r*f.i+x.i*dum+d.i;
         dum := d.r;
         d.r := x.r*d.r-x.i*d.i+b.r;
         d.i := x.r*d.i+x.i*dum+b.i;
         dum := b.r;
         b.r := x.r*b.r-x.i*b.i+a[j].r;
         b.i := x.r*b.i+x.i*dum+a[j].i;
         err := cabs(b)+abx*err
      END;
      err := epss*err;
      IF cabs(b) <= err THEN GOTO 99;
      cdiv(d,b,g);
      g2.r := sqr(g.r)-sqr(g.i);
      g2.i := 2.0*g.r*g.i;
      cdiv(f,b,cdum);
      h.r := g2.r-2.0*cdum.r;
      h.i := g2.i-2.0*cdum.i;
      cdum.r := (m-1)*(m*h.r-g2.r);
      cdum.i := (m-1)*(m*h.i-g2.i);
      csqrt(cdum,sq);
      gp.r := g.r+sq.r;
      gp.i := g.i+sq.i;
      gm.r := g.r-sq.r;
      gm.i := g.i-sq.i;
      IF cabs(gp) < cabs(gm) THEN gp := gm;
      cdum.r := m;
      cdum.i := 0.0;
      cdiv(cdum,gp,dx);
      x1.r := x.r-dx.r;
      x1.i := x.i-dx.i;
      IF (x.r = x1.r) AND (x.i = x1.i) THEN GOTO 99;
      x := x1;
      cdx := cabs(dx);
      dxold := cdx;
      IF not polish THEN
         IF cdx <= eps*cabs(x) THEN GOTO 99
   END;
   writeln('pause in routine LAGUER - too many iterations');
   readln;
99:
END;
