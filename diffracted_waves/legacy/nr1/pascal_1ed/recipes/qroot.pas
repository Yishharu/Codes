(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNV = ARRAY [1..3] OF real;
ENDENVIRON *)
PROCEDURE qroot(VAR p: RealArrayNP;
                    n: integer;
              VAR b,c: real;
                  eps: real);
LABEL 99;
CONST
   itmax = 20;
   tiny = 1.0e-6;
VAR
   iter,i: integer;
   sc,sb,s,rc,rb,r,dv,delc,delb: real;
   q,qq,rem: ^RealArrayNP;
   d: ^RealArrayNV;
BEGIN
   new(q);
   new(qq);
   new(rem);
   new(d);
   d^[3] := 1.0;
   FOR iter := 1 TO itmax DO BEGIN
      d^[2] := b;
      d^[1] := c;
      poldiv(p,n,d^,3,q^,rem^);
      s := rem^[1];
      r := rem^[2];
      poldiv(q^,n-1,d^,3,qq^,rem^);
      sc := -rem^[1];
      rc := -rem^[2];
      FOR i := n-1 DOWNTO 1 DO q^[i+1] := q^[i];
      q^[1] := 0.0;
      poldiv(q^,n,d^,3,qq^,rem^);
      sb := -rem^[1];
      rb := -rem^[2];
      dv := 1.0/(sb*rc-sc*rb);
      delb := (r*sc-s*rc)*dv;
      delc := (-r*sb+s*rb)*dv;
      b := b+delb;
      c := c+delc;
      IF ((abs(delb) <= eps*abs(b)) OR (abs(b) < tiny)) AND
         ((abs(delc) <= eps*abs(c)) OR (abs(c) < tiny)) THEN GOTO 99
   END;
   writeln('pause in routine QROOT - too many iterations');
99:
   dispose(d);
   dispose(rem);
   dispose(qq);
   dispose(q)
END;
