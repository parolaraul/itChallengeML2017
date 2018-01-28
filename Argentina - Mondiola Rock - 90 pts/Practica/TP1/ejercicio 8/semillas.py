# -*- coding: utf-8 -*-
"""
Ejercicio 7: Diagnóstico de pacientes con problemas de hígado.
"""
import numpy as np

semillas = np.load('semillas.npy')

datos = semillas[:, :-1]
tipos = semillas[:, -1]

# tipos == 1 --> Kama
# tipos == 2 --> Rosa
# tipos == 3 --> Canadiense
