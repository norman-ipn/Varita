%{
#include <stdio.h>
#include <string.h>
#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "psmoveapi/psmove.h"
#include "buffer.h"

//El arreglo donde se almacenarán los cuadrantes por donde se ha pasado.
char cuadrantes[20];
int t = 0;
IplImage *frame;
int yylex(); 
int yyerror(const char *p) {  } // Aqui se van a registrar errores, pero no se harán acciones.
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
E: A B D C A STOP {  
			printf("Ataque");//ataque("circulo"); 
	             	//limpiarBuffer(cuadrantes);
	          }

E: B A C D STOP   { printf("Ataque");//ataque("md"); 
		    //limpiarBuffer(cuadrantes); 
		  }

E: A B D C STOP   { printf("Ataque");//ataque("mdi"); 
		    //limpiarBuffer(cuadrantes);
		  }

E: C D B STOP { printf("Ataque");//ataque("lrh"); 
		//limpiarBuffer(cuadrantes); 
	      }

E: B A C STOP { printf("Ataque");//ataque("lrv");  
		//limpiarBuffer(cuadrantes); 
	      }

E: A B STOP { printf("Ataque");//ataque("lh"); 
	      //limpiarBuffer(cuadrantes);
            }

E: A C D B STOP { printf("Ataque");//ataque("u");
	          //limpiarBuffer(cuadrantes); 
		}

E: A C STOP { printf("Ataque");//ataque("lvizq"); 
	      //limpiarBuffer(cuadrantes); 
	    }

E: C A B D STOP { printf("Ataque");//ataque("escalon"); 
		  //limpiarBuffer(cuadrantes); 
	        }

E: A C D STOP { printf("Ataque");//ataque("l"); 
		//limpiarBuffer(cuadrantes); 
              }

E: A B D STOP { printf("Ataque");//ataque("linversa"); 
		//limpiarBuffer(cuadrantes); 
	      }

E: B D STOP { printf("Ataque");//ataque("lvder"); 
	      //limpiarBuffer(cuadrantes); 
	    }

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

	int i=0;
	
	for(i=0; i < 20; i++)
	{
		chaR=cuadrantes[i];
		if(chaR == 'A')
		{
			return a;
		} 
		else if(chaR == 'B')
		{
			return b;
		} 
		else if(chaR == 'C')
		{
			return c;
		}
		else if(chaR == 'D')
		{
			return d;
		}
	}

	return STOP;
}


void dibujaTexto(char texto[]) {
	CvFont font;
	CvPoint pt1;
	cvInitFont( &font, CV_FONT_VECTOR0, 0.5, 0.5, 0, 2.0, CV_AA);

	pt1.x = 150;
	pt1.y = 150;

	if(!(strcmp(texto, "u"))){
		cvPutText(frame, "Ataque U", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "circulo"))){
		cvPutText(frame, "Ataque circulo", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "escalon"))){
		cvPutText(frame, "Ataque Escalon", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "ml"))){
		cvPutText(frame, "Ataque media luna", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "mli"))){
		cvPutText(frame, "Ataque media luna invertida", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "lrh"))){
		cvPutText(frame, "Ataque L reflejada horizontal", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "lrv"))){
		cvPutText(frame, "Ataque L reflejada vertical", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "lh"))){
		cvPutText(frame, "Ataque linea horizontal", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "lvizq"))){
		cvPutText(frame, "Ataque linea vertical izquierda", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "lvder"))){
		cvPutText(frame, "Ataque linea vertical derecha", pt1, &font,CV_RGB(99,170,251) );
	}

	if(!(strcmp(texto, "l"))){
		cvPutText(frame, "Ataque L", pt1, &font,CV_RGB(99,170,251) );
	}	

	if(!(strcmp(texto, "linversa"))){
		cvPutText(frame, "Ataque L inversa", pt1, &font,CV_RGB(99,170,251) );
	}
}

void ataque(char texto[]){
/*int count=0;

	while(count<10000){
       		dibujaTexto(texto);
       		count=count++;
	}*/
printf("Ataque");
}

int main(void)
{
	//Conecta al PlayStation Move
	PSMove *move = NULL;
	move = psmove_connect();


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
	CvScalar hsv_min = cvScalar(151, 15, 250, 0);
	CvScalar hsv_max = cvScalar(153, 17, 256, 0);
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
		frame = cvQueryFrame(camara);
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
			t++;
			if (t == 20)
			{
				yyparse();
				limpiarBuffer(cuadrantes);
			}
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

