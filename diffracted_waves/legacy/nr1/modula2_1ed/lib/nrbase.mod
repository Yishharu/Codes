IMPLEMENTATION MODULE NRBase;

   PROCEDURE Equal(line, text: ARRAY OF CHAR): BOOLEAN;
      VAR
         i,
         highLine,
         highText: INTEGER;
         result:   BOOLEAN;
   BEGIN
      highLine := HIGH(line);
      highText := HIGH(text);
      IF line[highLine] = 0C THEN DEC(highLine) END;
      IF text[highText] = 0C THEN DEC(highText) END;
      IF highLine = highText THEN
         result := TRUE;
         i := 0;
         REPEAT
            IF line[i] # text[i] THEN result := FALSE END;
            INC(i);
         UNTIL ((result = FALSE) OR (i > highLine));
      ELSE
         result := FALSE
      END;
      RETURN result;
   END Equal;
   
END NRBase.
