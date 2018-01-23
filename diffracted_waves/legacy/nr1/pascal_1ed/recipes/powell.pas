(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
FUNCTION fnc(VAR p: RealArrayNP): real;
ENDENVIRON *)
PROCEDURE powell(VAR p: RealArrayNP;
                VAR xi: RealArrayNPbyNP;
                     n: integer;
                  ftol: real;
              VAR iter: integer;
              VAR fret: real);
LABEL 99;
CONST
   itmax = 200;
VAR
   j,ibig,i: integer;
   t,fptt,fp,del: real;
   pt,ptt,xit: ^RealArrayNP;
BEGIN
   new(pt);
   new(ptt);
   new(xit);
   fret := fnc(p);
   FOR j := 1 TO n DO pt^[j] := p[j];
   iter := 0;
   WHILE true DO BEGIN
      iter := iter+1;
      fp := fret;
      ibig := 0;
      del := 0.0;
      FOR i := 1 TO n DO BEGIN
         FOR j := 1 TO n DO
            xit^[j] := xi[j,i];
         fptt := fret;
         linmin(p,xit^,n,fret);
         IF abs(fptt-fret) > del THEN BEGIN
            del := abs(fptt-fret);
            ibig := i
         END
      END;
      IF 2.0*abs(fp-fret)
         <= ftol*(abs(fp)+abs(fret)) THEN GOTO 99;
      IF iter = itmax THEN BEGIN
         writeln('pause in routine POWELL');
         writeln('too many interations');
         readln
      END;
      FOR j := 1 TO n DO BEGIN
         ptt^[j] := 2.0*p[j]-pt^[j];
         xit^[j] := p[j]-pt^[j];
         pt^[j] := p[j]
      END;
      fptt := fnc(ptt^);
      IF fptt < fp THEN BEGIN
         t := 2.0*(fp-2.0*fret+fptt)*sqr(fp-fret-del)-del*sqr(fp-fptt);
         IF t < 0.0 THEN BEGIN
            linmin(p,xit^,n,fret);
            FOR j := 1 TO n DO
               xi[j,ibig] := xit^[j]
         END
      END
   END;
99:
   dispose(xit);
   dispose(ptt);
   dispose(pt)
END;
