TYPE
   double=real;
   string10=string[10];
PROCEDURE NROpen(VAR infile: text;
                   filename: string10);
BEGIN
   assign(infile,filename);
   reset(infile)
END;
