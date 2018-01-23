(* BEGINENVIRON
VAR
   BnldevNold: integer;
   BnldevPold,BnldevOldg,BnldevEn,BnldevPc,BnldevPlog,BnldevPclog: real;
BEGIN
   BnldevNold := -1;
   BnldevPold := -1.0;
ENDENVIRON *)
FUNCTION bnldev(pp: real;
                 n: integer;
          VAR idum: integer): real;
CONST
   pi = 3.141592654;
VAR
   am,em,g,angle,p,bnl,sq,t,y: real;
   j: integer;
BEGIN
   IF pp <= 0.5 THEN p := pp ELSE p := 1.0-pp;
   am := n*p;
   IF n < 25 THEN BEGIN
      bnl := 0.0;
      FOR j := 1 TO n DO IF ran3(idum) < p THEN bnl := bnl+1.0
   END
   ELSE IF am < 1.0 THEN BEGIN
      g := exp(-am);
      t := 1.0;
      j := -1;
      REPEAT
         j := j+1;
         t := t*ran3(idum);
      UNTIL (t < g) OR (j = n);
      bnl := j
   END
   ELSE BEGIN
      IF n <> BnldevNold THEN BEGIN
         BnldevEn := n;
         BnldevOldg := gammln(BnldevEn+1.0);
         BnldevNold := n
      END;
      IF p <> BnldevPold THEN BEGIN
         BnldevPc := 1.0-p;
         BnldevPlog := ln(p);
         BnldevPclog := ln(BnldevPc);
         BnldevPold := p
      END;
      sq := sqrt(2.0*am*BnldevPc);
      REPEAT
         REPEAT
            angle := pi*ran3(idum);
            y := sin(angle)/cos(angle);
            em := sq*y+am;
         UNTIL (em >= 0.0) AND (em < BnldevEn+1.0);
         em := trunc(em);
         t := 1.2*sq*(1.0+sqr(y))*exp(BnldevOldg-gammln(em+1.0)
            -gammln(BnldevEn-em+1.0)+em*BnldevPlog+(BnldevEn-em)*BnldevPclog);
      UNTIL ran3(idum) <= t;
      bnl := em
   END;
   IF p <> pp THEN bnl := n-bnl;
   bnldev := bnl
END;
