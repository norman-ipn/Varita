all: run

run: varita
	./varita

varita: lex.yy.c buffer.o
	gcc lex.yy.c buffer.o -lpsmoveapi -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_objdetect -o varita -ll

lex.yy.c: varita.l
	flex varita.l

buffer.o: buffer.c
	gcc -c buffer.c

clean:
	rm varita buffer.o lex.yy.c
