all: run

run: varita
	./varita

varita: varita.c
	gcc varita.c -lpsmoveapi -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_objdetect -o varita

clean:
	rm varita
