# -*- coding: utf-8 -*-
"""
@author: Germán L. Osella Massa (german.osella at nexo.unnoba.edu.ar)
"""
import numpy as np
from cbackpropagation import ANN #, Identidad, Sigmoide

X = np.array([[0, 0], [0, 1], [1, 0], [1, 1]], dtype=float)
#T = np.array([[0], [1], [1], [0]], dtype=float)
T = np.array([[0, 0], [0, 1], [0, 1], [1, 0]], dtype=float)

def progreso(ann, X, T, y=None, n=-1, E=None):
    if n % 20 == 0:
        print("Pasos: {0} - Error: {1:.32f}".format(n, E))

ocultas = 5
entradas = X.shape[1]
salidas = T.shape[1]

# Crea la red neuronal
ann = ANN(entradas, ocultas, salidas)

# La evalúa sin haberla entrenado

# y1 = ann.evaluar_numpy(X)
# print("Salida de la red (numpy):\n{0}\n".format(y1))
# 
# y2 = ann.evaluar(X)
# print("Salida de la red (cython):\n{0}\n".format(y2))
# 
# print("Respuestas iguales?", "Si" if ((y1 - y2) < 1e-15).all() else "No", "\n\n")

# Entrena la red

# E, n = ann.entrenar_original_numpy(X, T, min_error=0, max_pasos=50000, callback=progreso, frecuencia_callback=5000)
# E, n = ann.entrenar_con_momento_numpy(X, T, min_error=0, max_pasos=50000, callback=progreso, frecuencia_callback=5000)
# E, n = ann.entrenar_rprop_numpy(X, T, min_error=0, max_pasos=50000, callback=progreso, frecuencia_callback=5000)

# E, n = ann.entrenar_original(X, T, min_error=0, max_pasos=50000, callback=progreso, frecuencia_callback=5000)
# E, n = ann.entrenar_con_momento(X, T, min_error=0, max_pasos=50000, callback=progreso, frecuencia_callback=5000)
E, n = ann.entrenar_rprop(X, T, min_error=0, max_pasos=50000, callback=progreso, frecuencia_callback=5000)

print("\nRed entrenada en {0} pasos con un error de {1:.32f}".format(n, E))
