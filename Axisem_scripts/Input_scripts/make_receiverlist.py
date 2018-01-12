


f=open('receivers_RF_oneline_601.dat','wb')
f.write('601\n')
for i in range(601):
    f.write(str(90)+'\t'+str(i*.25+30.)+ '\n')
