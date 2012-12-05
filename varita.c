#include <stdio.h>

#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "psmoveapi/psmove.h"

int main(void)
{
	//Conecta al PlayStation Move
	PSMove *move = NULL; //<< siempre inicialicen sus variables.
	move = psmove_connect();
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

			printf("%c\n", cuadrante);
		}

		//printf("%c", cuadrante);

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
