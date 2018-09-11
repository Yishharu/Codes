# -*- coding: utf-8 -*-
"""
Created on Wed Jan 10 14:50:17 2018

@author: zl382
"""
from fpdf import FPDF
import scipy.io as sio
import numpy as np
from obspy import read 
import matplotlib.pyplot as plt
import glob
import os.path

pdf = FPDF('L','in','A4')
 
fan_path = '/home/zl382/Pictures/Fan_plot/'
image_list = os.listdir(fan_path)
image_list.sort(key= lambda x:float(x[-9:-5]))   # [-9:-5]

#pdf.add_page('L')
for image in image_list:
    if (image == image_list[-1]):
        break
    try:
        if (float(image[-16:-11])<110) and (float(image[-16:-11])>=100):
            pdf.add_page('L')
            pdf.image(fan_path + image,0.,0.,11.7,8.3,'PNG')
            print(image+' Done!')
    except:
        if (image == image_list[-1]):
            break
        continue
pdf.output('/home/zl382/Pictures/fanD100_110.pdf','F')
#pdf.add_page()
#for image in image_list:
#    if (float(image[-16:-11])<130) and (float(image[-16:-11])>120):
# #       pdf.add_page('L')
#        pdf.image(fan_path + image)
#        print(image+' Done!')
#pdf.output('/home/zl382/Pictures/fanD120_130.pdf','F')    
#
#pdf.add_page()
#for image in image_list:
#    if (float(image[-16:-11])<110) and (float(image[-16:-11])>100):
##       # pdf.add_page()
#        pdf.image(fan_path + image, None, None, 11,8)
#        print(image+' Done!')
#pdf.output('/home/zl382/Pictures/fanD100_110.pdf','F')    

#pdf.add_page()
#for image in image_list:
#  #  if (float(image[-16:-11])<102): # and (float(image[-16:-11])>100):
##       # pdf.add_page()
#        pdf.image(fan_path + image, None, None, 11,8)
#        print(image+' Done!')
#pdf.output('/home/zl382/Pictures/fanD90_100.pdf','F')   
