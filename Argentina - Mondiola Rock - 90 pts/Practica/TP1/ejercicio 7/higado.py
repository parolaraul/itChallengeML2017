# -*- coding: utf-8 -*-
"""
Ejercicio 7: Pacientes con problemas de Hígado
"""
import numpy as np

higado = np.load('higado.npy')

muestras = higado[:, :-1]

# Atributo 'sexo':
#     muestras[:, 1] == 1 --> HOMBRE
#     muestras[:, 1] == 2 --> MUJER

diagnostico = higado[:, -1]

# diagnostico == 1 --> CON PROBLEMA DE HÍGADO
# diagnostico == 2 --> SIN PROBLEMA DE HÍGADO
