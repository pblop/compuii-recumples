all: recumples.s19

recumples.rel: recumples.asm
	as6809 -o recumples.asm
recumples.s19: recumples.rel
	aslink -s recumples.rel

# Recumples con simbolos
recumples_s.rel: recumples.asm
	as6809 -a -o recumples_s.rel recumples.asm
recumples_s.s19: recumples_s.rel
	aslink -s -m -w recumples_s.rel

run: recumples.s19
	m6809-run -C recumples.s19
debug: recumples_s.s19
	m6809-run -d -C recumples_s.s19
tam: recumples.s19
	@echo $(shell cat recumples.s19 | ./calculaLongitud.sh) bytes
testReubic: recumples.rel
	./comprobarReubicable.sh recumples
testCorrecto: recumples.asm
	./tamano.py
test: testReubic testCorrecto
	


clean:
	rm recumples.rel recumples.s19 recumples_s.rel recumples_s.s19

