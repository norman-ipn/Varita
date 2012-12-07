Varita
======

Juego de Varita 

# Objetivo:

Crear  un juego que detecte el movimiento de un control de consola PlayStation Move mediante la librería OpenCV 
para efectuar diferentes ataques modelados mediante gramáticas haciendo uso de Bison.

#Introducción:

La forma para realizar este proyecto es la siguiente:

- Inicio de la cámara web mediante OpenCV (código ya desarrollado).
- Uso de filtros ópticos para la detección de un único color (código ya desarrollado).
- Uso del algoritmo de Hough para la detección de círculos en una imagen (código ya desarrollado).
- Detección de los cuadrantes mediante la posición de la "varita" y su representación en símbolos para facilitar el uso de gramáticas (código ya desarrollado en un 90%).
- Introducción de dicha cadena a un analizador léxico tipo Bison para identificar el tipo de ataque (código próximo a desarrollar).
- Presentación o mensaje a la pantalla del usuario indicando la acción que se ha realizado (código próximo a desarrollar).

#Desarrollo:

Primeramente se deberán instalar tanto las librerías OpenCV como PSMoveAPI 
(Las instrucciones para instalar OpenCV  se encuentran en el archivo OpenCV.odt y las instrucciones para PSMoveApi en el archivo PSMoveAPI.odt).

Posteriormente se mostrará una ventana y con ayuda de un ciclo infinito mostraremos las capturas de la cámara web. Justo en este proceso deberemos hacer uso de la librería PSMoveAPI para poder mostrar un color predefinido y así facilitar la detección de la "varita".

Como siguiente punto, deberemos pasar por diversos filtros. Obviamente debemos capturar un cuadro de nuestra cámara. El primer filtro o "paso" a realizar es la transformación de un espacio RGB (Red, Green, Blue) a HSV (Hue, Saturation, Value) que nos facilita la detección de un color específico. Como segundo filtro deberemos usar un by-pass y sólo permitir un rango de valores para refinar nuestra detección. Posteriormente analizamos la imagen con el algoritmo de Hough para detección de círculos que ya se incluye en OpenCV.

Una vez que tenemos la posición de nuestra varita procedemos a limitar los rangos de área de los cuatro cuadrantes, donde usamos una comparación de posición para indicar si se encuentra en el cuadrante A, B, C o D. Posteriormente pasamos a almacenarlos en una cadena para ser procesada por Bison.

Al analizar esta cadena en Bison, deberemos reconocer los 12 tipos de ataque posibles por el usuario. Donde a cada ataque le corresponderá un mensaje o tipo de retorno. Para esto, creamos funciones con ayuda del OpenCV para dibujar textos en la pantalla que se desvanecerán después de un tiempo.

Esto será el algorítmo básico para resolver este proyecto. Posteriormente se podrán incluir funciones de enlace mediante red y contadores de vida o puntos.

NOTA: El PSMoveAPI solamente se usará para encender el LED del control a un color específico, sin ser de mayor utilidad por el momento. Se usa esta técnica simplemente para facilitar la detección del control utilizado como "varita".