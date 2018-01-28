# -*- coding: utf-8 -*-
"""
Ejercicio 9: Reconocimiento de texturas que contengan piel.
"""
import numpy as np

piel = np.load('piel.npy')

color = piel[:, :-1]
tipos = piel[:, -1]

# tipos == 1 --> Piel
# tipos == 2 --> No Piel


# ... IMPLEMENTAR ...


# Para probar el clasificador
from matplotlib import pylab

imagen = np.load('imagen.npy')
pylab.imshow(imagen)

# La imagen ahora en una matriz donde en cada fila está el color de cada pixel.
imagen_lineal = imagen.reshape(-1, 3)[:, ::-1]

# Y = salida de la red neuronal
# ... IMPLEMENTAR ...

# Vuelve a darla las dimensiones de la imagen al resultado de la clasificación.
clasificacion = Y.reshape(imagen.shape[:-1])

pylab.gray()
pylab.imshow(clasificacion)

pylab.show()
