# -*- coding: utf-8 -*-
"""
Heurísticas de búsqueda local

@author: Germán L. Osella Massa (german.osella at nexo.unnoba.edu.ar)
"""

import numpy as np
from random import random

def hill_climb(solucion_inicial, evaluacion, obtener_vecinos):
    """
    Hill climbing determinístico.
    """
    soluciones_evaluadas = 1
    solucion_actual = solucion_inicial
    evaluacion_actual = evaluacion(solucion_actual)

    optimo_local = False
    while not optimo_local:
        vecinos = obtener_vecinos(solucion_actual)
        optimo_local = True
        for vecino in vecinos:
            evaluacion_vecino = evaluacion(vecino)
            soluciones_evaluadas += 1
            if evaluacion_vecino > evaluacion_actual:
                solucion_actual = vecino
                evaluacion_actual = evaluacion_vecino
                optimo_local = False

    return solucion_actual, soluciones_evaluadas


def simulated_annealing(solucion_inicial, evaluacion, obtener_vecinos,
                        T_max, T_min, reduccion):
    """
    Simulated Annealing.
    """
    solucion_mejor = solucion_actual = solucion_inicial
    evaluacion_mejor = evaluacion_actual = evaluacion(solucion_actual)
    soluciones_evaluadas = 1

    T = T_max
    while T >= T_min:
        vecinos = obtener_vecinos(solucion_actual)
        for vecino in vecinos:
            evaluacion_vecino = evaluacion(vecino)
            soluciones_evaluadas += 1
            
            if (evaluacion_vecino > evaluacion_actual or
                random() < np.exp((evaluacion_vecino - evaluacion_actual) / T)):
                solucion_actual = vecino
                evaluacion_actual = evaluacion_vecino
                if evaluacion_mejor < evaluacion_actual:
                    solucion_mejor = solucion_actual
                    evaluacion_mejor = evaluacion_actual

        T = reduccion * T

    return solucion_mejor, soluciones_evaluadas
