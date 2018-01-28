# -*- coding: utf-8 -*-
"""
Ejercicio 10: dígitos MNIST
"""
import numpy as np
import matplotlib.pyplot as plt

datos = np.load('mnistabridged.npz')
train_data = datos['train_data']
train_labels = datos['train_labels']
test_data = datos['test_data']
test_labels = datos['test_labels']

# Escalado al intervalo [0, 1]
X = train_data / 255.0  # Patrones de entrenamiento
X2 = test_data / 255.0  # Patrones de prueba

# Construcción de las respuestas esperadas a partir del valor del dígito
clases = np.unique(train_labels)
t = np.zeros((len(train_labels), len(clases))) 
t2 = np.zeros((len(test_labels), len(clases)))
for n, clase in enumerate(clases):
    t[train_labels.flat == clase, n] = 1
    t2[test_labels.flat == clase, n] = 1

# t tiene las respuestas esperadas para el entrenamiento
# t2 tiene las respuestas esperadas para las pruebas




# Nueva figura: Muestra el primer patrón de entrenamiento
plt.figure()
plt.gray() # Para ver las imágenes en escala de grises
plt.imshow(train_data[0].reshape(28, 28))
plt.title('Digito: {0}'.format(train_labels[0]))

# Nueva figura: Muestra el primer patrón de pruebas
plt.figure()
plt.imshow(test_data[1].reshape(28, 28))
plt.title('Digito: {0}'.format(test_labels[1]))

# Muestra todas las figuras creadas y espera
plt.show()
