# -*- coding: utf-8 -*-
"""
Ejercicio 2: Optimización numérica
"""
from math import cos, pi

# Esta es la función Rastrigin
def rastrigin(vect):
   total = 0
   for x in vect:
      total += x ** 2 - 10 * cos(2 * pi * x)
   return (10 * len(vect)) + total
