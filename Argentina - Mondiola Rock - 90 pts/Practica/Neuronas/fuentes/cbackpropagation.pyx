# -*- coding: utf-8 -*-
#cython: language_level=3
"""
@author: Germán L. Osella Massa (german.osella at nexo.unnoba.edu.ar)
"""

cimport cython
import numpy as np
cimport numpy as npc
from libc.math cimport exp

cdef class Funcion:
    cpdef npc.float_t eval(self, npc.float_t x) except *:
        return 0.0

    cpdef npc.float_t deriv(self, npc.float_t x) except *:
        return 0.0

    def eval_numpy(self, x):
        return 0.0

    def deriv_numpy(self, x):
        return 0.0


cdef class Identidad(Funcion):
    cpdef npc.float_t eval(self, npc.float_t x) except *:
        return x

    cpdef npc.float_t deriv(self, npc.float_t x) except *:
        return 1.0

    def eval_numpy(self, x):
        return x

    def deriv_numpy(self, x):
        return 1.0


cdef class Sigmoide(Funcion):
    @cython.cdivision(True)
    cpdef npc.float_t eval(self, npc.float_t x) except *:
        return 1.0 / (1.0 + exp(-x))

    @cython.cdivision(True)
    cpdef npc.float_t deriv(self, npc.float_t x) except *:
        cdef npc.float_t n = 1.0 / (1.0 + exp(-x))
        return n * (1.0 - n)

    def eval_numpy(self, x):
        return 1.0 / (1.0 + np.exp(-x))

    def deriv_numpy(self, x):
        n = 1.0 / (1.0 + np.exp(-x))
        return n * (1.0 - n)


cdef class SigmoideBipolar(Funcion):
    @cython.cdivision(True)
    cpdef npc.float_t eval(self, npc.float_t x) except *:
        return (2.0 / (1.0 + exp(-x))) - 1.0

    @cython.cdivision(True)
    cpdef npc.float_t deriv(self, npc.float_t x) except *:
        cdef npc.float_t n = (2.0 / (1.0 + exp(-x))) - 1.0
        return 0.5 * (1.0 + n) * (1.0 - n)

    def eval_numpy(self, x):
        return (2.0 / (1.0 + np.exp(-x))) - 1.0

    def deriv_numpy(self, x):
        n = (2.0 / (1.0 + np.exp(-x))) - 1.0
        return 0.5 * (1.0 + n) * (1.0 - n)


FUNCS = {
    'Identidad': Identidad,
    'Sigmoide': Sigmoide,
    'SigmoideBipolar': SigmoideBipolar,
}


