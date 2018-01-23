IMPLEMENTATION MODULE NRIO;

   FROM NRSystem IMPORT Allocate, Deallocate, LongInt;
   FROM SYSTEM   IMPORT BYTE, ADDRESS, TSIZE;

   IMPORT FIO;
   IMPORT IO;

   CONST
      CR = 15C;
      EOL = 15C;
      ResultsX = 5;
      ResultsY = 25;
      ResultsW = 600;
      ResultsH = 400;
      Title = "Numerical Recipes in Modula-2";

   TYPE
      File = POINTER TO FIO.File; (* POINTER TO TextFile;*)
   VAR
      ch:       CHAR;
      IOerr: CARDINAL;

   PROCEDURE Open(    fileName: ARRAY OF CHAR;
                  VAR file:     File);
   BEGIN
      Allocate(file, TSIZE(FIO.File));
      IF file # NIL THEN
         file^ := FIO.Open(fileName);
         IOerr := FIO.IOresult();
         IF (IOerr <> 0) THEN
            Error('Open', "Problems with opening the file."); HALT;
         END;
      ELSE
         Error('Open', "Problems with opening the file."); HALT;
      END;
   END Open;

   PROCEDURE Close(VAR file: File);
   BEGIN
      FIO.Close(file^);
      Deallocate(file);
   END Close;

   PROCEDURE GetLine(    file: File;
                      VAR line: ARRAY OF CHAR);
      VAR
         i, high: INTEGER;
         ch: CHAR;
   BEGIN
      i := -1;
      high := HIGH(line);
      REPEAT
         INC(i);
         line[i] := FIO.RdChar(file^);
      UNTIL ((line[i]=EOL) OR (i=high) OR EOF(file));
      IF NOT EOF(file) THEN
         IF (line[i]#EOL) THEN
	         REPEAT
	            ch := FIO.RdChar(file^);
   	      UNTIL ch=EOL;
	      ELSE
	         line[i] := 0C;
         END;
         ch := FIO.RdChar(file^);
      END;
   END GetLine;

   PROCEDURE GetWord(    file: File;
                     VAR word: ARRAY OF CHAR);
      VAR
         i, high: INTEGER;
         ch: CHAR;
   BEGIN
      high := HIGH(word);
      REPEAT
         word[0] := FIO.RdChar(file^);
      UNTIL ( (word[0] # EOL) AND (word[0] # " ")) ;
      i := 0;
      REPEAT
         INC(i);
         word[i] := FIO.RdChar(file^);
      UNTIL ((word[i]=EOL) OR (word[i] = " ") OR (i=high));
      IF (word[i]#EOL) AND (word[i]#" ") THEN
	      REPEAT
	         ch := FIO.RdChar(file^);
	      UNTIL ((ch=EOL) OR (ch = " "));
	   ELSE
	      word[i] := 0C;
      END;
   END GetWord;

   PROCEDURE GetByte(f: File; VAR b: BYTE);
      VAR i: INTEGER;
   BEGIN
     GetInt(f, i);
     b := VAL(BYTE, i);
   END GetByte;

   PROCEDURE GetChars(    file: File;
                          length: INTEGER;
                      VAR word: ARRAY OF CHAR);
      VAR
         i, high: INTEGER;
         ch: CHAR;
   BEGIN
      i := 0;
      high := HIGH(word);
      WHILE (i <= length-1) AND (i <= high) DO
         word[i] := FIO.RdChar(file^);
         INC(i);
      END;
   END GetChars;

   PROCEDURE GetEOL(file: File);
      VAR ch: CHAR;
   BEGIN
      REPEAT
         ch := FIO.RdChar(file^);
      UNTIL (EOF(file) OR (ch = EOL));
      IF ch = EOL THEN ch := FIO.RdChar(file^); END;
   END GetEOL;

   PROCEDURE EOF(file: File): BOOLEAN;
   BEGIN
      RETURN FIO.EOF;
   END EOF;

   PROCEDURE ReadLn;
   BEGIN
      REPEAT
         ch := IO.RdChar();
      UNTIL ch=CR;
   END ReadLn;

   PROCEDURE GetInt(    file: File;
                     VAR x:    INTEGER);
      VAR pos: LONGCARD;
   BEGIN
      x := FIO.RdInt(file^);
      pos := FIO.GetPos(file^);
      FIO.Seek(file^, pos-1);
   END GetInt;

   PROCEDURE GetLongInt(    file: File;
                        VAR x:    LongInt);
      VAR pos: LONGCARD;
   BEGIN
      x := FIO.RdLngInt(file^);
      pos := FIO.GetPos(file^);
      FIO.Seek(file^, pos-1);
   END GetLongInt;

   PROCEDURE GetReal(    file: File;
                      VAR x:    REAL);
      VAR pos: LONGCARD;
   BEGIN
      x := FIO.RdReal(file^);
      pos := FIO.GetPos(file^);
      FIO.Seek(file^, pos-1);
   END GetReal;

   PROCEDURE ReadInt(    label: ARRAY OF CHAR;
                     VAR x:     INTEGER);
   BEGIN
      IO.WrStr(label);
      x := IO.RdInt();
   END ReadInt;

   PROCEDURE ReadIntegers(    label: ARRAY OF CHAR;
                          VAR x,
                              y,
                              z:     INTEGER);
   BEGIN
      IO.WrStr(label);
      IO.WrLn;
      x := IO.RdInt();
      y := IO.RdInt();
      z := IO.RdInt();
   END ReadIntegers;

   PROCEDURE ReadReal(    label: ARRAY OF CHAR;
                      VAR x:     REAL);
   BEGIN
      IO.WrStr(label);
      x := IO.RdReal();
   END ReadReal;

   PROCEDURE WriteString(string: ARRAY OF CHAR);
   BEGIN
      IO.WrStr(string);
   END  WriteString;

   PROCEDURE WriteChar(ch: CHAR);
   BEGIN
      IO.WrChar(ch);
   END  WriteChar;

   PROCEDURE WriteText(text:   ARRAY OF CHAR;
                       length: INTEGER);
      VAR i, high: INTEGER;
   BEGIN
      i := 0;
      high := HIGH(text);
      WHILE (i <= high) AND (text[i] # 0C) DO
         WriteChar(text[i]);
         INC(i);
      END;
      WHILE length > i DO
         WriteChar(" ");
         INC(i);
      END;
   END  WriteText;

   PROCEDURE WriteInt(x: INTEGER;
                      n: INTEGER);
   BEGIN
      IO.WrInt(x, n);
   END WriteInt;

   PROCEDURE WriteLongInt(value:  LongInt;
                          length: INTEGER);
   BEGIN
      IO.WrLngInt(value, length);
   END WriteLongInt;

   PROCEDURE WriteReal(x: REAL;
                       n,
                       k: INTEGER);
   BEGIN
      IF k > 0 THEN
         IO.WrFixReal(x, k, n);
      ELSE
         IO.WrReal(x, 6, n);
      END;
   END WriteReal;

   PROCEDURE WriteLongReal(x: LongReal;
                           n, k: INTEGER);
   BEGIN
      IF k > 0 THEN
         IO.WrFixLngReal(x, k, n);
      ELSE
         IO.WrLngReal(x, 6, n);
      END;
   END WriteLongReal;

   PROCEDURE WriteLn;
   BEGIN
      IO.WrLn;
   END WriteLn;

   PROCEDURE Error(routineName: ARRAY OF CHAR;
                   message:     ARRAY OF CHAR);
   BEGIN
      WriteString("Error in routine "); WriteString(routineName);
      WriteString("."); WriteLn;
      WriteString(message);  WriteLn;
      WriteString("Type CR to continue!");
      ReadLn;
      HALT;
   END Error;

BEGIN
END NRIO.
