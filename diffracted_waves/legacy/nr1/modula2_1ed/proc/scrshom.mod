IMPLEMENTATION MODULE SCRSHOM;

   FROM NRMath   IMPORT RealFunction;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT ReadReal, WriteString, WriteChar, WriteReal, WriteLn, Error;

  PROCEDURE SCRSHO(fx: RealFunction); 
    CONST 
      iscr = 60; (* Number of horizontal and vertical positions in display. *)
      jscr = 21; 
      blank = ' '; 
      zero = '-'; 
      yy = 'l'; 
      xx = '-'; 
      ff = 'x'; 
    VAR 
      jz, j, i: INTEGER; 
      ysml, ybig, x2, x1, x, dyj, dx: REAL; 
      y: ARRAY [1..iscr] OF REAL; 
      scr: ARRAY [1..iscr], [1..jscr] OF CHAR; 
  BEGIN 
    LOOP 
      WriteString('Enter x1 x2 (x1=x2 to stop): '); 
      WriteLn; (* Query for another plot, quit if x1=x2. *)
      ReadReal('x1:', x1); 
      ReadReal('x2:', x2); 
      IF x1 = x2 THEN RETURN; END; 
      FOR j := 1 TO jscr DO (* Fill vertical sides with character 'l'. *)
        scr[1, j] := yy; 
        scr[iscr, j] := yy
      END; 
      FOR i := 2 TO iscr-1 DO (* Fill top, bottom with character '-'. *)
        scr[i, 1] := xx; 
        scr[i, jscr] := xx; 
        FOR j := 2 TO jscr-1 DO (* Fill interior with blanks. *)
          scr[i, j] := blank
        END
      END; 
      dx := (x2-x1)/Float(iscr-1); 
      x := x1; 
      ybig := 0.0; (* Limits will include 0. *)
      ysml := ybig; 
      FOR i := 1 TO iscr DO (* Evaluate the function at equal intervals,
                               finding the largest and smallest values. *)
        y[i] := fx(x); 
        IF y[i] < ysml THEN 
          ysml := y[i]
        END; 
        IF y[i] > ybig THEN 
          ybig := y[i]
        END; 
        x := x+dx
      END; 
      IF ybig = ysml THEN (* Be sure to separate top and bottom. *)
        ybig := ysml+1.0
      END; 
      dyj := Float(jscr-1)/(ybig-ysml); 
      jz := 1-Trunc(ysml*dyj); (* Note which row corresponds to 0. *)
      FOR i := 1 TO iscr DO (* Place an indicator at the height of the function and at 0. *)
        scr[i, jz] := zero; 
        j := 1+Trunc((y[i]-ysml)*dyj); 
        scr[i, j] := ff
      END; 
      WriteChar(' '); 
      WriteReal(ybig, 10, 3); 
      WriteChar(' '); 
      FOR i := 1 TO iscr DO 
        WriteChar(scr[i, jscr])
      END; 
      WriteLn; 
      FOR j := jscr-1 TO 2 BY -1 DO (* Display. *)
        WriteString('            '); 
        FOR i := 1 TO iscr DO 
          WriteChar(scr[i, j])
        END; 
        WriteLn
      END; 
      WriteChar(' '); 
      WriteReal(ysml, 10, 3); 
      WriteChar(' '); 
      FOR i := 1 TO iscr DO 
        WriteChar(scr[i, 1])
      END; 
      WriteLn; 
      WriteString('        '); 
      WriteReal(x1, 10, 3); 
      WriteString('                      '); 
      WriteString('                      '); 
      WriteReal(x2, 10, 3); 
      WriteLn
    END; 
   END SCRSHO; 

END SCRSHOM.
