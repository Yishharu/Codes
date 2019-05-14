import glob
import os
from os.path import splitext

import numpy as np
from scipy import stats

import matplotlib.pyplot as plt

coherence_value = 0.5
data_folder = '/raid1/zl382/Pictures/BeamForming/traveltime_1-5s/'

sta_location = np.load('/raid1/zl382/Data/Hawaii/20100320/STALOCATION.npy').item()
# plot main phase baz
center_azi_list1 = []
center_azi_list2 = []
baz_degree_list = []
T1_list = []
Azi1_list = []
T2_list = []
Azi2_list = []
T1_error_list = []
Azi1_error_list = []
T2_error_list = []
Azi2_error_list = []

center_azi_list_all = []
BACKAZIMUTH_list = []

for array in glob.glob(data_folder+'*_traveltime.npy'):
    sname = splitext(os.path.split(array)[1])[0][:-11:]
    print(sname)
    if not sname in sta_location.keys():
        continue
    center_azi = sta_location[sname][1]
    center_backazimuth = sta_location[sname][4]

    center_azi_list_all.append(center_azi)
    BACKAZIMUTH_list.append(center_backazimuth)

    T1 = np.load(array)[0]
    Azi1 = np.load(array)[1]
    T2 = np.load(array)[2]
    Azi2 = np.load(array)[3]
    T1_error = np.array([T1-np.load(array)[4], np.load(array)[5]-T1])
    Azi1_error = np.array([Azi1-np.load(array)[6], np.load(array)[7]-Azi1])
    T2_error = np.array([T2-np.load(array)[8], np.load(array)[9]-T2])
    Azi2_error = np.array([Azi2-np.load(array)[10], np.load(array)[11]-Azi2])
    # if the signal is acceptable
    # for T1, Azi1, time error bar not too wide, not at the edge of 25, 
    # if (T1_error<10).all() \
    # and (T1_error>4).all() \
    # and T1<24 and Azi1>60 and Azi1<140 \
    # and (Azi1_error<20).all() and  (Azi1_error>5).all() :
    if (T1_error<10).all() and  (T1_error>0.5).all() and Azi1>75 and Azi1<115\
        and (Azi1_error<5).all() and  (Azi1_error>1).all():
        center_azi_list1.append(center_azi)
        T1_list.append(T1)
        T1_error_list.append(T1_error)
        Azi1_list.append(Azi1-center_backazimuth)
        Azi1_error_list.append(Azi1_error)

    # for T2, Azi2, 
    if (T2_error<10).all() and  (T2_error>0.5).all() and Azi2>75 and Azi2<115\
        and (Azi2_error<5).all() and  (Azi2_error>1).all():
        center_azi_list2.append(center_azi)
        T2_list.append(T2)
        T2_error_list.append(T2_error)
        Azi2_list.append(Azi2-center_backazimuth)
        Azi2_error_list.append(Azi2_error)

center_azi_list1 = np.array(center_azi_list1)
T1_list = np.array(T1_list)
T1_error_list = np.array(T1_error_list).transpose()
Azi1_list = np.array(Azi1_list)
Azi1_error_list = np.array(Azi1_error_list).transpose()
print('T1 error bar min, max: ', T1_error_list.min(), T1_error_list.max())
print('Azi1 error bar min, max: ', Azi1_error_list.min(), Azi1_error_list.max())

center_azi_list2 = np.array(center_azi_list2)
T2_list = np.array(T2_list)
T2_error_list = np.array(T2_error_list).transpose()
Azi2_list = np.array(Azi2_list)
Azi2_error_list = np.array(Azi2_error_list).transpose()

print('T2 error bar min, max: ', T2_error_list.min(), T2_error_list.max())
print('Azi2 error bar min, max: ', Azi2_error_list.min(), Azi2_error_list.max())

center_azi_list_all = np.array(center_azi_list_all)
BACKAZIMUTH_list = np.array(BACKAZIMUTH_list)

# plt.title(data_folder)
plt.ylabel('Traveltime (s)', fontsize=15)
plt.xlabel('Station Azimuth (deg)', fontsize=15)
plt.scatter(center_azi_list1,T1_list,c='b',marker='o',label='Main arrival')
plt.errorbar(center_azi_list1, T1_list, yerr=T1_error_list, c='b',marker='o', fmt='o')
plt.scatter(center_azi_list2,T2_list,c='r',marker='^',label='Post Cursor')
plt.errorbar(center_azi_list2, T2_list, yerr=T2_error_list, c='r',marker='^', fmt='o')

plt.xlim([39,63])
plt.ylim([-20,100])
plt.legend()


plt.figure()
# plt.title(data_folder)
# plt.scatter(center_azi_list_all,BACKAZIMUTH_list,c='y',marker='P',label='Reference',zorder=10,alpha=0.3)

plt.scatter(center_azi_list1,Azi1_list,c='b',marker='o',label='Main arrival')
plt.errorbar(center_azi_list1, Azi1_list, yerr=Azi1_error_list, c='b',marker='o', fmt='o')
plt.scatter(center_azi_list2,Azi2_list,c='r',marker='^',label='Post Cursor')
plt.errorbar(center_azi_list2, Azi2_list, yerr=Azi2_error_list, c='r',marker='^', fmt='o')
plt.legend(loc=1)

plt.xlim([39,63])
plt.ylim([-30,30])
# plt.ylim([240,320])
plt.hlines(0,0,100, linestyle='--',color='y',alpha=0.8)
plt.ylabel('BackAzimuth Deviation (deg)', fontsize=15)
plt.xlabel('Station Azimuth (deg)', fontsize=15)
plt.show()


