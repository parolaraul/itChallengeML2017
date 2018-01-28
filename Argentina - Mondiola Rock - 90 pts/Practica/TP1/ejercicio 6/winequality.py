# -*- coding: utf-8 -*-
"""
Ejercicio 6: Puntuación de vinos.
"""
import numpy as np

winequality = np.load('winequality.npy')

datos = winequality[:, :-1]
puntuacion = winequality[:, -1].reshape(-1, 1)
