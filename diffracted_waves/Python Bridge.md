# Python Bridge to fortran

>f2py3 -m bessj0 -h bessj0.pyf cal.f90 nrtype.f90 nrutil.f90 bessj0.f90 --overwrite-signature

edit the .pyf interface

and then make it python module
>f2py3 -c bessj0.pyf cal.f90 bessj0.f90 nrtype.f90 nrutil.f90

In python3, you could also see the signature file via 
>print (module_name._ _doc_ _)
