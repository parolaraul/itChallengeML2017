# -*- coding: utf-8 -*-
#cython: language_level=3
"""
@author: Germán L. Osella Massa (german.osella at nexo.unnoba.edu.ar)
"""
cimport cython
import numpy as np
cimport numpy as np

class Perceptron:
    """
    Implementa un perceptrón.
    """
    def __init__(self, entradas):
        self.entradas = entradas
        self.reiniciar()


    def reiniciar(self):
        self.W = np.zeros(self.entradas, dtype=np.float)
        self.b = 0.0
        self.iteraciones = 0


    @staticmethod
    def cargar(nombre_archivo):
        datos = np.load(nombre_archivo)
        perceptron = Perceptron(int(datos['entradas']))
        perceptron.W = datos['W']
        perceptron.b = float(datos['b'])
        perceptron.iteraciones = int(datos['iteraciones'])
        return perceptron


    def guardar(self, nombre_archivo):
        np.savez(nombre_archivo, entradas=self.entradas,
                 W=self.W, b=self.b, iteraciones=self.iteraciones)


    def evaluar_numpy(self, X):
        return (np.dot(X, self.W) + self.b > 0).astype(np.int8)


    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    def evaluar(self, np.float_t[:, ::1] X not None, out=None):
        cdef Py_ssize_t patrones = X.shape[0]
        assert X.shape[1] == self.entradas

        cdef np.float_t[::1] W = self.W
        cdef np.float_t b = self.b

        if out is None:
            out = np.empty(patrones, dtype=np.int8)
        assert out.shape[0] == patrones

        cdef Py_ssize_t i, j
        cdef np.float_t suma
        cdef np.int8_t[::1] Y = out

        for i in range(patrones):
            suma = b
            for j in range(self.entradas):
                suma += X[i, j] * W[j]
            Y[i] = 1 if suma > 0 else 0

        return out


    def entrenar_numpy(self, X, T, max_pasos=1000, callback=None, frecuencia_callback=1):
        # Verifica que las entradas coincidan con el tamaño de X
        if X.shape[1] != self.entradas:
            raise ValueError("El vector con los patrones de entrada no tiene las dimensiones requeridas.\n"
                "Se esperaban {0} pero se recibieron {1}.".format(self.entradas, X.shape[1]))

        # Verifica que las salidas esperadas coincidan con la cantidad de patrones
        if T.shape[0] != X.shape[0]:
            raise ValueError("El vector con las respuestas esperadas no tiene la cantidad requerida de patrones.\n"
                "Se esperaban {0} pero se recibieron {1}.".format(X.shape[0], T.shape[0]))

        # Ciclo de aprendizaje
        frec = 0
        n = 0

        while n < max_pasos:
            cambio = False
            for x, t in zip(X, T):
                y = (np.dot(x, self.W) + self.b > 0).astype(np.int8)
                d = t - y
                if d != 0:
                    self.W += d * x
                    self.b += d
                    cambio = True

            n += 1

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    if callback(self, X, T, n=n):
                        break
                    frec = 0

            if not cambio:
                break

        self.iteraciones += n
        return n


    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    def entrenar(self, np.float_t[:, ::1] X not None,
                 np.int8_t[::1] T not None,
                 long max_pasos=1000, callback=None,
                 long frecuencia_callback=1):
        cdef Py_ssize_t patrones = X.shape[0]
        cdef Py_ssize_t entradas = X.shape[1]
        assert T.shape[0] == patrones

        cdef np.float_t[::1] W = self.W
        cdef np.float_t b = self.b

        cdef Py_ssize_t i, j, k
        cdef np.float_t suma
        cdef np.int8_t y, d
        cdef int cambio

        cdef long frec = 0
        cdef long n = 0
        
        while n < max_pasos:
            cambio = False

            # Para cada patrón de entrada
            for i in range(patrones):
                # Calcula la salida del percetrón
                suma = 0
                for j in range(entradas):
                    suma += X[i, j] * W[j]
                y = 1 if (suma + b) > 0 else 0

                # Calcula el error y ajusta los pesos si fuera necesario
                d = T[i] - y
                if d != 0:
                    cambio = True
                    for j in range(entradas):
                        W[j] += d * X[i, j]
                    b += d

            n += 1

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    self.b = b
                    if callback(self, np.asarray(X), np.asarray(T), n=n):
                        break
                    frec = 0

            if not cambio:
                break

        self.b = b
        self.iteraciones += n
        return n


    def visualizar(self, X, T):
        from matplotlib import pylab

        if self.entradas != 2:
            raise ValueError("Solamente es posible visualizar un perceptron con 2 entradas")

        mn = X.min(axis=0)
        mx = X.max(axis=0)
        d = (mx - mn) * 0.1
        mn = mn - d
        mx = mx + d

        pylab.figure()
        pylab.axis([mn[0], mx[0], mn[1], mx[1]])

        clases = np.unique(T)
        for c in clases:
            o = X[pylab.find(T == c)].T
            pylab.plot(o[0], o[1], 'o', label="t={0}".format(c))

        w1, w2 = self.W
        b = self.b
        if w2 != 0:
            x2 = lambda x1: -(w1 * x1 + b) / w2
            pylab.plot((mn[0], mx[0]), (x2(mn[0]), x2(mx[0])), '--')
        elif w1 != 0:
            x1 = -b / w1
            pylab.plot((x1, x1), (mn[1], mx[1]), '--')
        else:
            return "Los pesos están en 0. Nada para graficar..."

        pylab.show()
