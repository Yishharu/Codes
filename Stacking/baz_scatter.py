import glob

import numpy as np
from scipy import stats

main_folder = '/home/zl382/Pictures/BeamForming/main_1-5s/'
pc_folder = '/home/zl382/Pictures/BeamForming/pc_1-5s/'

# plot main phase baz
for array in glob.glob(main_folder+'*'):
    baz_list = []
    for baz_sequence in glob.glob(array+'/*_baz.npy'):
        baz_list.append(np.load(baz_sequence))
    
    baz = stats.mode(baz_list)
    plt.scatter()