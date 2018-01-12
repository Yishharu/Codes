#!/usr/bin python3
import fileinput

f = open('ULVZ5km.txt','w') # new model

search_radius = ['3485000.','3480000.']
#search_radius = ['3482000.','3480000']
count = 0

rho_var = 1 + 0.1
vpv_var = 1 - 0.1
vsv_var = 1 - 0.2
qka_var = 1
qmu_var = 1
vph_var = 1 - 0.1
vsh_var = 1 - 0.2
eta_var = 1


# Please input the filename after the script if fileinput.input()
for line in fileinput.input('external_model.TEMPLATE'):
 #   line_unmodified = line
    change_value = False
    for s in search_radius:
        if (s in line) and (s == str.split(line)[0]) and (count<len(search_radius)):
            change_value = True
            count = count + 1
######################################################          
#        try:
#            if (float(search_radius[0]) > float(str.split(line)[0])) and (float(search_radius[0]) < float(str.split(line)[0])+5000) and (count<len(search_radius)):
#                count = count + 1
#                line_unmodified = line
#                parameters = str.split(line)
#  #              radius = float(parameters[0])
#                rho = 5563.95 - (5566.46-5563.95)*2000./5000.
#                vpv = 13716.62 - (13716.62-13715.39)*2000./5000. 
#                vsv = 7264.65 - (7264.65-7264.70)*2000./5000. 
#                #          qka = float(parameters[4]) * qka_var
#                #          qmu = float(parameters[5]) * qmu_var
#                vph = 13716.62 - (13716.62-13715.39)*2000./5000.
#                vsh = 7264.65 - (7264.65-7264.70)*2000./5000.
#                #          eta = float(parameters[8]) * eta_var#
#                line = line.replace(parameters[0], search_radius[0])
#                line1 = line
#                
#                line = line.replace(parameters[1], '{:.2f}'.format(rho))
#                line = line.replace(parameters[2], '{:.2f}'.format(vpv))
#                line = line.replace(parameters[3], '{:.2f}'.format(vsv))
#                line = line.replace(parameters[6], '{:.1f}'.format(vph))
#                line = line.replace(parameters[7], '{:.1f}'.format(vsh))
                
#                line1 = line1.replace(parameters[1], '{:.2f}'.format(rho* rho_var))
#                line1 = line1.replace(parameters[2], '{:.2f}'.format(vpv* vpv_var))
#                line1 = line1.replace(parameters[3], '{:.2f}'.format(vsv* vsv_var))
#                line1 = line1.replace(parameters[6], '{:.1f}'.format(vph* vph_var))
#                line1 = line1.replace(parameters[7], '{:.1f}'.format(vsh* vsh_var))
#                line_modified = line+'#          Discontinuity, depth:    ' + '2 km\n'+line1
#                f.write(line_modified)
#        except:
#            change_value = False
############################################################
    if (change_value):        
        line_unmodified = line
        parameters = str.split(line)
        radius = float(parameters[0])
        rho = float(parameters[1]) * rho_var
        vpv = float(parameters[2]) * vpv_var
        vsv = float(parameters[3]) * vsv_var
        qka = float(parameters[4]) * qka_var
        qmu = float(parameters[5]) * qmu_var
        vph = float(parameters[6]) * vph_var
        vsh = float(parameters[7]) * vsh_var
        eta = float(parameters[8]) * eta_var
        line = line.replace(parameters[1], '{:.2f}'.format(rho))
        line = line.replace(parameters[2], '{:.2f}'.format(vpv))
        line = line.replace(parameters[3], '{:.2f}'.format(vsv))
        if (search_radius[0] == str.split(line)[0]): # add the Discontinuity comment
            line = line_unmodified + '#          Discontinuity, depth:    ' + str(6371-radius/1000.0) + ' km\n' + line

        line_modified = line
                # print (line)
        f.write(line)
            
    else:
        # print (line)
        f.write(line)


print('Previous lines: ')
print (line_unmodified)

print('Modified lines: ')
print (line_modified)

f.close()
