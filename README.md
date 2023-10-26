# INEL 4206 – Microprocesadores COREMISE
Diseño de Aplicación con Manejo de Interrupciones y Temporizadores

# Introducción
El MSP430FR6989 Launchpad provee múltiples opciones para desarrollar aplicaciones. Entre 
ellas se encuentran lo puertos digitales, la pantalla LCD, el manejo de interrupciones y múltiples 
temporizadores (timers). En esta actividad se diseñará e implementará una aplicación que hará 
uso estas tres herramientas. 

# Descripción General del Sistema 
Se diseñará un sistema para implementar un contador regresivo de minutos y segundos
(Coremise) utilizando el MSP430FR6989 Launchpad. El Coremise tendrá dos dígitos para los 
minutos y dos dígitos para los segundos. Para presentar los cuatro dígitos se utilizarán los 
cuatro caracteres alfanuméricos de la extrema derecha del despliegue. La siguiente figura 
muestra como luciría el valor 25:48 dentro de la organización del despliegue.

# Operación del Sistema
Inicialmente en la pantalla se identificará al equipo que diseñó el sistema. Aparecerá en 
pantalla “TEAM##” en donde ## son los dos dígitos que identifican al número del equipo. Al 
presionar el botón S1 aparecerá el nombre (al menos los primeros 6 caracteres del mismo) del 
primer integrante del equipo (seleccionado por orden alfabético de apellidos). Si se sigue 
presionando S1 seguirán apareciendo los nombres (por orden alfabético de apellidos) de los 
demás integrantes del equipo. Luego del último integrante al presionar S1 se regresa a 
identificar en pantalla al equipo. El diagrama de estados se muestra en la Figura 2.
Si, al identificar en pantalla al número del equipo se presiona S2, el sistema se moverá a la 
configuración del conteo. En pantalla aparecerá el conteo inicial en 00:00. Para ello se 
utilizarán los cuatro caracteres de la extrema derecha de la pantalla. Los valores de cada dígito 
se inicializarán de izquierda a derecha. Al entrar en la configuración de conteo el primer dígito 
de la izquierda aparecerá de forma intermitente. Cada vez que se presione S1 se incrementará 
en 1 el valor del dígito. Luego del 9 el valor regresa a 0. Al presionar S2 el sistema se mueve al 
próximo dígito de la derecha. El dígito de la izquierda ya no aparecerá de forma intermitente y 
el dígito que se está configurando sí aparecerá de forma intermitente hasta que se presione S2. 
El proceso continúa hasta configurar el valor de cada dígito. Luego de configurar el valor del 
último dígito, al presionar S2 el sistema se mueve al estado Ready en el que ninguno de los 
dígitos estará de forma intermitente y el sistema está listo para comenzar con el conteo 
regresivo. Al presionar S2 nuevamente el sistema comenzará a contar de forma regresiva con 
una frecuencia de 1 Hz. Mientras el sistema está contando, si se presiona S1, la frecuencia del 
conteo se duplicará (esto hace que el conteo vaya al doble de la velocidad que antes de 
presionar S2). Si durante el conteo se presiona S2 el conteo pausará. Estando en pausa, si se 
presiona S2 el conteo se reanudará. Cuando el conteo llegue a 00:00 se detendrá. Estando en
pausa, si se presiona S1, el sistema regresa a su estado inicial identificando al equipo que lo 
diseñó.

# Requisitos Técnicos
Luego de la inicialización del sistema y que aparezca el TEAM## en el despliegue, el MCU 
entrará en modo Low Power y sólo saldrá del mismo para atender subrutinas de manejo de 
interrupciones. Cuando el procesador no tenga tareas para realizar se mantendrá en modo Low 
Power. Las lecturas del estado de los botones se realizarán como atenciones a peticiones de 
interrupción que generarán los mismos. No se leerán utilizando polling. Todos los controles de 
tiempo en el sistema se realizarán utilizando el temporizador Timer_A0. No se implementarán 
por medio de estructuras iterativas.
El programa tiene que ser modular dividido en subrutinas. Cada subrutina terminará con un ret 
y en la medida en que sea posible operará sobre valores que recibirá por medio de registros o 
del stack.  
No se realizará brincos de una subrutina a otra por medio de instrucciones que no sean call.

