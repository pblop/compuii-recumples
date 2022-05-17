DIA := 31
MES := 7
ANO := 1969

all: recumples.s19

# recumples.asm no tiene un día, mes o año introducido, sino un espacio vacío para que se lo añadamos antes
# de cada compilación facilmente, con un script.
# Generamos un archivo recumples_.asm que tiene ya los días, meses y años escritos.
recumples_.asm: clean recumples.asm
	cp recumples.asm recumples_.asm
	sed -i -e 's/{ANO}/$(ANO)/g' recumples_.asm
	sed -i -e 's/{MES}/$(MES)/g' recumples_.asm
	sed -i -e 's/{DIA}/$(DIA)/g' recumples_.asm

recumples.rel: clean recumples_.asm
	as6809 -o recumples.rel recumples_.asm
recumples.s19: recumples.rel
	aslink -s recumples.rel

# Recumples con simbolos
recumples_s.rel: clean recumples_.asm
	as6809 -a -o recumples_s.rel recumples_.asm
recumples_s.s19: recumples_s.rel
	aslink -s -m -w recumples_s.rel

run: recumples.s19
	m6809-run -C recumples.s19
debug: recumples_s.s19
	m6809-run -d -C recumples_s.s19
tam: recumples.s19
	@echo $(shell cat recumples.s19 | ./tools/calculaLongitud.sh) bytes
testReubic: recumples.rel
	./tools/comprobarReubicable.sh recumples
testCorrecto: recumples.s19
	./tools/comprobarSalida.sh
test: testReubic testCorrecto
	


clean:
	rm -f recumples_.asm recumples.rel recumples.s19 recumples_s.map recumples_s.rel recumples_s.s19 recumples.lst 

