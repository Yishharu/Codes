(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
VAR
   LinminNcom: integer;
   LinminPcom,LinminXicom: RealArrayNP;
FUNCTION fnc(VAR x: RealArrayNP): real;
ENDENVIRON *)
PROCEDURE linmin(VAR p,xi: RealArrayNP;
                        n: integer;
                 VAR fret: real);
CONST
   tol = 1.0e-4;
VAR
   j: integer;
   xx,xmin,fx,fb,fa,bx,ax: real;

BEGIN
   LinminNcom := n;
   FOR j := 1 TO n DO BEGIN
      LinminPcom[j] := p[j];
      LinminXicom[j] := xi[j]
   END;
   ax := 0.0;
   xx := 1.0;
   mnbrak(ax,xx,bx,fa,fx,fb);
   fret := brent(ax,xx,bx,tol,xmin);
   FOR j := 1 TO n DO BEGIN
      xi[j] := xmin*xi[j];
      p[j] := p[j]+xi[j]
   END
END;
