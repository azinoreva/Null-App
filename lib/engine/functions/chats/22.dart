// this recieves contact and saves it - It is a callback function, the SSE is the one that calls it when it recieves it. 

So first it takes whatever is given, then runs it through the decrypt function, using its private key. Then it reads it from string to json, then adds it to the contact database. 


Asides the other functions 