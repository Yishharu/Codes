import sys
import numpy as np
import matplotlib.pyplot as plt

import matplotlib.tri as tri

dir = '/raid1/zl382/HPC_axisem3d_run/3s/S40RTS+ZD40_3s/output/plots/'
model_path = dir + 'vs_vertex_18_-162_116.87_3D.txt'
ndata = 4

gll = [-1.000000000000, -0.654653670708, 0.000000000000, 0.654653670708, 1.000000000000]
def gllpntCrds(nodeCrds):
    gllpntCrds = []
    for ipnt in range(0,25):
        jpol = ipnt % 5
        ipol = ipnt // 5
        xii = gll[ipol]
        eta = gll[jpol]
        xiip = 1 + xii
        xiim = 1 - xii
        etap = 1 + eta
        etam = 1 - eta
        shp1 = xiim*etam /4
        shp2 = xiip*etam /4
        shp3 = xiip*etap /4
        shp4 = xiim*etap /4 
        gllpntCrds.append([
            nodeCrds[0,0]*shp1 + nodeCrds[1,0]*shp2 + nodeCrds[2, 0]*shp3 + nodeCrds[3, 0]*shp4,
            nodeCrds[0,1]*shp1 + nodeCrds[1,1]*shp2 + nodeCrds[2,1]*shp3 + nodeCrds[3,1]*shp4
            ])
    return np.array(gllpntCrds)

def progress(count, total, status=''):
    bar_len = 60
    filled_len = int(round(bar_len * count / float(total)))

    percents = round(100.0 * count / float(total), 1)
    bar = '=' * filled_len + '-' * (bar_len - filled_len)

    sys.stdout.write('[%s] %s%s ...%s\r' % (bar, percents, '%', status))
    sys.stdout.flush()  # As suggested by Rom Ruben (see: http://stackoverflow.com/questions/3173320/text-progress-bar-in-the-console/27871113#comment50529068_27871113)


# VgllpntCrds = np.vectorize(gllpntCrds)


con = np.loadtxt(dir+'mesh_connectivity.txt', dtype='int16')
print('MESH CONNECTIVITY DONE !')
crd = np.loadtxt(dir+'mesh_coordinates.txt', dtype='float64')
print('MESH COORDINATES DONE !')

nele = len(con)
eleCrd = np.stack((crd[:,0][con],crd[:,1][con]),axis=-1)

dataPar = np.loadtxt(model_path, dtype='float64')
print('DATA PARAMETER DONE !')

if ndata == 1: 
    dataCrds = np.mean(eleCrd,axis=1)   

elif ndata == 4:
    dataCrds = eleCrd

elif ndata == 25:
    dataCrds = []
    for index, nodeCrds in enumerate(eleCrd):
        progress(index, nele, status='Doing very long job')
        dataCrds.append(gllpntCrds(nodeCrds)) 
    dataCrds = np.array(dataCrds)

crdsPlot = np.reshape(dataCrds, (nele*ndata,2))
dataPlot = dataPar.flatten()

# savename = dir + str(ndata) + '-model.txt'
# savedata = np.concatenate((crdsPlot, dataPlot),axis=1)
# np.savetxt(savename, savedata, fmt='%12f %12f %12f')

x = crdsPlot[:,0]
y = crdsPlot[:,1]

triang = tri.Triangulation(x, y)

# Mask off unwanted triangles.
min_radius = 3483000
max_radius = 6371000

# triang.set_mask(np.hypot(x[triang.triangles].mean(axis=1),
#                                  y[triang.triangles].mean(axis=1))
#                         < min_radius)

# triang.set_mask(np.any([np.hypot(x[triang.triangles].min(axis=1),
#                                  y[triang.triangles].min(axis=1))
#                         < min_radius,
#                         np.hypot(x[triang.triangles].max(axis=1),
#                                  y[triang.triangles].max(axis=1))
#                         > max_radius], axis = 0))  

fig, ax = plt.subplots()
# ax.set_aspect(0.5)
tpc = ax.tripcolor(triang, dataPlot)
# tpc = ax.tricontourf(triang, dataPlot)

fig.colorbar(tpc)

plt.show()

# # grid_x, grid_y = np.mgrid[xi.min():xi.max():10,yi.min():yi.max():10]
# # grid_value = griddata(dataCrds,dataPlot,(grid_x,grid_y),method='nearest')

# plt.scatter(xi,yi,c=dataPlot,marker='s',alpha=0.5)

# plt.colorbar()
# plt.show()