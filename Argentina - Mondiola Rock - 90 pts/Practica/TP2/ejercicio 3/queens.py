# -*- coding: utf-8 -*-
"""
Ejercicio 3: N-reinas
"""

QUEENS = 16

def amenaza(fila_1, col_1, fila_2, col_2):
    "Determina a partir de sus posiciones si dos reinas se están amenazando."
    return ( (fila_1 == fila_2) or (col_1 == col_2) or
             (abs(fila_1 - fila_2) == abs(col_1 - col_2)) )

"""
Para la cantidad máxima de amenazas, si la reina A amenaza a la reina B, la
reina B también amenaza a la reina A pero sólo se contabiliza como una amenaza.
"""
MAX_AMENAZAS = (QUEENS * (QUEENS-1)) / 2
