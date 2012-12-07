all: run

run: varita
	./varita

varita: gramaticasVarita.tab.c buffer.o
	gcc gramaticasVarita.tab.c buffer.o -lpsmoveapi -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_objdetect -o varita

gramaticasVarita.tab.c: gramaticasVarita.y
	bison gramaticasVarita.y

buffer.o: buffer.c
	gcc -c buffer.c

clean:
	rm varita buffer.o
