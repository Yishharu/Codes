FUNCTION bico(n,k: integer): real;
BEGIN
   bico := round(exp(factln(n)-factln(k)-factln(n-k)));
END;
