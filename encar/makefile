DIA := 31
MES := 7
ANO := 1969

all: encar.s19

# recumples.asm no tiene un día, mes o año introducido, sino un espacio vacío para que se lo añadamos antes
# de cada compilación facilmente, con un script.
# Generamos un archivo recumples_.asm que tiene ya los días, meses y años escritos.
encar_.asm: clean encar.asm
	cp encar.asm encar_.asm
	sed -i -e 's/{ANO}/$(ANO)/g' encar_.asm
	sed -i -e 's/{MES}/$(MES)/g' encar_.asm
	sed -i -e 's/{DIA}/$(DIA)/g' encar_.asm

encar.rel: clean encar_.asm
	as6809 -o encar.rel encar_.asm
encar.s19: encar.rel
	aslink -s encar.rel

# Recumples con simbolos
encar_s.rel: clean encar_.asm
	as6809 -a -o encar_s.rel encar_.asm
encar_s.s19: encar_s.rel
	aslink -s -m -w encar_s.rel

run: encar.s19
	m6809-run -C encar.s19
debug: encar_s.s19
	m6809-run -d -C encar_s.s19
tam: encar.s19
	@echo $(shell cat encar.s19 | /mnt/c/Users/Encarna/Desktop/ejercicios/compii/final/tools/calculaLongitud.sh) bytes
testReubic: encar.rel
	/mnt/c/Users/Encarna/Desktop/ejercicios/compii/final/tools/comprobarReubicable.sh encar
testCorrecto: encar.s19
	/mnt/c/Users/Encarna/Desktop/ejercicios/compii/final/tools/comprobarSalida.sh
test: testReubic testCorrecto
	


clean:
	rm -f encar_s.asm encar.rel encar.s19 encar_s.map encar_s.rel encar_s.s19 encar.lst 

