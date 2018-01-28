# -*- coding: utf-8 -*-
"""
@author: Germán L. Osella Massa (german.osella at nexo.unnoba.edu.ar)
"""
import numpy as np


def escalar(datos, margen_adicional=0, minimos=None, maximos=None):
    """
    Recibe datos cuyos valores se encuentran en el intervalo [minimos, maximos],
    y los escala  de forma que queden en el intervalor [0, 1].
    Adicionalmente, puede especificarse un margen de seguridad, que amplía el
    intervalo entre [minimos, maximos] en un porcentaje dado por margen_adicional.
    El porcentaje debe expresarse como un valor entre 0 y 100 incluidos.
    Si no se especifican los mínimos o los máximos, se los calcula a partir
    del conjunto de datos suministrado.
    Si no se especifica el margen adicional, se asume que es cero.
    """
    if minimos is None:
        minimos = datos.min(axis=0)
    if maximos is None:
        maximos = datos.max(axis=0)
    delta = (maximos - minimos)
    if margen_adicional:
        margen = delta * margen_adicional / 100.0
        minimos -= margen
        maximos += margen
        delta = (maximos - minimos)
    return (datos - minimos) / delta


def generar_patrones(X, T, porcentaje_division=90):
    """
    Sepera las patrones recibidos en dos grupos: uno para entrenamiento y
    otro para prueba.

    El parámetro 'X' es un array con los datos de cada patrón.
    El parámetro 'T' es un array que indica la clase de cada uno de
    los patrones recibidos en 'X'.
    El parámetro 'porcentaje_division' determina cuantos patrones se usarán
    para entrenamiento.

    La función devuelve:
        - Un array que contiene las clases únicas encontradas.
        - Un diccionario donde cada clase tiene asociada los patrones
          para el entrenamiento.
        - Un diccionario donde cada clase tiene asociada los patrones
          para las pruebas.
    """
    clases = np.unique(T)
    patrones_entrenamiento = {}
    patrones_prueba = {}
    for clase in clases:
        # Obtiene los patrones de esta clase
        patrones_de_la_clase = X[T.flat == clase]

        # Mezcla al azar los índices de los patrones
        indices = list(range(len(patrones_de_la_clase)))
        np.random.shuffle(indices)

        # Divide los patrones en 2 grupos: entrenamiento y prueba
        division = len(patrones_de_la_clase) * porcentaje_division // 100
        patrones_entrenamiento[clase] = patrones_de_la_clase[indices[:division]]
        patrones_prueba[clase] = patrones_de_la_clase[indices[division:]]

    return clases, patrones_entrenamiento, patrones_prueba


def armar_patrones_y_salida_esperada(clases, patrones):
    """
    Construye los patrones y la salida esperada a partir de las clases y patrones
    producidos por la función generar_patrones.

    El parámetro 'clases' es un array que contiene las clases únicas encontradas.
    El parámetro 'patrones' es un diccionario donde cada clase tiene asociada
    los patrones correspondiente a esa clase.

    La función devuelve:
        - Un array X con todos los patrones.
        - Un array T con tantas columnas como clases y tantas filas como patrones,
          conteniendo un único 1 en la columna de la clase asociada a cada patrón.
    """
    # Arma los patrones
    X = np.vstack(patrones[c] for c in clases)

    # Arma las respuestas esperadas
    T = np.zeros((len(X), len(clases)))
    i = 0
    for c, f in enumerate(np.cumsum([len(patrones[c]) for c in clases])):
        T[i:f, c] = 1
        i = f

    return X, T


def matriz_de_confusion(T, Y, sólo_respuestas_válidas=True):
    """
    Retorna la matriz de confusión a partir de las respuestas esperadas
    (que determinan las clases a analizar) y de las respuestas arrojadas
    por la red neuronal.

    Si el parámetro sólo_respuestas_válidas es True, se calcula una matriz
    de confusión donde se cuenta únicamente la cantidad de respuestas válidas
    (es decir, que corresponden a una clase exactamente) para cada posible
    clase. De esa forma, el total de respuestas por cada clase puede ser menor
    al total esperado si existen respuestas pertenecientes a más de una clase
    o a ninguna.

    Si el parámetro sólo_respuestas_válidas es False, se calcula una matriz
    donde se contabiliza la cantidad de respuestas por cada posible combinación
    de clases. En este caso, la matriz tendrá 2 ** clases columnas (una por cada
    combinación posible).

    La función retorna la matriz calculada y la clase que identifica a cada una
    de las columnas de la matriz.    
    """
    n_clases = T.shape[1]

    # Arma las posibles clases o respuestas esperadas
    clase = np.zeros(n_clases, dtype=int)
    clase[0] = 1
    respuestas_esperadas = [np.roll(clase, i) for i in range(n_clases)]

    if sólo_respuestas_válidas:
        # La matriz es cuadrada y las respuestas posibles a contemplar 
        # son las respuestas de las clases esperadas.
        matriz = np.zeros((n_clases, n_clases))
        salidas_esperadas = respuestas_esperadas
    else:
        # La matriz de confusión tiene una columna por cada combinación
        # posible de las salidas y las respuestas a contemplar son todas
        # esas combinaciones.
        matriz = np.zeros((n_clases, 2 ** n_clases))
        salidas_esperadas = list(respuestas_esperadas)
        for i in range(2 ** n_clases):
            s = np.fromiter('{0:0{1}b}'.format(i, n_clases)[::-1], int)
            if s.sum() != 1:
                salidas_esperadas.append(s)
    
    # Calcula la matriz pedida
    for i, respuesta in enumerate(respuestas_esperadas):
        mascara = (T == respuesta).all(axis=1)
        for j, salida in enumerate(salidas_esperadas):
            matriz[i, j] = (Y[mascara] == salida).all(axis=1).sum()

    return matriz, salidas_esperadas
