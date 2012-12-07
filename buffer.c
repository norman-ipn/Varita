#include "buffer.h"

void agregarBuffer(char elemento, char arreglo[])
{
	int i = 0;
	for (i = 0; arreglo[i] != '\0'; i++)
	{
	}

	if (i <= 9)
	{
		arreglo[i] = elemento;
	}
	else
	{
		for (i = 0; i < 9; i++)
		{
			arreglo[i] = arreglo[i + 1];
		}

		arreglo[9] = elemento;
	}
}

void limpiarBuffer(char arreglo[])
{
	int i = 0;
	for (i = 0; i <= 9; i++)
	{
		arreglo[i] = '\0';
	}
}

void imprimirBuffer(char arreglo[])
{
	int i = 0;
	for (i = 0; i <= 9; i++)
	{
		printf("%c", arreglo[i]);
	}
	printf("\n");
}
