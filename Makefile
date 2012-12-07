all: run

run: varita
	./varita

varita: varita.c buffer.o
	gcc varita.c buffer.o -lpsmoveapi -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_objdetect -o varita

buffer.o: buffer.c
	gcc -c buffer.c

clean:
	rm varita buffer.o
