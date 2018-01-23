(* BEGINENVIRON
CONST
   mp =
   m4 =
TYPE
   RealArrayMP = ARRAY [1..mp] OF real;
   RealArray4tM = ARRAY [1..m4] OF real;
   RealArrayNN2 = RealArray4tM;
VAR
   dfile: text;
ENDENVIRON *)
PROCEDURE spctrm(VAR p: RealArrayMP;
                   m,k: integer;
                ovrlap: boolean);
VAR
   mm,m44,m43,m4,kk,joffn,joff,j2,j,jj: integer;
   w,sumw,facp,facm,den: real;
   w1: ^RealArray4tM;
   w2: ^RealArrayMP;

FUNCTION window(j: integer;
        facm,facp: real): real;
BEGIN
   window := 1.0-abs(((j-1)-facm)*facp)
(* window := 1.0 *)
(* window := 1.0-sqr(((j-1)-facm)*facp) *)
END;

BEGIN
   new(w1);
   new(w2);
   mm := m+m;
   m4 := mm+mm;
   m44 := m4+4;
   m43 := m4+3;
   den := 0.0;
   facm := m-0.5;
   facp := 1.0/(m+0.5);
   sumw := 0.0;
   FOR j := 1 TO mm DO
      sumw := sumw+sqr(window(j,facm,facp));
   FOR j := 1 TO m DO p[j] := 0.0;
   IF ovrlap THEN
      FOR j := 1 TO m DO read(dfile,w2^[j]);
   FOR kk := 1 TO k DO BEGIN
      FOR joff := -1 TO 0 DO BEGIN
         IF ovrlap THEN BEGIN
            FOR j := 1 TO m DO w1^[joff+j+j] := w2^[j];
            FOR j := 1 TO m DO read(dfile,w2^[j]);
            joffn := joff+mm;
            FOR j := 1 TO m DO w1^[joffn+j+j] := w2^[j]
         END
         ELSE BEGIN
            FOR jj := 0 TO (m4-joff-2) DIV 2 DO BEGIN
               j := joff+2+2*jj;
               read(dfile,w1^[j])
            END
         END
      END;
      FOR j := 1 TO mm DO BEGIN
         j2 := j+j;
         w := window(j,facm,facp);
         w1^[j2] := w1^[j2]*w;
         w1^[j2-1] := w1^[j2-1]*w
      END;
      four1(w1^,mm,1);
      p[1] := p[1]+sqr(w1^[1])+sqr(w1^[2]);
      FOR j := 2 TO m DO BEGIN
         j2 := j+j;
         p[j] := p[j]+sqr(w1^[j2])+sqr(w1^[j2-1])
                  +sqr(w1^[m44-j2])+sqr(w1^[m43-j2])
      END;
      den := den+sumw
   END;
   den := m4*den;
   FOR j := 1 TO m DO p[j] := p[j]/den;
   dispose(w2);
   dispose(w1)
END;
