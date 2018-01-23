(* BEGINENVIRON
CONST
   np =
   mp =
   nn =
TYPE
   RealArrayNN = ARRAY [1..nn] OF real;
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
ENDENVIRON *)
PROCEDURE splin2(VAR x1a,x2a: RealArrayNN;
                  VAR ya,y2a: RealArrayMPbyNP;
                         m,n: integer;
                       x1,x2: real;
                       VAR y: real);
VAR
   k,j: integer;
   ytmp,y2tmp,yytmp: ^RealArrayNN;
BEGIN
   new(ytmp);
   new(y2tmp);
   new(yytmp);
   FOR j := 1 TO m DO BEGIN
      FOR k := 1 TO n DO BEGIN
         ytmp^[k] := ya[j,k];
         y2tmp^[k] := y2a[j,k]
      END;
      splint(x2a,ytmp^,y2tmp^,n,x2,yytmp^[j])
   END;
   spline(x1a,yytmp^,m,1.0e30,1.0e30,y2tmp^);
   splint(x1a,yytmp^,y2tmp^,m,x1,y);
   dispose(yytmp);
   dispose(y2tmp);
   dispose(ytmp)
END;
