# tarea_t3
# ¿Se asocia el nivel educacional con la probabilidad de ser informal, y cuánto 
# de esa asociación se mantiene al controlar por género y edad en los ocupados?
Respuesta: Cada año adicional de educación se asocia con una disminución de 10,41 
puntos porcentuales en la probabilidad de informalidad, manteniendo constantes género y edad.

Para correr el script, carga primero las librerias, si no las tienes descargadas
deberas hacerlo con la funcion install.packages y el paquete a instalar, luego ve linea 
por linea cargando en la parte A las bases de datos en primer lugar y luego los puntos 
que se piden en la tarea. Lo mismo para la Parte B, esta base de datos es mas grande
por lo que puede tardar un poco mas, y sigue linea por linea para que el vayas creando las 
variables que se utilizan mas abajo en el codigo con el fin de responder la pregunta.

## Declaración de autoría y uso de IA

Copia este bloque al final de tu `README.md` y complétalo:


## Declaración de autoría y uso de IA
- Herramienta utilizada:Claude pro
- Para qué la usé:  Le pedi que me hicera un borrador para crear una portada llamativa
visulamente y tuve problemas a la hora de ir corriendo el codigo, guiandome por las sesiones
y laboratorios, me dijo que solo el error estaba en que puse mal unos nombres a la hora 
de hacer los modelos.
- Qué hice yo: elegi mi pregunta, cree el codigo con las variables que necesitaba para responderla e
hice la interpretacion economica en base a la tabla que obtuve con los estimate (coefs_m2). Tambien la parte A que tenia
un poco menos de complejidad, no tuve mayor problema con esa.
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.


**Uso permitido:** pedir que te expliquen un error, preguntar qué hace una función
o un argumento (`weights`, `conf.int`, `group_modify`), pedir alternativas a un
código que ya escribiste, revisar la redacción.

**Uso no permitido:** pegar este enunciado y entregar lo que devuelva; entregar
código que no puedes explicar línea por línea; pedirle que **interprete** los
coeficientes por ti — esa es justamente la habilidad que se evalúa.

Un aviso concreto: si le pides a un chatbot que «haga una regresión con la ENE», te
va a inventar variables (`ingreso`, `salario`, `años_educ`) que **no existen** en
este archivo. El manual manda sobre el chatbot.

Declarar el uso **no baja la nota**; ocultarlo constituye falta a la ética
académica (Guía de uso ético de tecnologías digitales, UdeC).
