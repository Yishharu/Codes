(* BEGINENVIRON
CONST
   nvar =
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
ENDENVIRON *)
PROCEDURE bsstep(VAR y,dydx: RealArrayNVAR;
                          n: integer;
                      VAR x: real;
                   htry,eps: real;
                  VAR yscal: RealArrayNVAR;
             VAR hdid,hnext: real);
LABEL 99;
CONST
   imax = 11;
   nuse = 7;
   shrink = 0.95e0;
   grow = 1.2e0;
VAR
   j,i: integer;
   xsav,xest,h,errmax: real;
   ysav,dysav,yseq,yerr: ^RealArrayNVAR;
   nseq: ARRAY [1..imax] OF integer;
BEGIN
   new(ysav);
   new(dysav);
   new(yseq);
   new(yerr);
   nseq[1] := 2;
   nseq[2] := 4;
   nseq[3] := 6;
   nseq[4] := 8;
   nseq[5] := 12;
   nseq[6] := 16;
   nseq[7] := 24;
   nseq[8] := 32;
   nseq[9] := 48;
   nseq[10] := 64;
   nseq[11] := 96;
   h := htry;
   xsav := x;
   FOR i := 1 TO n DO BEGIN
      ysav^[i] := y[i];
      dysav^[i] := dydx[i]
   END;
   WHILE true DO BEGIN
      FOR i := 1 TO imax DO BEGIN
         mmid(ysav^,dysav^,n,xsav,h,nseq[i],yseq^);
         xest := sqr(h/nseq[i]);
         rzextr(i,xest,yseq^,y,yerr^,n,nuse);
         IF i > 3 THEN BEGIN
            errmax := 0.0;
            FOR j := 1 TO n DO
               IF errmax < abs(yerr^[j]/yscal[j]) THEN
                  errmax := abs(yerr^[j]/yscal[j]);
            errmax := errmax/eps;
            IF errmax < 1.0 THEN BEGIN
               x := x+h;
               hdid := h;
               IF i = nuse THEN
                  hnext := h*shrink
               ELSE IF i = nuse-1 THEN
                  hnext := h*grow
               ELSE
                  hnext := (h*nseq[nuse-1])/nseq[i];
               GOTO 99
            END
         END
      END;
      h := 0.25*h;
      FOR i := 1 TO (imax-nuse) DIV 2 DO h := h/2;
      IF x+h = x THEN BEGIN
         writeln('pause in routine BSSTEP');
         writeln('step size underflow');
         readln
      END
   END;
99:
   dispose(yerr);
   dispose(yseq);
   dispose(dysav);
   dispose(ysav)
END;
