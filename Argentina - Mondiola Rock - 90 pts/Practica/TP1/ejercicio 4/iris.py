# -*- coding: utf-8 -*-
"""
Ejercicio 4: Iris
"""
import numpy as np

iris = np.load('iris.npy')
datos = iris[:, 1:]
tipos = iris[:, 0]

T = np.zeros((len(tipos), 3))
T[tipos == 1, 0] = 1  # Tipo 1: Iris setosa
T[tipos == 2, 1] = 1  # Tipo 2: Iris versicolor
T[tipos == 3, 2] = 1  # Tipo 3: Iris virginica
