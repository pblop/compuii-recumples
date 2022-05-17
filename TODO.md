# TODO
- [ ] Cambiar tablames para que sea reubicable.
       Para ello, hacemos que el primer elemento sea 0x0,
       El segundo sea febrero-enero
       El tercero sea marzo-febrero
       ...

       Luego utilizamos el valor de estos elementos como el índice con el que accedemos
       a la array de meses que empieza en enero.

- [x] Utilizar variables auxiliares en vez del stack U.

- [x] Cambiar nCumples para que no sea BCD.
  - [x] Cambiar i para que no sea BCD.

  - [ ] Forma 1. A la hora de imprimir i, convertirla a BCD según la imprimimos.
  - [x] Forma 2. Tener otra variable iBCD que vamos incrementando, y luego imprimir eso.

# OPTIMIZACIONES
- [ ] Podemos hacer que imprimirBCD sean funciones separadas, en vez de comparar, así nos ahorramos
      código que salta de una subfunción a otra.
- [ ] Puede ser que podamos generar tabladiasmes con pocas líneas de código. En concreto con menos
      líneas de las que usamos actualmente, y acceder a ellas con página directa
