python -m salvus_mesher_lite.interface AxiSEM  --basic.model prem_ani --basic.period 10 --generate_plots

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

