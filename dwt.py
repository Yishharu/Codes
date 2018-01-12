#!/usr/bin python3

import pywt
import numpy as np
import matplotlib.pyplot as plt
x = np.arange(512)
y = np.sin(2*np.pi*x/32)
(cA, cD) = pywt.dwt([1, 2, 3, 4, 5, 6], 'db1')


