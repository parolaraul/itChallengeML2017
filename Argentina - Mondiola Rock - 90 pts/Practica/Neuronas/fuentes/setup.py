import numpy
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(cmdclass = {'build_ext': build_ext},
      name = 'Perceptron',
      ext_modules=[Extension('cperceptron', ['cperceptron.pyx'])],
      include_dirs=[numpy.get_include()],
)

setup(cmdclass = {'build_ext': build_ext},
      name = 'Red Neuronal Artificial entrenada con Backpropagation',
      ext_modules=[Extension('cbackpropagation', ['cbackpropagation.pyx'])],
      include_dirs=[numpy.get_include()],
)
