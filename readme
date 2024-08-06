Esse é uma simples biblioteca que implementa uma fila

Uma fila é um tipo de estrutura de dados semelhante a uma array, porém ela dá a volta em si, permitindo que ao adicionarmos uma nova informação em uma fila cheia, a informação mais antiga é substituída pela mais nova.

Além disso, ao retirarmos um valor de uma fila, sempre retiramos o valor mais antigo primeiro e incrementamos o contador

---

# Motivação:

Inspirado na competição do H2 Challenge em que eu tive que fazer uma média móvel, eu decidi implementar uma fila em zig
no código do h2 havia o seguinte:

```c
for(int i = 0; i<len-1; i++){
 array[i+1] = array[i];
}
array[0] = val;
media = 0;
for(int i = 0; i<len; i++){
  media += array[i]
}
media = media/len
```

Essa função era executada a cada 20ms, isso é extremamente ineficiente, pois precisamos percorrer e escrever na array toda vez que um valor novo é inserido, note que isso é O(N), mas pode ser O(1) utilizando uma fila.
