# Peru 

pi = open('pi', 'r').read()

def is_prime(n):
  if n == 2 or n == 3: return True
  if n < 2 or n%2 == 0: return False
  if n < 9: return True
  if n%3 == 0: return False
  r = int(n**0.5)
  f = 5
  while f <= r:
    if n%f == 0: return False
    if n%(f+2) == 0: return False
    f +=6
  return True 

#number as string
def is_Capicua(given_str):
    if (len(given_str) % 2 == 0):
        a,b = given_str[:len(given_str)/2], given_str[len(given_str)/2:][::-1]
    else:
        a,b = given_str[:(len(given_str)-1)/2], given_str[(len(given_str)+1)/2:][::-1]
    return a==b

counter = 0
for i in range(0,len(pi)):
	numero = pi[i]+pi[i+1]+pi[i+2]+pi[i+3]+pi[i+4]+pi[i+5]+pi[i+6]
	if is_prime(int(numero)) and is_Capicua(numero):
		counter+=1
		print numero
	if counter == 7:
		print numero,i
		break