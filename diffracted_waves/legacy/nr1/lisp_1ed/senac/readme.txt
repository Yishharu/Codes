
   [IMAGE]
   
                       NUMERICAL RECIPES IN COMMON LISP
                                       
  (Broughan/Senac Version)
  
   The code in this directory is organized into files with each file
   corresponding to a single chapter in Numerical Recipes in Fortran,
   First Edition. The first chapter contains support routines which may
   need to be loaded into Lisp before the Numerical Recipes Routines are
   called. If a function or functions are to be compiled the macros in
   nr00.l must be loaded into the compiler first.
   
   In the main, the subroutines have been translated into Lisp defun's
   which may be called like any other Lisp function. A number of
   subprogrammes have been translated to defvar's: these are the ones
   where state is to be preserved between different invocations. To call
   these use (funcall name arg1 arg2 ...) where name is the symbol
   following the defvar (normally the name of the corresponding Numerical
   Recipes routine).
   
   These functions have been tested with a range of implementations of
   Common Lisp. They have been incorporated into the
   symbolic-numeric-graphic problem solving software system Senac. This
   has an easy to use top level function for each Numerical Recipes
   function with argument datatype checking. For details concerning Senac
   contact kab@waikato.ac.nz.
   
   Links to the individual Lisp files, in this directory:
   
   nr00.l | nr01.l | nr02.l | nr03.l | nr04.l | nr05.l | nr06.l | nr07.l
   | nr08.l | nr09.l | nr10.l | nr11.l | nr12.l | nr13.l | nr14.l |
   nr15.l | nr16.l | nr17.l |
   
   Links to related documentation files (PostScript) from the SENPACK
   manual, in this directory:
   
   sp00.ps | sp01.ps | sp02.ps | sp03.ps | sp04.ps | sp05.ps | sp06.ps |
   sp07.ps | sp08.ps | sp09.ps | sp10.ps | sp11.ps | sp12.ps | sp13.ps |
   sp14.ps | sp15.ps | sp16.ps | sp17.ps |
   
   Kevin Broughan
   Hamilton, New Zealand
   24 April 1996
