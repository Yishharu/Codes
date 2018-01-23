(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE spear(VAR data1,data2: RealArrayNP;
                              n: integer;
       VAR d,zd,probd,rs,probrs: real);
VAR
   j: integer;
   vard,t,sg,sf,fac,en3n,en,df,aved: real;
   wksp1,wksp2: ^RealArrayNP;

PROCEDURE crank(n: integer;
            VAR w: RealArrayNP;
            VAR s: real);
LABEL 1;
VAR
   j,ji,jt,lbl1,lbl2: integer;
   t,rank: real;
BEGIN
   s := 0.0;
   j := 1;
   WHILE j < n DO BEGIN
      IF w[j+1] <> w[j] THEN BEGIN
         w[j] := j;
         j := j+1
      END
      ELSE BEGIN
         FOR jt := j+1 TO n DO
            IF w[jt] <> w[j] THEN GOTO 1;
         jt := n+1;
1:       rank := 0.5*(j+jt-1);
         FOR ji := j TO jt-1 DO
            w[ji] := rank;
         t := jt-j;
         s := s+t*t*t-t;
         j := jt
      END
   END;
   IF j = n THEN w[n] := n
END;

BEGIN
   new(wksp1);
   new(wksp2);
   FOR j := 1 TO n DO BEGIN
      wksp1^[j] := data1[j];
      wksp2^[j] := data2[j]
   END;
   sort2(n,wksp1^,wksp2^);
   crank(n,wksp1^,sf);
   sort2(n,wksp2^,wksp1^);
   crank(n,wksp2^,sg);
   d := 0.0;
   FOR j := 1 TO n DO
      d := d+sqr(wksp1^[j]-wksp2^[j]);
   en := n;
   en3n := en*en*en-en;
   aved := en3n/6.0-(sf+sg)/12.0;
   fac := (1.0-sf/en3n)*(1.0-sg/en3n);
   vard := ((en-1.0)*sqr(en)*sqr(en+1.0)/36.0)*fac;
   zd := (d-aved)/sqrt(vard);
   probd := erfcc(abs(zd)/1.4142136);
   rs := (1.0-(6.0/en3n)*(d+(sf+sg)/12.0))/sqrt(fac);
   fac := (1.0+rs)*(1.0-rs);
   IF fac <> 0.0 THEN BEGIN
      t := rs*sqrt((en-2.0)/fac);
      df := en-2.0;
      probrs := betai(0.5*df,0.5,df/(df+sqr(t)))
   END
   ELSE
      probrs := 0.0;
   dispose(wksp2);
   dispose(wksp1)
END;
