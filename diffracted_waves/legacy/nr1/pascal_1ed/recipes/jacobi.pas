(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE jacobi(VAR a: RealArrayNPbyNP;
                     n: integer;
                 VAR d: RealArrayNP;
                 VAR v: RealArrayNPbyNP;
              VAR nrot: integer);
LABEL 99;
VAR
   j,iq,ip,i: integer;
   tresh,theta,tau,t,sm,s,h,g,c: real;
   b,z: ^RealArrayNP;
BEGIN
   new(b);
   new(z);
   FOR ip := 1 TO n DO BEGIN
      FOR iq := 1 TO n DO v[ip,iq] := 0.0;
      v[ip,ip] := 1.0
   END;
   FOR ip := 1 TO n DO BEGIN
      b^[ip] := a[ip,ip];
      d[ip] := b^[ip];
      z^[ip] := 0.0
   END;
   nrot := 0;
   FOR i := 1 TO 50 DO BEGIN
      sm := 0.0;
      FOR ip := 1 TO n-1 DO
         FOR iq := ip+1 TO n DO
            sm := sm+abs(a[ip,iq]);
      IF sm = 0.0 THEN GOTO 99;
      IF i < 4 THEN tresh := 0.2*sm/sqr(n)
      ELSE tresh := 0.0;
      FOR ip := 1 TO n-1 DO BEGIN
         FOR iq := ip+1 TO n DO BEGIN
            g := 100.0*abs(a[ip,iq]);
            IF (i > 4) AND (abs(d[ip])+g = abs(d[ip]))
               AND (abs(d[iq])+g = abs(d[iq])) THEN a[ip,iq] := 0.0
            ELSE IF abs(a[ip,iq]) > tresh THEN BEGIN
               h := d[iq]-d[ip];
               IF abs(h)+g = abs(h) THEN
                  t := a[ip,iq]/h
               ELSE BEGIN
                  theta := 0.5*h/a[ip,iq];
                  t := 1.0/(abs(theta)+sqrt(1.0+sqr(theta)));
                  IF theta < 0.0 THEN t := -t
               END;
               c := 1.0/sqrt(1+sqr(t));
               s := t*c;
               tau := s/(1.0+c);
               h := t*a[ip,iq];
               z^[ip] := z^[ip]-h;
               z^[iq] := z^[iq]+h;
               d[ip] := d[ip]-h;
               d[iq] := d[iq]+h;
               a[ip,iq] := 0.0;
               FOR j := 1 TO ip-1 DO BEGIN
                  g := a[j,ip];
                  h := a[j,iq];
                  a[j,ip] := g-s*(h+g*tau);
                  a[j,iq] := h+s*(g-h*tau)
               END;
               FOR j := ip+1 TO iq-1 DO BEGIN
                  g := a[ip,j];
                  h := a[j,iq];
                  a[ip,j] := g-s*(h+g*tau);
                  a[j,iq] := h+s*(g-h*tau)
               END;
               FOR j := iq+1 TO n DO BEGIN
                  g := a[ip,j];
                  h := a[iq,j];
                  a[ip,j] := g-s*(h+g*tau);
                  a[iq,j] := h+s*(g-h*tau)
               END;
               FOR j := 1 TO n DO BEGIN
                  g := v[j,ip];
                  h := v[j,iq];
                  v[j,ip] := g-s*(h+g*tau);
                  v[j,iq] := h+s*(g-h*tau)
               END;
               nrot := nrot+1
            END
         END
      END;
      FOR ip := 1 TO n DO BEGIN
         b^[ip] := b^[ip]+z^[ip];
         d[ip] := b^[ip];
         z^[ip] := 0.0
      END
   END;
   writeln('pause in routine JACOBI');
   writeln('50 iterations should not happen');
   readln;
99:
   dispose(z);
   dispose(b)
END;
