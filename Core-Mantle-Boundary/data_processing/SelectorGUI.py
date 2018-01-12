#!/usr/bin/env python3

'''
This script can be used to select data.
It will loop through the seismograms and show the Radial component and Transverse component.
Press the buttons in  the GUI to process the data:
1. Keep data (also bound to left arrow key)
2. Discard data (also bound to right arrow key)
3. Invert polarity (also bound to the up arrow key)
Discarded data will be moved to a directory called Dump.
'''

#------------------------------------------------------------------------------------------#
### Import section ------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#

import obspy
from obspy import read, UTCDateTime
from obspy.core import Stream
import os
import os.path
import time
import glob
import shutil
import sys
import subprocess
import matplotlib
matplotlib.use('TkAgg')
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
from matplotlib.figure import Figure
import tkinter as tk
import tkinter.ttk as ttk
from tkinter import *

#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#

class Application(tk.Frame):
    ABOUT_TEXT = """Instructions for use:

    This software can be used to download and process data from the IRIS
    catalogue website. """
    
    DISCLAIMER = "Author: Conor Bacon"
    
    # Initialise counter
    s = 0

    # Plot synthetics?
    syn = True

    # Filter frequencies
    fmin = 0.033
    fmax = 0.1

    replot = False
    
    def __init__(self, master=None):
        tk.Frame.__init__(self, master)
        
        self.name = StringVar()
        self.event = StringVar()
        self.eventName = StringVar()
        self.azimuth = StringVar()
        self.distance = StringVar()
        self.freqBand = IntVar()
        self.freqBand.set(1)
        self.freqMin = DoubleVar()
        self.freqMax = DoubleVar()        

        self.createWidgets()


    def callback():
        if messagebox.askokcancel("Quit", "Do you want to quit?"):
            root.destroy()
            
    def createWidgets(self):
        # Create menu
        menubar = Menu(root)
        menubar.add_command(label="Instructions", command=lambda: self.instructions())
        menubar.add_command(label="Exit", command=root.quit)
        root.config(menu=menubar)

        # Create options section
        optionFrame = ttk.Frame(root, padding="12 12 12 12", relief=RAISED)
        optionFrame.grid(column=0, row=2, columnspan=2, rowspan=12, sticky=(N, W, E, S))
        optionFrame.columnconfigure(0, weight=1)
        optionFrame.rowconfigure(0, weight=1)

        # Option label
        ttk.Label(master=optionFrame, text="Options").pack(anchor=W)
        
        # Name label and entry box
        ttk.Label(master=optionFrame, text="Name").pack(anchor=W)
        ttk.Entry(master=optionFrame, textvariable=self.name).pack(anchor=W)

        # Control buttons for plots
        ttk.Button(master=optionFrame, text="Start", command=lambda: self.initiate(canvas1,ax1,canvas2,ax2)).pack(anchor=W)       
        ttk.Button(master=optionFrame, text="Accept", command=lambda: self.acceptData(canvas1,ax1,canvas2,ax2)).pack(anchor=W)
        ttk.Button(master=optionFrame, text="Reject", command=lambda: self.rejectData(canvas1,ax1,canvas2,ax2)).pack(anchor=W)
        ttk.Button(master=optionFrame, text="Invert", command=lambda: self.invertData(canvas1,ax1,canvas2,ax2)).pack(anchor=W)        
        ttk.Button(master=optionFrame, text="Reset", command=lambda: self.resetCounter()).pack(anchor=W)
        
        # Frequency options and update button
        Radiobutton(master=optionFrame, text="10-30s", variable=self.freqBand, value=1).pack(anchor=W)
        Radiobutton(master=optionFrame, text="10-20s", variable=self.freqBand, value=2).pack(anchor=W)
        Radiobutton(master=optionFrame, text="Custom", variable=self.freqBand, value=3).pack(anchor=W)
        ttk.Label(master=optionFrame, text="Min. Period").pack(anchor=W)
        ttk.Entry(master=optionFrame, textvariable=self.freqMax).pack(anchor=W)
        ttk.Label(master=optionFrame, text="Max. Period").pack(anchor=W)
        ttk.Entry(master=optionFrame, textvariable=self.freqMin).pack(anchor=W)

        ttk.Button(master=optionFrame, text="Update", command=lambda: self.updateFreqBand(canvas, ax, canvas2, ax2)).pack(anchor=W)
        
        # Create labels for distance and azimuth
        ttk.Label(master=optionFrame, text="Azimuth").pack(anchor=W)
        ttk.Label(master=optionFrame, textvariable=self.azimuth).pack(anchor=W)
        ttk.Label(master=optionFrame, text="Distance").pack(anchor=W)
        ttk.Label(master=optionFrame, textvariable=self.distance).pack(anchor=W)

        # Add some padding to all widgets in this frame
        for child in optionFrame.winfo_children():
            child.pack_configure(padx=5, pady=5)        

        # Create transverse canvas
        fig1 = plt.figure(figsize=(10,5), dpi=100)
        ax1 = fig1.add_axes([0.1,0.1,0.8,0.8])
        canvas1 = FigureCanvasTkAgg(fig1, master=root)
        canvas1.get_tk_widget().grid(row=2, column=2, rowspan=6, columnspan=8)
        canvas1.show()

        # Create radial canvas
        fig2 = plt.figure(figsize=(10,5), dpi=100)
        ax2 = fig2.add_axes([0.1,0.1,0.8,0.8])
        canvas2 = FigureCanvasTkAgg(fig2, master=root)
        canvas2.get_tk_widget().grid(row=8, column=2, rowspan=6, columnspan=8)
        canvas2.show()

        self.update()
        
        root.bind("<Right>", lambda _: self.acceptData(canvas1, ax1, canvas2, ax2))
        root.bind("<Left>", lambda _: self.rejectData(canvas1, ax1, canvas2, ax2))
        root.bind("<Up>", lambda _: self.invertData(canvas1, ax1, canvas2, ax2))      

        
    def initiate(self, canvas1, ax1, canvas2, ax2):
        dir = 'Data/' + str(self.name.get())
        self.seislist = glob.glob(dir + '/*PICKLE')
        print(self.seislist)

        self.resetCounter()

        self.updateFreqBand(canvas1, ax1, canvas2, ax2)
        
        # Create directory to dump data into
        self.dirdump = dir + 'Dump'
        if not os.path.exists(self.dirdump):
            os.makedirs(self.dirdump)

        self.distAzUpdate()

        
    def updateFreqBand(self, canvas1, ax1, canvas2, ax2):
        freqBand = self.freqBand.get()
        if (freqBand == 1):
            self.fmin = 0.033
            self.fmax = 0.1
        if (freqBand == 2):
            self.fmin = 0.05
            self.fmax = 0.1
        if (freqBand == 3):
            self.fmin = 1 / self.freqMin.get()
            self.fmax = 1 / self.freqMax.get()

        self.plot(canvas1, ax1, canvas2, ax2)

        
    def counterUpdate(self):
        self.eventName.set(str(self.seislist[self.s]))
        self.event.set(str(self.s + 1) + ' / ' + str(len(self.seislist)))
        

    def distAzUpdate(self):
        self.azimuth.set(str(round(self.az, 3)))
        self.distance.set(str(round(self.dist, 3)))
        
        
    def resetCounter(self):
        self.s = 0
        self.counterUpdate()
        

    def rejectData(self, canvas1, ax1, canvas2, ax2, event=None):
        shutil.move(self.seislist[self.s], self.dirdump)
        self.s += 1

        if ((self.s) == len(self.seislist)):
            print('Last seismogram')
        else:
            self.counterUpdate()
            self.updateFreqBand(canvas1, ax1, canvas2, ax2)
            self.distAzUpdate()

            
    def acceptData(self, canvas1, ax1, canvas2, ax2, event=None):
        self.s += 1

        if ((self.s) == len(self.seislist)):
            print('Last seismogram')
        else:
            self.counterUpdate()
            self.updateFreqBand(canvas1, ax1, canvas2, ax2)
            self.distAzUpdate()
            

    def invertData(self, canvas1, ax1, canvas2, ax2, event=None):
        self.seisR.data = self.seisR.data * -1.
        self.seisT.data = self.seisT.data * -1.
              
        if len(self.seisZ) > 1:
            self.seisZ = self.seisZ.select(location='10')
            self.seisZ[0].stats = self.seisStats
            
        seisnew = Stream()
        seisnew.append(self.seisZ[0])
        seisnew.append(self.seisR)
        seisnew.append(self.seisT)
        seisnew.append(self.synT)
        seisnew.append(self.synR)
        seisnew.append(self.synZ)
        # Write out in PICKLE format
        filename = self.seislist[self.s]
        seisnew.write(filename, 'PICKLE')
        self.replot = True
        self.updateFreqBand(canvas1, ax1, canvas2, ax2)

        
    def plot(self, canvas1, ax1, canvas2, ax2):
        # Clear current plot
        ax1.clear()
        ax2.clear()

        # Get current data
        seis = read(self.seislist[int(self.s)], format='PICKLE')

        if (self.replot == False):
            seis.filter('highpass', freq=self.fmin, corners=2, zerophase=True)
            seis.filter('lowpass', freq=self.fmax, corners=2, zerophase=True)

        tshift = seis[0].stats['starttime'] - seis[0].stats['eventtime']

        self.seisR = seis.select(channel='BHR')[0]
        self.seisT = seis.select(channel='BHT')[0]
        self.seisZ = seis.select(channel='BHZ')
        self.seisStats = seis[0].stats

        self.az = seis[0].stats['az']
        self.dist = seis[0].stats['dist']        

        # Differentiate data
        if (self.replot == False):
            self.seisT.data = np.gradient(self.seisT.data, self.seisT.stats.delta)
            self.seisR.data = np.gradient(self.seisR.data, self.seisT.stats.delta)

        # Plotting data. Both components normalised by max amplitude on transverse component
        Phase = ['Sdiff', 'S']
        for x in range (0,2):
            if  seis[0].stats.traveltimes[Phase[x]]!=None:
                phase = Phase[x]
        ax1.plot(self.seisT.times() + tshift - seis[0].stats.traveltimes[phase], self.seisT.data / np.max(abs(self.seisT.data)), 'k', linewidth=2)
        ax2.plot(self.seisR.times() + tshift - seis[0].stats.traveltimes[phase], self.seisR.data / np.max(abs(self.seisT.data)), 'k', linewidth=2)

        # Retrieve synthetic data
        self.synT = seis.select(channel='BXT')[0]
        self.synR = seis.select(channel='BXR')[0]
        self.synZ = seis.select(channel='BXZ')[0]
        
        # Plot synthetic data
        self.synR.data = np.gradient(self.synR.data, self.synR.stats.delta)
        self.synT.data = np.gradient(self.synT.data, self.synT.stats.delta)
        
        ax1.plot(self.synT.times(), self.synT.data / np.max(self.seisT.data), color=[0.5,0.5,0.5])
        ax2.plot(self.synR.times(), self.synR.data / np.max(self.seisT.data), color=[0.5,0.5,0.5])

        # Plotting travel time predictions
        for k in seis[0].stats.traveltimes.keys():
            if seis[0].stats.traveltimes[k] != None:
                ax1.plot(seis[0].stats.traveltimes[k], 0.0, 'g', marker='o', markersize=4)
                ax1.text(seis[0].stats.traveltimes[k], -0.2, k, fontsize=8)

        ax1.set_title('%s' % (str(self.eventName.get())), loc='left')
        ax1.set_title('%s' % (str(self.event.get())), loc='right')
                
        ax1.set_ylim([-1.0, 1.0])
        ax1.set_xlim([-50, 100])

        ax2.set_ylim([-1.0, 1.0])
        ax2.set_xlim([-50, 100])
        
        canvas1.draw()
        canvas2.draw()

        self.replot = False

    def instructions(self):
        toplevel = Toplevel()
        label1 = Label(toplevel, text=self.ABOUT_TEXT, height=0, width=100)
        label1.pack(anchor=W)
        label2 = Label(toplevel, text=self.DISCLAIMER, height=0, width=100)
        label2.pack()

    
root = tk.Tk()
root.title("Part III Project - Data Selector")
#root.protocol("WM_DELETE_WINDOW", self.callback)
app = Application(master=root)
app.mainloop()
