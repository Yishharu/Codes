> python -m salvus_mesh_lite.interface AxiSEM --basic.model ./prem_iso_smooth_ulvz_30km.bm --basic.period 2 --advanced.elements_per_wavelength 1.5


modify the model bm, discountinity and velocity profile
name 
number of layer
discountinity depth
velocity profile same just for mesh
same for VPV VSV, QKappa, VPH, ETA

python -m mesher_lite .interface AxiSEM --basic.model ~/codes/build/prem_ani****.bm --basic.period 50 --generate

vi param.model     

change the name of bg model

3D layer



inparam.model name the model

vi inparam.model . add 3D feature . under src/volumeric 3D

cyclinder$vs$Ref1D$$




How to Generate Mesh?
Need background model file first (this is 1D depth profile.)

> python -m salvus_mesh_lite.interface AxiSEM --save_yaml=input.yaml

> python -m salvus_mesh_lite.interface --input_file=input.yaml

or 

>python -m salvus_mesh_lite.interface AxiSEM  --basic.model prem_ani --basic.period 10 --generate_plots

or
modify the model bm, discountinity and velocity profile
name 
number of layer
discountinity depth
velocity profile same just for mesh
same for VPV VSV, QKappa, VPH, ETA
> python -m mesh_lite .interface AxiSEM --basic.model ~/codes/build/prem_ani****.bm --basic.period 50 --generate

(Salvus Conda does not work, use pip instead)
## MESHER - generate a Mesh
We could generate mesh based on current model.(like prem_iso) 
>python -m salvus_mesh_lite.interface AxiSEM  --basic.model prem_ani --basic.period 10 --generate_plots

if we want to use our own model, we could redefine background model in bm file, add discountinity layer, modify VPV VSV, QKappa, VPH, ETA and give it another name.

> python -m salvus_mesh_lite.interface AxiSEM --basic.model /raid1/zl382/AxiSEM3D/MESHER/prem_ani****.bm --basic.period 50 --generate_plots

Remember Here only set up 1D model, the high-dimensional model is set up in inparam.model file in input.
## SOLVER - Input file
inparam.model (2.5D model add to BG model)
change to approriate frequency mesh file
Dist, Azi of ULVZ, velocity reduction, Gaussian Height...

## Postprocessing - Input file
nc2ascii.py help to make axisem3d_synthetics.nc to ascii file.
in ascii file, time RTZ component.

## Postprocessing - Input file
For Saluvs Mesh, bm file poly parameter?  Find models_1D.py in Salvus Mesh...
