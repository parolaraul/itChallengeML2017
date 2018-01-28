# -*- coding: utf-8 -*-
"""
Ejercicio 1: Satisfactibilidad Booleana
"""
from uf20 import f_1

VARIABLES = 20
TERMINOS = 91

# f_1 recibe 20 parámetros (los valores para las 20 variables) y devuelve
# una tupla con los valores de verdad de los 91 términos.

#
# Ayudita:
#
# En Python, si se tiene una lista con valores, puede invocarse a una función
# haciendo que los valores de la lista se pasen como parámetros poniendo un *
# adelante de la lista. Ejemplo:
#
#  def func(a, b, c):
#      return a + b + c
#
#  v = [1, 2, 3]
#  func(*v) == func(1, 2, 3)
#