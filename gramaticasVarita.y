%{
#include <stdio.h>
#include <string.h>
#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "psmoveapi/psmove.h"
#include "buffer.h"

int yylex(); 
int yyerror(const char *p) { printf("Error"); }
%}

//SYMBOL SEMANTIC VALUES
%union {
  char sym;
};
%token <sym> a
%token <sym> b
%token <sym> c
%token <sym> d
%token <sym> STOP
%type  <sym> A 
%type  <sym> B 
%type  <sym> C 
%type  <sym> D 
%type  <sym> E

//GRAMMAR RULES

%%
run: 
  | run E 
  | run error
E: A B D C A STOP { printf("Circulo"); }

E: B A C D STOP   { printf("Media Luna"); }

E: A B D C STOP   { printf("Media Luna invertida"); }

E: C D B STOP { printf("L reflejada horizontalmente"); }

E: B A C STOP { printf("L reflejada verticalmente"); }

E: A B STOP { printf("Línea horizontal"); }

E: A C D B STOP { printf("U"); }

E: A C STOP { printf("Linea vertical (Lado izq)"); }

E: C A B D STOP { printf("Escalón"); }

E: A C D STOP { printf ("L (normal)"); }

E: A B D STOP { printf ("L inversa");}

E: B D STOP { printf("Línea vertial (lado derecho"); }

A: a A
  | a
B: b B 
  | b
C: c C 
  | c
D: d D 
  | d
%%

//FUNCTION DEFINITIONS
int yylex(){
  char chaR;
	while(1){
	scanf("%c",&chaR);
	yylval.sym = chaR;
	
	if(chaR == 'A'){
	return a;
	}
	else if(chaR == 'B'){
	return b;
	}
	else if(chaR == 'C'){
	return c;
	}
	else if(chaR == 'D'){
	return d;
	}
	else if(chaR == ';'){
	return STOP;
	}

	}
}

int main(void)
{
	//Conecta al PlayStation Move
	PSMove *move = NULL;
	move = psmove_connect();

	//El arreglo donde se almacenarán los cuadrantes por donde se ha pasado.
	char cuadrantes[20];
	limpiarBuffer(cuadrantes); //Se inicializa el arreglo.

	if (!move)
	{
		printf("ERROR: No se ha podido establecer la conexión al PlayStation Move\n");
	}

	//Almacena el cuadrante en donde se encuentra
	char cuadrante = '\0';

	//Obtiene el dispositivo de visiòn (càmara)
	CvSize size = cvSize(640, 480);
	CvCapture *camara = cvCaptureFromCAM(0);
	if (!camara)
	{
		printf("ERROR: No se pudo inicializar el dispositivo de visión.\n");
		return -1;
	}

	//Crea la ventana
	cvNamedWindow("Juego Varita", CV_WINDOW_AUTOSIZE);

	//Para poder detectar el color verde del PlayStation Move
	CvScalar hsv_min = cvScalar(150, 10, 250, 0);
	CvScalar hsv_max = cvScalar(155, 20, 256, 0);
	IplImage *hsv_frame = cvCreateImage(size, IPL_DEPTH_8U, 3);
	IplImage *thresholded = cvCreateImage(size, IPL_DEPTH_8U, 1);
	
	//Crea el ciclo para mostrar la captura de video
	while(1)
	{
		//Establece el color del move
		if (move)
		{
			psmove_set_leds(move, 0, 255, 0);
			psmove_update_leds(move);
		}

		//Obtiene el siguiente cuadro
		IplImage *frame = cvQueryFrame(camara);
		if(!frame)
		{
			printf("Fallò la captura del cuadro\n");
			break;
		}

		//Voltea la imagen para ajustar con el usuario
		cvFlip(frame, frame, 1);

		//Convierte de RGB a HSV
		cvCvtColor(frame, hsv_frame, CV_BGR2HSV);		
		//Filtra los colores en el rango dado
		cvInRangeS(hsv_frame, hsv_min, hsv_max, thresholded);

		//Creamos un espacio de memoria para la detecciòn de cìrculos
		CvMemStorage *storage = cvCreateMemStorage(0);

		//Suavizamos la imagen
		cvSmooth(thresholded, thresholded, CV_GAUSSIAN, 9, 9, 0, 0);

		//Detecciòn de cìrculos
		CvSeq* circles = cvHoughCircles(thresholded, storage, CV_HOUGH_GRADIENT, 2, thresholded->height/4, 100, 50, 10, 400);
		
		int i = 0;
		for (i = 0; i < circles->total; i++)
		{
			float *pos = (float *)cvGetSeqElem(circles, i);
			//printf("Detectando en x=%f y=%f r=%f\n", pos[0], pos[1], pos[2]);
			
			cvCircle(frame, cvPoint(cvRound(pos[0]), cvRound(pos[1])), 3, CV_RGB(0, 255, 0), -1, 8, 0);
			cvCircle(frame, cvPoint(cvRound(pos[0]), cvRound(pos[1])), cvRound(pos[2]), CV_RGB(255, 0, 0), 3, 8, 0);
			if (pos[0] < 320 && pos[1] < 240)
			{
				cuadrante = 'A';
				cvRectangle(frame, cvPoint(0, 0), cvPoint(320, 240), CV_RGB(0, 255, 0), -1, 8, 0);
			}

			if (pos[0] < 320 && pos [1] >= 240)
			{
				cuadrante = 'C';
				cvRectangle(frame, cvPoint(0, 240), cvPoint(320, 480), CV_RGB(0, 255, 0), -1, 8, 0);
			}

			if (pos[0] >= 320 && pos[1] < 240)
			{
				cuadrante = 'B';
				cvRectangle(frame, cvPoint(320, 0), cvPoint(640, 240), CV_RGB(0, 255, 0), -1, 8, 0);
			}

			if (pos[0] >= 320 && pos[1] >= 240)
			{
				cuadrante = 'D';
				cvRectangle(frame, cvPoint(320, 240), cvPoint(640, 480), CV_RGB(0, 255, 0), -1, 8, 0);
			}

			agregarBuffer(cuadrante, cuadrantes); //Agrega el caracter al buffer para su lectura.
			imprimirBuffer(cuadrantes); //Imprime los cuadrantes que se han ingresado hasta este momento.
		}

		//Muestra el siguiente cuadro
		cvShowImage("Juego Varita", frame);

		//Con ESC termina el ciclo
		if ((cvWaitKey(10) & 255) == 27) break;
	}
	
	//Finaliza el proceso de captura de video
	cvReleaseCapture(&camara);
	cvDestroyWindow("Juego Varita");	

	//Cierra la conexión con el PlayStation Move
	if(move)
	{
		psmove_disconnect(move);
	}

	return 0;
}
