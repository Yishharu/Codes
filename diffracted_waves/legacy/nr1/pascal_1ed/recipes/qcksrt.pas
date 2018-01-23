(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE qcksrt(n: integer;
           VAR arr: RealArrayNP);
LABEL 10,20,99;
CONST
   m = 7;
   nstack = 50;
VAR
   i,j,k,l,ir,jstack: integer;
   a,temp: real;
   istack: ARRAY[1..nstack] OF integer;
BEGIN
   jstack := 0;
   l := 1;
   ir := n;
   WHILE true DO BEGIN
      IF ir-l < m THEN BEGIN
         FOR j := l+1 TO ir DO BEGIN
            a := arr[j];
            FOR i := j-1 DOWNTO 1 DO BEGIN
               IF arr[i] <= a THEN GOTO 10;
               arr[i+1] := arr[i]
            END;
            i := 0;
10:         arr[i+1] := a
         END;
         IF jstack = 0 THEN GOTO 99;
         ir := istack[jstack];
         l := istack[jstack-1];
         jstack := jstack-2
      END
      ELSE BEGIN
         k := (l+ir) DIV 2;
         temp := arr[k];
         arr[k] := arr[l+1];
         arr[l+1] := temp;
         IF arr[l+1] > arr[ir] THEN BEGIN
            temp := arr[l+1];
            arr[l+1] := arr[ir];
            arr[ir] := temp
         END;
         IF arr[l] > arr[ir] THEN BEGIN
            temp := arr[l];
            arr[l] := arr[ir];
            arr[ir] := temp
         END;
         IF arr[l+1] > arr[l] THEN BEGIN
            temp := arr[l+1];
            arr[l+1] := arr[l];
            arr[l] := temp
         END;
         i := l+1;
         j := ir;
         a := arr[l];
         WHILE true DO BEGIN
            REPEAT
               i := i+1;
            UNTIL arr[i] >= a;
            REPEAT
               j := j-1;
            UNTIL arr[j] <= a;
            IF j < i THEN GOTO 20;
            temp := arr[i];
            arr[i] := arr[j];
            arr[j] := temp
         END;
20:      arr[l] := arr[j];
         arr[j] := a;
         jstack := jstack+2;
         IF jstack > nstack THEN BEGIN
            writeln('pause in QCKSRT - NSTACK must be made larger');
            readln
         END;
         IF ir-i+1 >= j-l THEN BEGIN
            istack[jstack] := ir;
            istack[jstack-1] := i;
            ir := j-1
         END
         ELSE BEGIN
            istack[jstack] := j-1;
            istack[jstack-1] := l;
            l := i
         END
      END
   END;
99:
END;
