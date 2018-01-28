import numpy as np

def mejorVecino(posicion):
    x,y = posicion[0],posicion[1]
    precio = 99999
    if (data[x-1,y+1] < precio):
        precio = data[x-1,y+1]
    elif (data[x,y+1] < precio):
        precio = data[x,y+1]
    elif (data[x,y+2] < precio):
        precio = data[x,y+2]
    elif (data[x,y+3] < precio):
        precio = data[x,y+3]
    elif (data[x+1,y-1] < precio):
        precio = data[x+1,y-1]
    elif (data[x+1,y] < precio):
        precio = data[x+1,y]
    elif (data[x+1,y+2] < precio):
        precio = data[x+1,y+2]
    elif (data[x+2,y] < precio):
        precio = data[x+2,y]
    elif (data[x+2,y+1] < precio):
        precio = data[x+2,y+1]
    elif (data[x+3,y] < precio):
        precio = data[x+3,y]
    return precio

def costo(ciudad):
    return PEAJE + data[ciudad]

v = []
pos = [0,0]
asd = "4 2\n30 92 36 10\n38 85 60 16\n41 13 5 68\n20 97 13 802"
data = asd.split('\n')[1:]
PEAJE = asd.split('\n')[:1][0][2]
TAM = asd.split('\n')[:1][0][0]
info = np.asmatrix([[30,92,36,10],[38,85,60,6],[41,13,5,68],[20,97,13,802]])

print(data)
while pos != [TAM,TAM]:
    pos = mejorVecino(pos)
    v.append(pos)
cuesta = 0
for i in rang(0,len(v)):
    cuesta+=costo(v[i])