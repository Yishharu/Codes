(* BEGINENVIRON

FUNCTION fx(x: real): real;
ENDENVIRON *)
PROCEDURE scrsho;
LABEL 99;
CONST
   iscr = 60;
   jscr = 21;
   blank = ' ';
   zero = '-';
   yy = 'l';
   xx = '-';
   ff = 'x';
VAR
   jz,j,i: integer;
   ysml,ybig,x2,x1,x,dyj,dx: real;
   y: ARRAY [1..iscr] OF real;
   scr: ARRAY [1..iscr,1..jscr] OF char;
BEGIN
   WHILE true DO BEGIN
      writeln('Enter x1 x2 (x1=x2 to stop): ');
      readln(x1,x2);
      IF x1 = x2 THEN GOTO 99;
      FOR j := 1 TO jscr DO BEGIN
         scr[1,j] := yy;
         scr[iscr,j] := yy
      END;
      FOR i := 2 TO iscr-1 DO BEGIN
         scr[i,1] := xx;
         scr[i,jscr] := xx;
         FOR j := 2 TO jscr-1 DO
            scr[i,j] := blank
      END;
      dx := (x2-x1)/(iscr-1);
      x := x1;
      ybig := 0.0;
      ysml := ybig;
      FOR i := 1 TO iscr DO BEGIN
         y[i] := fx(x);
         IF y[i] < ysml THEN ysml := y[i];
         IF y[i] > ybig THEN ybig := y[i];
         x := x+dx
      END;
      IF ybig = ysml THEN ybig := ysml+1.0;
      dyj := (jscr-1)/(ybig-ysml);
      jz := 1-trunc(ysml*dyj);
      FOR i := 1 TO iscr DO BEGIN
         scr[i,jz] := zero;
         j := 1+trunc((y[i]-ysml)*dyj);
         scr[i,j] := ff
      END;
      write(' ',ybig:10:3,' ');
      FOR i := 1 TO iscr DO write(scr[i,jscr]);
      writeln;
      FOR j := jscr-1 DOWNTO 2 DO BEGIN
         write(' ':12);
         FOR i := 1 TO iscr DO write(scr[i,j]);
         writeln
      END;
      write(' ',ysml:10:3,' ');
      FOR i := 1 TO iscr DO write(scr[i,1]);
      writeln;
      writeln(' ':8,x1:10:3,' ':44,x2:10:3)
   END;
99:
END;
