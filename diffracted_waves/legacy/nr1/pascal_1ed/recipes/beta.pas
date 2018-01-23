FUNCTION beta(z,w: real): real;
BEGIN
   beta := exp(gammln(z)+gammln(w)-gammln(z+w))
END;
