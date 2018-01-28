# -*- coding: utf-8 -*-
"""
Ejercicio 4: Problema del Viajante.
"""
import numpy as np

CIUDADES = np.load('bayg29.cities.npy')
DISTANCIAS = np.load('bayg29.distances.npy')
RECORRIDO_OPTIMO = np.load('bayg29.opt.tour.npy')  # Distancia mínima: 1610

#CIUDADES = np.load('eil101.cities.npy')
#DISTANCIAS = np.load('eil101.distances.npy')
#RECORRIDO_OPTIMO = np.load('eil101.opt.tour.npy')  # Distancia mínima: 629

def distancia_recorrido(recorrido):
    """ Devuelve el largo total del recorrido. """
    largo = 0
    ciudad_anterior = recorrido[-1]
    for ciudad in recorrido:
        largo += DISTANCIAS[ciudad_anterior, ciudad]
        ciudad_anterior = ciudad
    return largo


def mostrar_recorrido(recorrido):
    import matplotlib.pyplot as plt
    r = recorrido + [recorrido[0]]
    plt.figure(1)
    plt.clf()
    plt.plot(CIUDADES[0], CIUDADES[1], 'o')
    plt.plot(CIUDADES[0, r], CIUDADES[1, r], 'r')
    plt.show()
