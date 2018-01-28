## Ucrania
import numpy as np
import base64

data = np.array(open('level8', 'r').read().split('\n'))

# Considerar los string como arreglos de caracteres ascii, x[i] es el i-esimo caracter
def decrypt(key, file): 
	for n in file:
		c = base64.b64decode(n)
		k = key
		p = []
		for i in range(0,len(c)):
			# "" += asci c[i]-k[i]-i	
			p.append((ord(c[i]) - ord(k[i]) - i) % 256)
			k+=chr(p[i])
	s = "".join([chr(c) for c in p])
	return s

## user: meltedgalloway 
## pass: wcS@D6d6

asd=decrypt('meltedgalloway',data)
print(asd)

def crackear(file):
	for n in file:
		c = base64.b64decode(n)
		p = "meltedgalloway"
		k = []
#		for i in range(len(c),0,-1):
#			k.append()
#		print c
#crackear(data)