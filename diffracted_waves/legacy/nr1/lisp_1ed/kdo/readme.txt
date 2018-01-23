
                       NUMERICAL RECIPES IN COMMON LISP
                                       
  (Ken Olum Variant)
  
   The code in this directory is a slightly rewritten version of the Lisp
   Numerical Recipes code translated by Kevin Broughan from the first
   edition of Numerical Recipes in Fortran. It is based on a slightly
   earlier version of the Broughan code than that which appears elsewhere
   on this CDROM. Because the needs of Lisp users vary widely, it was
   felt that a slightly different customization of the original Broughan
   files might be additionally useful to some users.
   
   The files in this directory are as follows:
     * contents.txt -- A list of which routines are implemented and which
       file they are in.
     * header.l -- A few utility functions that are used in many
       different places in the code.
     * nr01.l | nr02.l | nr03.l | nr04.l | nr05.l | nr06.l | nr07.l |
       nr08.l | nr09.l | nr10.l | nr11.l | nr12.l | nr13.l | nr14.l |
       nr15.l | nr16.l | nr17.l -- The Numerical Recipes code, organized
       by chapters as in the first edition of Numerical Recipes in
       Fortran.
       
   I have made the following changes for use in Common Lisp instead of
   the Senac system:
   
     * Some utility functions are defined in the header file.
     * Everything is in Common Lisp without implementation extensions or
       dependencies.
     * User-defined functions accept and return arrays, rather than
       converting things to and from list structures.
       
   Only some of the routines in this code have been tested. Thus it is
   quite possible that I have introduced bugs in my modifications of some
   of the routines. If you suspect this you can compare these routines
   with the ones in the Broughan/Senac directory. The routines most
   likely to be affected are those in the FFT chapter which deal with
   converting between real and complex arrays, those that call
   user-supplied functions, and the function MEDFIT.
   
   The function MEDFIT does not work properly. I believe the mistake was
   in the original code before translation. You might want to make a new
   translation of the rewritten version of ROFUNC that appears in the
   second edition of the books.
   
   Feel free to contact me at the email address below if you have
   questions about this code, if you discover bugs, or if you would like
   to make further improvements.
   
   Ken Olum
   kdo@mit.edu or kdo@ctp.mit.edu
   April 30, 1996