class ANN:
    """
    Implementa una Red Neuronal Artifical con tres capas:
    Una de entrada, una oculta y una de salida.
    Permite entrenar la red usando el algoritmo de backpropagation.
    """

    def __init__(self, entradas, ocultas, salidas, func_h=Sigmoide(), func_o=Identidad()):
        """
        Crea una red neuronal artificial que tiene:
          - "entradas" neuronas de entrada
          - "ocultas" neuronas en la capa oculta
          - "salidas" neuronas en la capa de salida
        Para calcular la activación de la capa oculta se usa func_h y para
        la capa de salida, func_o.
        """
        self.entradas = entradas
        self.ocultas = ocultas
        self.salidas = salidas
        self.func_h = func_h
        self.func_o = func_o
        self.reiniciar()


    def reiniciar(self, delta=0.5):
        """
        Inicializa la red poniendo valores aleatorios entre -delta y delta
        en todos los pesos de las conexiones de la red.
        """
        delta2 = delta * 2
        self.W_h = np.random.random((self.entradas, self.ocultas)) * delta2 - delta
        self.b_h = np.random.random(self.ocultas) * delta2 - delta
        self.W_o = np.random.random((self.ocultas, self.salidas)) * delta2 - delta
        self.b_o = np.random.random(self.salidas) * delta2 - delta
        self.iteraciones = 0


    @staticmethod
    def cargar(nombre_archivo):
        datos = np.load(nombre_archivo)

        ann = ANN(int(datos['entradas']), int(datos['ocultas']), int(datos['salidas']),
                  func_h=FUNCS[str(datos['func_h'])](),
                  func_o=FUNCS[str(datos['func_o'])]())

        ann.W_h = datos['W_h']
        ann.b_h = datos['b_h']
        ann.W_o = datos['W_o']
        ann.b_o = datos['b_o']
        ann.iteraciones = int(datos['iteraciones'])

        return ann


    def guardar(self, nombre_archivo):
        np.savez(nombre_archivo,
            entradas=self.entradas, salidas=self.salidas, ocultas=self.ocultas,
            func_h=self.func_h.__class__.__name__, func_o=self.func_o.__class__.__name__,
            W_h=self.W_h, b_h=self.b_h, W_o=self.W_o, b_o=self.b_o,
            iteraciones=self.iteraciones)


    def _evaluar_interno_numpy(self, X):
        """
        Calcula la salida de la red retornando además los valores usados
        al realizar los pasos intermedios.
        """
        z_h = np.dot(X, self.W_h) + self.b_h
        y_h = self.func_h.eval_numpy(z_h)
        z_o = np.dot(y_h, self.W_o) + self.b_o
        y_o = self.func_o.eval_numpy(z_o)
        return (z_h, y_h, z_o, y_o)


    def evaluar_numpy(self, X):
        """
        Calcula y devuelve la respuesta de la red para los patrones X.
        """
        return self._evaluar_interno_numpy(X)[-1]


    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    def evaluar(self, npc.float_t[:, ::1] X not None, out=None):
        """
        Calcula y devuelve la respuesta de la red para los patrones X.
        """
        cdef Py_ssize_t entradas = self.entradas
        cdef Py_ssize_t ocultas = self.ocultas
        cdef Py_ssize_t salidas = self.salidas
        cdef Py_ssize_t patrones = X.shape[0]
        assert X.shape[1] == entradas

        if out is None:
            out = np.empty((patrones, salidas), dtype=np.float)
        assert out.shape == (patrones, self.salidas)

        cdef Funcion func_h = self.func_h
        cdef Funcion func_o = self.func_o

        cdef npc.float_t[:, ::1] W_h = self.W_h
        cdef npc.float_t[::1]    b_h = self.b_h
        cdef npc.float_t[:, ::1] W_o = self.W_o
        cdef npc.float_t[::1]    b_o = self.b_o

        cdef npc.float_t[::1] y_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[:, ::1] y_o = out

        cdef Py_ssize_t i, j, k
        cdef npc.float_t suma

        for i in range(patrones):
            for j in range(ocultas):
                suma = b_h[j]
                for k in range(entradas):
                    suma += X[i, k] * W_h[k, j]
                y_h[j] = func_h.eval(suma)

            for j in range(salidas):
                suma = b_o[j]
                for k in range(ocultas):
                    suma += y_h[k] * W_o[k, j]
                y_o[i, j] = func_o.eval(suma)

        return out


    def entrenar_original_numpy(self, X, T, min_error=0, alfa=0.3, max_pasos=500,
                                callback=None, frecuencia_callback=1):
        patrones = X.shape[0]
        frec = 0
        E = 0.0
        n = 0

        # Entrena hasta alcanzar max_pasos (puede terminar antes)
        for n in range(1, max_pasos + 1):
            # Evalua la red para calcular error total
            Y_o = self.evaluar_numpy(X)
            E = 0.5 * ((T - Y_o) ** 2).sum() / patrones

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    if callback(self, X, T, n=n, E=E):
                        break
                    frec = 0

            # Si el error es menor al mínimo error buscado, termina
            if E <= min_error:
                break

            # Para cada patrón, realiza ajustes en los pesos
            for x, t in zip(X, T):
                # Evalúa la red neuronal para este patrón
                z_h, y_h, z_o, y_o = self._evaluar_interno_numpy(x)

                # Calcula el error en la salida
                err = t - y_o
                delta_o = err * self.func_o.deriv_numpy(z_o)
                delta_h = self.func_h.deriv_numpy(z_h) * np.dot(self.W_o, delta_o)

                self.W_o += alfa * delta_o * y_h[:, np.newaxis]
                self.b_o += alfa * delta_o
                self.W_h += alfa * delta_h * x[:, np.newaxis]
                self.b_h += alfa * delta_h

        # Devuelve el error total cometido y la cantidad de pasos usados
        self.iteraciones += n
        return E, n


    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    def entrenar_original(self, npc.float_t[:, ::1] X not None,
                          npc.float_t[:, ::1] T not None,
                          npc.float_t min_error=0, npc.float_t alfa=0.3,
                          long max_pasos=500, callback=None,
                          long frecuencia_callback=1):
        cdef Py_ssize_t patrones = X.shape[0]
        cdef Py_ssize_t entradas = self.entradas
        cdef Py_ssize_t ocultas = self.ocultas
        cdef Py_ssize_t salidas = self.salidas

        assert X.shape[1] == entradas
        assert T.shape[0] == patrones
        assert T.shape[1] == salidas

        cdef Funcion func_h = self.func_h
        cdef Funcion func_o = self.func_o

        # Pesos y bias de la red a entrenar
        cdef npc.float_t[:, ::1] W_h = self.W_h
        cdef npc.float_t[::1]    b_h = self.b_h
        cdef npc.float_t[:, ::1] W_o = self.W_o
        cdef npc.float_t[::1]    b_o = self.b_o

        # Activaciones, salidas y deltas de las capa oculta y de salida
        cdef npc.float_t[::1] z_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] y_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] z_o = np.empty(salidas, dtype=np.float)
        cdef npc.float_t[::1] y_o = np.empty(salidas, dtype=np.float)

        cdef npc.float_t[::1] delta_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] delta_o = np.empty(salidas, dtype=np.float)

        cdef Py_ssize_t i, j, k
        cdef npc.float_t suma
        cdef npc.float_t E = 0.0
        cdef npc.float_t err

        cdef long frec = 0
        cdef long n = 0

        # Entrena hasta alcanzar max_pasos (pero puede terminar antes).
        for n in range(1, max_pasos + 1):
            # Calcula el error acumulado sobre todos los patrones.
            E = 0.0
            for i in range(patrones):
                # Calcula las salidas de las neuronas de la capa oculta
                for j in range(ocultas):
                    suma = b_h[j]
                    for k in range(entradas):
                        suma += X[i, k] * W_h[k, j]
                    y_h[j] = func_h.eval(suma)

                # Calcula las salidas de las neuronas de la capa de salida y
                # el error cometido en cada una de las salidas
                for j in range(salidas):
                    suma = b_o[j]
                    for k in range(ocultas):
                        suma += y_h[k] * W_o[k, j]
                    err = T[i, j] - func_o.eval(suma)
                    E += err * err

            # Calcula el error cuadrático medio
            E /= 2.0 * patrones   #  E  <-- (1/2 * sum((t - y) ** 2)) / patrones

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    if callback(self, np.asarray(X), np.asarray(T), n=n, E=E):
                        break
                frec = 0

            # Si el error es menor al mínimo error buscado, termina
            if E <= min_error:
                break

            # Realiza el entrenamiento con cada uno de los patrones
            for i in range(patrones):
                # Calcula las activaciones y salidas de las neuronas de la capa oculta.
                for j in range(ocultas):
                    suma = b_h[j]
                    for k in range(entradas):
                        suma += X[i, k] * W_h[k, j]
                    z_h[j] = suma
                    y_h[j] = func_h.eval(suma)

                # Calcula las activaciones y salidas de las neuronas de la capa de salida.
                # También calcula el error cometido y los deltas en cada una de las salidas.
                for j in range(salidas):
                    suma = b_o[j]
                    for k in range(ocultas):
                        suma += y_h[k] * W_o[k, j]
                    z_o[j] = suma
                    y_o[j] = func_o.eval(suma)
                    err = T[i, j] - y_o[j]
                    delta_o[j] = err * func_o.deriv(z_o[j])

                # Propaga el error hacia atrás.
                for j in range(ocultas):
                    suma = 0.0
                    for k in range(salidas):
                        suma += delta_o[k] * W_o[j, k]
                    delta_h[j] = suma * func_h.deriv(z_h[j])

                    # Ajusta los pesos y bias para esta neurona oculta.
                    b_h[j] += alfa * delta_h[j]
                    for k in range(entradas):
                        W_h[k, j] += alfa * delta_h[j] * X[i, k]

                # Ajusta los pesos y bias para las neuronas de salida.
                for j in range(salidas):
                    b_o[j] += alfa * delta_o[j]
                    for k in range(ocultas):
                        W_o[k, j] += alfa * delta_o[j] * y_h[k]

        # Devuelve el error total cometido y la cantidad de pasos usados
        self.iteraciones += n
        return E, n


    def entrenar_con_momento_numpy(self, X, T, min_error=0, alfa=0.3, mu=None,
                                   max_pasos=500, callback=None, frecuencia_callback=1):
        patrones = X.shape[0]
        frec = 0
        E = 0.0
        n = 0

        # Términos para calcular el momento
        pW_o = self.W_o.copy()
        pb_o = self.b_o.copy()
        pW_h = self.W_h.copy()
        pb_h = self.b_h.copy()

        if mu is None:
            mu = alfa / 2.0

        # Entrena hasta alcanzar max_pasos (puede terminar antes)
        for n in range(1, max_pasos + 1):
            # Evalua la red para calcular error total
            Y_o = self.evaluar_numpy(X)
            E = 0.5 * ((T - Y_o) ** 2).sum() / patrones

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    if callback(self, X, T, n=n, E=E):
                        break
                    frec = 0

            # Si el error es menor al mínimo error buscado, termina
            if E <= min_error:
                break

            # Para cada patrón, realiza ajustes en los pesos
            for x, t in zip(X, T):
                # Evalúa la red neuronal para este patrón
                z_h, y_h, z_o, y_o = self._evaluar_interno_numpy(x)

                # Calcula el error en la salida
                err = t - y_o
                delta_o = err * self.func_o.deriv_numpy(z_o)
                delta_h = self.func_h.deriv_numpy(z_h) * np.dot(self.W_o, delta_o)

                pW_o, self.W_o = self.W_o, (self.W_o + alfa * delta_o * y_h[:, np.newaxis] + mu * (self.W_o - pW_o))
                pb_o, self.b_o = self.b_o, (self.b_o + alfa * delta_o + mu * (self.b_o - pb_o))
                pW_h, self.W_h = self.W_h, (self.W_h + alfa * delta_h * x[:, np.newaxis] + mu * (self.W_h - pW_h))
                pb_h, self.b_h = self.b_h, (self.b_h + alfa * delta_h + mu * (self.b_h - pb_h))

        # Devuelve el error total cometido y la cantidad de pasos usados
        self.iteraciones += n
        return E, n


    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    def entrenar_con_momento(self, npc.float_t[:, ::1] X not None,
                             npc.float_t[:, ::1] T not None,
                             npc.float_t min_error=0, 
                             npc.float_t alfa=0.3, npc.float_t mu=-1,
                             long max_pasos=500, callback=None,
                             long frecuencia_callback=1):
        cdef Py_ssize_t patrones = X.shape[0]
        cdef Py_ssize_t entradas = self.entradas
        cdef Py_ssize_t ocultas = self.ocultas
        cdef Py_ssize_t salidas = self.salidas

        assert X.shape[1] == entradas
        assert T.shape[0] == patrones
        assert T.shape[1] == salidas

        cdef Funcion func_h = self.func_h
        cdef Funcion func_o = self.func_o

        # Pesos y bias de la red a entrenar
        cdef npc.float_t[:, ::1] W_h = self.W_h
        cdef npc.float_t[::1]    b_h = self.b_h
        cdef npc.float_t[:, ::1] W_o = self.W_o
        cdef npc.float_t[::1]    b_o = self.b_o

        # Términos para calcular el momento
        cdef npc.float_t[:, ::1] pW_h = self.W_h.copy()
        cdef npc.float_t[::1]    pb_h = self.b_h.copy()
        cdef npc.float_t[:, ::1] pW_o = self.W_o.copy()
        cdef npc.float_t[::1]    pb_o = self.b_o.copy()

        if mu == -1:
            mu = alfa / 2.0

        # Activaciones, salidas y deltas de las capa oculta y de salida
        cdef npc.float_t[::1] z_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] y_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] z_o = np.empty(salidas, dtype=np.float)
        cdef npc.float_t[::1] y_o = np.empty(salidas, dtype=np.float)

        cdef npc.float_t[::1] delta_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] delta_o = np.empty(salidas, dtype=np.float)


        cdef Py_ssize_t i, j, k
        cdef npc.float_t suma
        cdef npc.float_t E = 0.0
        cdef npc.float_t err

        cdef long frec = 0
        cdef long n = 0

        # Entrena hasta alcanzar max_pasos (pero puede terminar antes).
        for n in range(1, max_pasos + 1):
            # Calcula el error acumulado sobre todos los patrones.
            E = 0.0
            for i in range(patrones):
                # Calcula las salidas de las neuronas de la capa oculta
                for j in range(ocultas):
                    suma = b_h[j]
                    for k in range(entradas):
                        suma += X[i, k] * W_h[k, j]
                    y_h[j] = func_h.eval(suma)

                # Calcula las salidas de las neuronas de la capa de salida y
                # el error cometido en cada una de las salidas
                for j in range(salidas):
                    suma = b_o[j]
                    for k in range(ocultas):
                        suma += y_h[k] * W_o[k, j]
                    err = T[i, j] - func_o.eval(suma)
                    E += err * err

            # Calcula el error cuadrático medio
            E /= 2.0 * patrones   #  E  <-- (1/2 * sum((t - y) ** 2)) / patrones

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    if callback(self, np.asarray(X), np.asarray(T), n=n, E=E):
                        break
                    frec = 0

            # Si el error es menor al mínimo error buscado, termina
            if E <= min_error:
                break

            # Realiza el entrenamiento con cada uno de los patrones
            for i in range(patrones):
                # Calcula las activaciones y salidas de las neuronas de la capa oculta.
                for j in range(ocultas):
                    suma = b_h[j]
                    for k in range(entradas):
                        suma += X[i, k] * W_h[k, j]
                    z_h[j] = suma
                    y_h[j] = func_h.eval(suma)

                # Calcula las activaciones y salidas de las neuronas de la capa de salida.
                # También calcula el error cometido y los deltas en cada una de las salidas.
                for j in range(salidas):
                    suma = b_o[j]
                    for k in range(ocultas):
                        suma += y_h[k] * W_o[k, j]
                    z_o[j] = suma
                    y_o[j] = func_o.eval(suma)
                    err = T[i, j] - y_o[j]
                    delta_o[j] = err * func_o.deriv(z_o[j])

                # Propaga el error hacia atrás.
                for j in range(ocultas):
                    suma = 0.0
                    for k in range(salidas):
                        suma += delta_o[k] * W_o[j, k]
                    delta_h[j] = suma * func_h.deriv(z_h[j])

                    # Ajusta los pesos y bias para esta neurona oculta.
                    pb_h[j], b_h[j] = b_h[j], b_h[j] + alfa * delta_h[j] + mu * (b_h[j] - pb_h[j])
                    for k in range(entradas):
                        pW_h[k, j], W_h[k, j] = W_h[k, j], W_h[k, j] + alfa * delta_h[j] * X[i, k] + mu * (W_h[k, j] - pW_h[k, j])

                # Ajusta los pesos y bias para las neuronas de salida.
                for j in range(salidas):
                    pb_o[j], b_o[j] = b_o[j], b_o[j] + alfa * delta_o[j] + mu * (b_o[j] - pb_o[j])
                    for k in range(ocultas):
                        pW_o[k, j], W_o[k, j] = W_o[k, j], W_o[k, j] + alfa * delta_o[j] * y_h[k] + mu * (W_o[k, j] - pW_o[k, j])

        # Devuelve el error total cometido y la cantidad de pasos usados
        self.iteraciones += n
        return E, n


    def entrenar_rprop_numpy(self, X, T, min_error=0,
                             delta_0=0.1, delta_min=1e-6, delta_max=50.0,
                             eta_minus=0.5, eta_plus=1.2, max_pasos=500,
                             callback=None, frecuencia_callback=1):
        # Gradiente inicial en cero
        prev_grad = [np.zeros_like(self.W_h),  # W_h
                     np.zeros_like(self.b_h),  # b_h
                     np.zeros_like(self.W_o),  # W_o
                     np.zeros_like(self.b_o),  # b_o
        ]

        # deltas iniciales
        deltas = [np.empty_like(self.W_h),  # W_h
                  np.empty_like(self.b_h),  # b_h
                  np.empty_like(self.W_o),  # W_o
                  np.empty_like(self.b_o),  # b_o
        ]
        for d in deltas:
            d.fill(delta_0)

        # Pesos a ajustar
        weights = [self.W_h, self.b_h, self.W_o, self.b_o]

        patrones = X.shape[0]
        frec = 0
        E = 0
        n = 0

        # Entrena hasta alcanzar max_pasos (puede terminar antes)
        for n in range(1, max_pasos + 1):
            # Evalua la red para calcular error total
            z_h, y_h, z_o, y_o = self._evaluar_interno_numpy(X)

            # Calcula el error en la salida
            err = T - y_o
            E = 0.5 * (err ** 2).sum() / patrones

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    if callback(self, X, T, n=n, E=E):
                        break
                    frec = 0

            # Si el error es menor al mínimo error buscado, termina
            if E <= min_error:
                break

            # Calcula la suma de los gradientes para todos los patrones
            delta_o = err * self.func_o.deriv_numpy(z_o)
            delta_h = self.func_h.deriv_numpy(z_h) * np.dot(delta_o, self.W_o.T)

            grad = [(delta_h[:, np.newaxis, :] * X[:, :, np.newaxis]).sum(axis=0),    # W_h
                    delta_h.sum(axis=0),                                              # b_h
                    (delta_o[:, np.newaxis, :] * y_h[:, :, np.newaxis]).sum(axis=0),  # W_o
                    delta_o.sum(axis=0),                                              # b_o
            ]

            # Realiza ajustes en los pesos
            for pg, g, d, w in zip(prev_grad, grad, deltas, weights):
                prod = pg * g
                cond_gt_0 = prod > 0
                cond_lw_0 = prod < 0
                cond_gt_eq_0 = prod >= 0

                d[cond_gt_0] = np.minimum(d[cond_gt_0] * eta_plus, delta_max)
                d[cond_lw_0] = np.maximum(d[cond_lw_0] * eta_minus, delta_min)
                g[cond_lw_0] = 0

                w[cond_gt_eq_0] += np.sign(g[cond_gt_eq_0]) * d[cond_gt_eq_0]

            prev_grad = grad

        # Devuelve el error total cometido y la cantidad de pasos usados
        self.iteraciones += n
        return E, n


    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    def entrenar_rprop(self, npc.float_t[:, ::1] X not None,
                       npc.float_t[:, ::1] T not None,
                       npc.float_t min_error=0, npc.float_t delta_0=0.1,
                       npc.float_t delta_min=1e-6, npc.float_t delta_max=50.0,
                       npc.float_t eta_minus=0.5, npc.float_t eta_plus=1.2,
                       long max_pasos=500, callback=None,
                       long frecuencia_callback=1):
        cdef Py_ssize_t patrones = X.shape[0]
        cdef Py_ssize_t entradas = self.entradas
        cdef Py_ssize_t ocultas = self.ocultas
        cdef Py_ssize_t salidas = self.salidas

        assert X.shape[1] == entradas
        assert T.shape[0] == patrones
        assert T.shape[1] == salidas

        cdef Funcion func_h = self.func_h
        cdef Funcion func_o = self.func_o

        # Pesos y bias de la red a entrenar
        cdef npc.float_t[:, ::1] W_h = self.W_h
        cdef npc.float_t[::1]    b_h = self.b_h
        cdef npc.float_t[:, ::1] W_o = self.W_o
        cdef npc.float_t[::1]    b_o = self.b_o

        # Activaciones, salidas y deltas de las capa oculta y de salida
        cdef npc.float_t[::1] z_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] y_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] z_o = np.empty(salidas, dtype=np.float)
        cdef npc.float_t[::1] y_o = np.empty(salidas, dtype=np.float)
        cdef npc.float_t[::1] delta_h = np.empty(ocultas, dtype=np.float)
        cdef npc.float_t[::1] delta_o = np.empty(salidas, dtype=np.float)

        # Gradiente
        cdef npc.float_t[:, ::1] grad_W_h = np.empty_like(W_h)
        cdef npc.float_t[::1]    grad_b_h = np.empty_like(b_h)
        cdef npc.float_t[:, ::1] grad_W_o = np.empty_like(W_o)
        cdef npc.float_t[::1]    grad_b_o = np.empty_like(b_o)

        # Gradiente anterior (inicializado en cero)
        cdef npc.float_t[:, ::1] prev_grad_W_h = np.zeros_like(W_h)
        cdef npc.float_t[::1]    prev_grad_b_h = np.zeros_like(b_h)
        cdef npc.float_t[:, ::1] prev_grad_W_o = np.zeros_like(W_o)
        cdef npc.float_t[::1]    prev_grad_b_o = np.zeros_like(b_o)

        # DELTAS (inicializadas en delta_0)
        cdef npc.float_t[:, ::1] delta_W_h = np.empty_like(self.W_h)
        cdef npc.float_t[::1]    delta_b_h = np.empty_like(self.b_h)
        cdef npc.float_t[:, ::1] delta_W_o = np.empty_like(self.W_o)
        cdef npc.float_t[::1]    delta_b_o = np.empty_like(self.b_o)

        cdef Py_ssize_t i, j, k
        cdef npc.float_t suma
        cdef npc.float_t E = 0.0
        cdef npc.float_t err
        cdef npc.float_t prod

        cdef long frec = 0
        cdef long n = 0

        for i in range(ocultas):
            delta_b_h[i] = delta_0
            for j in range(entradas):
                delta_W_h[j, i] = delta_0

        for i in range(salidas):
            delta_b_o[i] = delta_0
            for j in range(ocultas):
                delta_W_o[j, i] = delta_0

        # Entrena hasta alcanzar max_pasos (puede terminar antes)
        for n in range(1, max_pasos + 1):
            # Calcula el error total y el gradiente resultante
            E = 0.0
            for j in range(ocultas):
                grad_b_h[j] = 0.0
                for i in range(entradas):
                    grad_W_h[i, j] = 0.0

            for j in range(salidas):
                grad_b_o[j] = 0.0
                for i in range(ocultas):
                    grad_W_o[i, j] = 0.0

            for i in range(patrones):
                # Calcula las activaciones y salidas de las neuronas de la capa oculta
                for j in range(ocultas):
                    suma = b_h[j]
                    for k in range(entradas):
                        suma += X[i, k] * W_h[k, j]
                    z_h[j] = suma
                    y_h[j] = func_h.eval(suma)

                # Calcula las activaciones y salidas de las neuronas de la capa de salida
                # También calcula el error cometido en cada una de las salidas y el gradiente,
                # el cual acumula para obtener el gradiente total (todos los patrones).
                for j in range(salidas):
                    suma = b_o[j]
                    for k in range(ocultas):
                        suma += y_h[k] * W_o[k, j]
                    z_o[j] = suma
                    y_o[j] = func_o.eval(suma)

                    # Calcula el error en la salida
                    err = T[i, j] - y_o[j]
                    E += err ** 2

                    # Acumula la información del gradiente para este patrón
                    delta_o[j] = err * func_o.deriv(z_o[j])
                    grad_b_o[j] -= delta_o[j]
                    for k in range(ocultas):
                        grad_W_o[k, j] -= delta_o[j] * y_h[k]

                # Propaga el error hacia atrás y calcula el gradiente del Error
                # con respecto a los pesos de la capa oculta.
                for j in range(ocultas):
                    suma = 0.0
                    for k in range(salidas):
                        suma += delta_o[k] * W_o[j, k]
                    delta_h[j] = func_h.deriv(z_h[j]) * suma

                    grad_b_h[j] -= delta_h[j]
                    for k in range(entradas):
                        grad_W_h[k, j] -= delta_h[j] * X[i, k]

            # Calcula el error cuadrático medio
            E /= 2.0 * patrones   #  E  <-- (1/2 * sum((t - y) ** 2)) / patrones

            if callback is not None:
                frec += 1
                if frec >= frecuencia_callback:
                    if callback(self, np.asarray(X), np.asarray(T), n=n, E=E):
                        break
                    frec = 0

            # Si el error es menor al mínimo error buscado, termina
            if E <= min_error:
                break

            # Ajusta los pesos de acuerdo a los DELTAS
            for j in range(salidas):
                prod = grad_b_o[j] * prev_grad_b_o[j]
                if prod < 0:
                    delta_b_o[j] *= eta_minus
                    if delta_b_o[j] < delta_min:
                        delta_b_o[j] = delta_min

                    prev_grad_b_o[j] = 0;
                else:
                    if prod > 0:
                        delta_b_o[j] *= eta_plus
                        if delta_b_o[j] > delta_max:
                            delta_b_o[j] = delta_max

                    if grad_b_o[j] > 0:
                        b_o[j] -= delta_b_o[j]
                    elif grad_b_o[j] < 0:
                        b_o[j] += delta_b_o[j]

                    prev_grad_b_o[j] = grad_b_o[j];


                for i in range(ocultas):
                    prod = grad_W_o[i, j] * prev_grad_W_o[i, j]
                    if prod < 0:
                        delta_W_o[i, j] *= eta_minus
                        if delta_W_o[i, j] < delta_min:
                            delta_W_o[i, j] = delta_min

                        prev_grad_W_o[i, j] = 0;
                    else:
                        if prod > 0:
                            delta_W_o[i, j] *= eta_plus
                            if delta_W_o[i, j] > delta_max:
                                delta_W_o[i, j] = delta_max

                        if grad_W_o[i, j] > 0:
                            W_o[i, j] -= delta_W_o[i, j]
                        elif grad_W_o[i, j] < 0:
                            W_o[i, j] += delta_W_o[i, j]

                        prev_grad_W_o[i, j] = grad_W_o[i, j];


            for j in range(ocultas):
                prod = grad_b_h[j] * prev_grad_b_h[j]
                if prod < 0:
                    delta_b_h[j] *= eta_minus
                    if delta_b_h[j] < delta_min:
                        delta_b_h[j] = delta_min

                    prev_grad_b_h[j] = 0;
                else:
                    if prod > 0:
                        delta_b_h[j] *= eta_plus
                        if delta_b_h[j] > delta_max:
                            delta_b_h[j] = delta_max

                    if grad_b_h[j] > 0:
                        b_h[j] -= delta_b_h[j]
                    elif grad_b_h[j] < 0:
                        b_h[j] += delta_b_h[j]

                    prev_grad_b_h[j] = grad_b_h[j];


                for i in range(entradas):
                    prod = grad_W_h[i, j] * prev_grad_W_h[i, j]
                    if prod < 0:
                        delta_W_h[i, j] *= eta_minus
                        if delta_W_h[i, j] < delta_min:
                            delta_W_h[i, j] = delta_min

                        prev_grad_W_h[i, j] = 0;
                    else:
                        if prod > 0:
                            delta_W_h[i, j] *= eta_plus
                            if delta_W_h[i, j] > delta_max:
                                delta_W_h[i, j] = delta_max

                        if grad_W_h[i, j] > 0:
                            W_h[i, j] -= delta_W_h[i, j]
                        elif grad_W_h[i, j] < 0:
                            W_h[i, j] += delta_W_h[i, j]

                        prev_grad_W_h[i, j] = grad_W_h[i, j];

        # Devuelve el error total cometido y la cantidad de pasos usados
        self.iteraciones += n
        return E, n
