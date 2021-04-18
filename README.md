# DSSD - Trabajo práctico integrador 2020 #

### Aplicacion web para la gestion de medicamentos desarrollado para la materia Desarrollo de software en sistemas distribuidos ###

#### Enunciado ###


_Se desea modelar el proceso de aprobación de medicamentos en un laboratorio internacional._

_Al intentar desarrollar un nuevo medicamento, el equipo elabora un conjunto de protocolos que deben aprobarse durante el período de pruebas, el cual obviamente varía de acuerdo al tipo de medicamento del cual se trata (si es una vacuna, un psicotrópico, un medicamento de venta libre, etc). De esta manera, una vez elaborados los protocolos, el jefe del proyecto inicia el proceso y configura el mismo, cargando todos los protocolos necesarios con sus etapas internas, cuáles son secuenciales y cuáles paralelas, y los responsables del equipo a cargo de cada una de ellas.
Una vez configurado el proyecto, se lanzan todas las actividades propias del protocolo/s activos al momento, tomando la duración, tareas internas y responsables de cada actividad de la configuración inicial realizada por el jefe del proyecto.
Una configuración especial para un protocolo puede radicar en el hecho de que el mismo puede ser ejecutado en distintas regionales del laboratorio. Por lo cual, al momento de la configuración el jefe del proyecto puede indicar si la ejecución del mismo es local o no. En el caso de que no lo sea, el proceso debe indicar su ejecución remota y luego realizar el chequeo contra un servicio web externo el cual recibe los datos del protocolo y responde su estado y su resultado de evaluación. 
Durante la ejecución del proyecto, una vez finalizado un protocolo, se debe determinar el resultado de su evaluación. Se debe notificar al responsable del protocolo una vez finalizado el mismo. Si la ejecución del mismo fue positiva, se debe continuar con la ejecución del protocolo siguiente. Si en el mismo ocurrió alguna falla, se debe informar al responsable del proyecto para que decida qué hacer: si volver a repetir la etapa, si reiniciar todo el proceso de testeo, si continuar a pesar de la falla o si cancelar el proyecto.
De acuerdo a esta decisión, finalizado el circuito (exitosamente o no de acuerdo a la secuencia de protocolos ejecutados) se debe informar al jefe del proyecto el resultado obtenido. En el único caso donde esta notificación no es necesaria es aquél donde el responsable ordena la interrupción del proyecto._

En resumen, el proceso a modelar debería considerar las siguientes etapas:
- Configuración inicial de protocolos, etapas internas, duración y responsables de cada una
- Ejecución de todas las actividades del protocolo actual con su correspondiente carga deresultado
- Determinación del resultado de evaluación del protocolo y las posibles salidas deacuerdo al mismo.
- Informe final al responsable de los resultados de los protocolos ejecutados

_Además de la ejecución propia del proceso de gestión de protocolos, el laboratorio requiere de la elaboración de un panel de control operativo que reúna consultas útiles para la toma de decisiones. Estas consultas deben considerar cuestiones operativas del proceso, así como de los datosÍtems a desarrollar_

- Proceso en Bonita Open Solution que permite administrar y gestionar los ítems anteriormente citados (DSSD-2-dic-final.bos)
- Aplicación web que implemente las interfaces para cada una de las etapas del proceso e interactúe con el proceso de Bonita (this repository).
- Servicios web para el inicio de los protocolos remotos, y su consulta de estado y resultado de evaluación. (Heroku, Platform.sh) (ver https://github.com/PabloA95/DSSD_remote_protocols)
- Aplicación web que permita al personal jerárquico del Laboratorio, la evaluación, seguimiento y métricas de los procesos. (this repository)