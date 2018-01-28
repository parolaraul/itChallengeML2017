# -*- coding: utf-8 -*-
import numpy as np
from cperceptron import Perceptron

X = np.array([[0, 0], [0, 1], [1, 0], [1, 1]], dtype=np.float)
# T = np.array([0, 1, 0, 1], dtype=np.int8)
T = np.array([1, 0, 0, 1], dtype=np.int8)

def progreso(perceptron, X, T, n):
    y = perceptron.evaluar(X)
    incorrectas = (T != y).sum()
    print("Pasos: {0}\tIncorrectas: {1}\ny = {2}\nt = {3}\n".format(n, incorrectas, y, T))


# Crea un perceptron con tantas entradas como columnas tiene X
p = Perceptron(X.shape[1])

print("Entrenando:\n")
# n = p.entrenar_numpy(X, T, max_pasos=50000, callback=progreso, frecuencia_callback=10000)
n = p.entrenar(X, T, max_pasos=50000000, callback=progreso, frecuencia_callback=10000000)

print("\nEntrenamiento finalizado en {0} iteraciones.".format(n))
print("W:", p.W)
print("b:", p.b)

print("T:", T)
# print("y:", p.evaluar_numpy(X))
print("y:", p.evaluar(X))

# p.visualizar(X, T)
