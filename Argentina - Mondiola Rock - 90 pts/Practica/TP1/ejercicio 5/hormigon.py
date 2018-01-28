# -*- coding: utf-8 -*-
"""
Ejercicio 5: Resistencia a compresión del hormigón.
"""
import numpy as np

hormigon = np.load('hormigon.npy')

datos = hormigon[:, :-1]
resistencia = hormigon[:, -1].reshape(-1, 1)