# Reporte
Portada: Título, curso, profesor, integrantes, fecha
Introducción: Descripción general del producto. 1 página
Proceso de solución del problema: Cómo se realizó el análisis del problema, se determinaron las tareas, 
qué tuvieron que buscar e investigar (con referencias). Entre las imágenes incluirá el 1 a 3 páginas
Distribución de tareas: Tabla mostrando las tareas que realizaron (investigaciones, pruebas, algoritmos, 
creación de código, etc.) y los integrantes del equipo a que realizaron las mismas.

Ejemplo:  
Tarea Persona a cargo Comentarios
Crear subrutina que recibe un dígito decimal en 
R5 y la posición del dígito en R6 y escribe 
presenta el mismo en el despliegue.

# Código del programa: Copia del archivo con el código del programa. Letra Courier New o Consolas
Notas: El reporte se entregará en formato compatible con MS-Word (.docx o .doc). El nombre del 
archivo con el reporte será CoremiseGr##SuNombre. ## son los dos dígitos que identifican su equipo.
SuNombre es su primer apellido con la primera letra en mayúscula y las demás en minúsculas, seguido
de su primer nombre (mismo formato del apellido). Para el nombre del archivo no se utilizarán acentos, 
diéresis, tildes, ni carácter alguno que no sea letra o dígito. No escribir correctamente el nombre del 
archivo implica una deducción del 10% del total de puntos de la tarea.

# Entrega de código
; Equipo ##  
; Integrante 1  
; % de contribución  
; Integrante 2  
; % de contribución  
; Integrante 3  
; % de contribución  
; Integrante 4  
; % de contribución  

# Documentación de las subrutinas
Nombre de la subrutina  
Objetivo: Propósito de la subrutina. Debe hacer sólo una tarea  
Precondiciones: Lo que siempre tiene que ser cierto antes de la ejecución de la subrutina para que la 
misma funcione de manera correcta  
Postcondiciones: Lo que siempre será cierto luego de ejecutar la subrutina
Autor/a: Persona que diseñó la subrutina  
Fecha: Cuándo se creó esta versión de la subrutina  

Ejemplo  
DecimalABinario  
;Objetivo: Convertir dos dígitos decimales individuales almacenados en R5 y R6 (R5:R6) en un entero de 
16 bits  
;Precondiciones: El dígito que representa las decenas está almacenado en R5 y las unidades en R6.  
;Postcondiciones: R8 contiene el valor entero representado por los dígitos individuales en R5 y R6.  
;Autor: Pepito Pérez  
;Fecha: 3/nov/2021  

Entregará el programa de la siguiente forma. En un archivo de texto (.txt) tendrá el código completo del 
programa. Este archivo se utilizará para copiar el código a un programa nuevo en el IAR y probar el 
funcionamiento. Si el programa copiado de esta forma no funciona no recibe puntos en la tarea. El 
nombre de este archivo será ChronoGroup## en donde donde ## es el número del grupo con dos 
dígitos. En adición entregará el fólder que contiene todos los fólders y archivos de su workspace. 
Comprimirá el fólder y el archivo tiempo texto en un solo archivo (.zip o .rar) con el nombre 
ChronoGroup## en donde ## es el número del grupo con dos dígitos.

# Entrega de vídeo
Vídeo de la operación de la aplicación: Muestra que el programa cumple con todos los requisitos. 
Comienza con el estado inicial y evidencia que pasa por todos los estados y transiciones de forma 
correcta y que cumple con todos y cada uno de los requisitos. Tiene que comenzar mostrando cómo 
ejecutar el programa en el IDE y luego continuar mostrando sólo la operación en el Launchpad sin el IDE 
y luego de apagar y encender nuevamente el Launchpad. Tome en consideración que es posible que el 
dispositivo que utilice para tomar el vídeo tenga más resolución de la que hace falta. Así que verifique 
cuál es la resolución más baja con la cual puede tomar un vídeo que sea vea bien. De esta forma el 
tamaño del archivo no será más grande de lo necesario. El archivo tiene que estar en formato .mp4 y el 
nombre tiene que ser Gr##Coremise en donde ## es el número del grupo con dos dígitos.

# Hoja de Autoevaluación y Evaluación de los Pares
Entregará el archivo de Excel completado. El nombre del archivo será SuNombreGr## en donde 
SuNombre seguirá el mismo formato que el nombre del reporte.
