Location = 'Iceland'
Event = '20151026'

dir = '/raid3/zl382/Data/'+Location+'/'+Event + '/'

# Loop through seismograms
count = 0
location_dict = np.load(dir+'location.npy').item()

for s, (s_name, (dist,azi)) in enumerate(location_dict.items()):