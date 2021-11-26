## MC Kernel Workflow
Before reading this document about how to use MC Kernel there are a few things that you must
bear in mind whenever you use MC Kernel:
1. MC Kernel hates you.
2. MC Kernel doesn’t want you to succeed.
3. You can beat MC Kernel.

Now that that is out the way, getting kernels with MC Kernel is a three step process:
1. Make wavefields using AxiSEM.
2. Make kernels using MC Kernel.
3. Plot those kernels.

# Making wavefields with AxiSEM
Both a forward and backward simulation should be used. The forward simulation should be a full
moment simulation. The backward simulation is a force simulation in which the solver uses -dt.
What follows is a summary of how I made useable wavefields.
1. Make the mesh using the MESHER and move it to the SOLVER.
2. Go to the solver and set up the simulation.
 - Define the source in inparam_source and CMTSOLUTION. MC Kernel requires that
your source is at the north pole.
 - Define the stations in STATIONS (I don’t know if this actually matters but I just used a
station every 1 degree along a meridian).
 - Set the mesh in inparam_basic.
 - There are some requirements for some options in inparam_advanced but these are
summarised in the AxiSEM manual. (in inparam_advanced file shoudl set KERNEL_RMIN to 0)

3. Run a forward simulation. In inparam_basic the SIMULATION_TYPE parameter should be set
to moment.
4. Run a backward simulation. In inparam_basic the SIMULATION_TYPE parameter should be
set to force.
5. Run the field transform procedure. Change the parameters in and use the script
submit_field_transform.csh for this. Running this locally is too big a job for the login nodes,
so this script runs it through SLURM.
6. The wavefield output then needs moving to MC Kernel. For my setup on the HPC the script
move_kernel.py in the SOLVER directory does this. Parameters should be changed within the
script.

# Calculating the Kernel
MC Kernel is actually not too hard to use when you know how, but the fact is completely
undocumented and counterintuitive does not make learning how to use it very easy.

The input options can be specified when submitting the job. This is done according to the options
specified in submit.py although this needs to be submitted in a virtual environment and is done
using ./slurm_submit.sh/

There are several important files for running MC Kernel.

a) receiver.dat contains the details of the receivers and is well commented. This is where the
time window (and therefore phase choice) is set.

b) filters.dat contains the filters that can be applied. Details on the filters that can be used can
be found in src/filtering.f90.

c) CMTSOLUTION should match the one used for the AxiSEM wavefield simulation.

d) The STF file can be changed but editing the time series in the default file stf_20s.dat. The
easiest way to get a shorter period STF is by changing the sample rate in the default file.

e) The mesh file can be changed, or a default mesh can be used. Meshes should be stored in
./Meshes. It is possible to create a mesh using a meshing software or just by manipulating an
example text file.

Once all is set up then submit the job with ./slurm_submit.sh.

# Viewing the Kernel
Paraview sucks, and we can do much better than that with very simple scripts. I have written some
basic python scripts to visualise various elements of the kernel.

a) plot_filters.py

b) plot_seismograms.py

c) plot_kernels.py
