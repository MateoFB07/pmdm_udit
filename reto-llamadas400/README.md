# Filtro de llamadas 400

Aplicación Android desarrollada en Kotlin que utiliza el servicio nativo
`CallScreeningService` para rechazar llamadas entrantes cuyo número coincide
con una regla de bloqueo. Incluye una regla inicial para el prefijo `400`,
gestión local de reglas y un historial de decisiones.

> **Estado de la demostración:** las pruebas unitarias de la lógica están
> implementadas. La demostración con llamadas reales debe realizarse en un
> dispositivo y documentarse con evidencias; una simulación dentro de la
> aplicación no demuestra que Android haya filtrado una llamada real.

## Enlaces de entrega

- **APK:** se genera localmente en `build/outputs/apk/debug/filtro400-debug.apk` al compilar el proyecto.

## Funcionalidades

- Solicita al usuario el rol de filtrado de llamadas de Android y permite
  activar o desactivar el bloqueo del prefijo `400`.
- Rechaza una llamada entrante cuando la regla activa que coincide determina
  que debe bloquearse. Las llamadas que no coinciden se permiten.
- Normaliza los números eliminando caracteres que no sean dígitos y contempla
  el prefijo español `+34` y el formato `0034`.
- Permite crear reglas de prefijo, bloqueo de número exacto y lista blanca.
  También permite editar, activar, desactivar y eliminar reglas.
- Da prioridad a la lista blanca. Para las demás reglas aplica primero la de
  mayor prioridad; en caso de empate, prevalece el bloqueo de número exacto
  frente a una regla de prefijo.
- Guarda reglas e historial localmente en SQLite. El historial distingue las
  simulaciones de las decisiones recibidas por el servicio.
- Ofrece una comprobación/simulación de números, estadísticas e importación y
  exportación de reglas CSV (`tipo,valor,activa,prioridad`).

## Requisitos

- Android Studio con soporte para Kotlin y Gradle.
- Android 10 (API 29) o posterior, correspondiente al `minSdk` del proyecto.
- Para filtrar llamadas reales, un dispositivo compatible y el rol
  `ROLE_CALL_SCREENING` concedido por el usuario. La disponibilidad del
  filtrado puede depender también de la versión de Android, el fabricante y
  el operador.

## Compilar, instalar y ejecutar pruebas

Desde la carpeta del proyecto:

```bash
./gradlew test assembleDebug
```

El APK de depuración se encontrará en:

```text
build/outputs/apk/debug/filtro400-debug.apk
```

Para instalarlo en un dispositivo conectado por ADB:

```bash
adb install -r build/outputs/apk/debug/filtro400-debug.apk
```

Abre **Filtro de llamadas**, concede el rol cuando Android lo solicite y activa
el filtro. El servicio no puede intervenir en llamadas reales hasta que el
usuario haya concedido ese rol.

## Funcionamiento y decisiones técnicas

1. `MainActivity` solicita el rol de filtrado mediante el sistema de roles de
   Android y guarda el estado de activación del filtro.
2. Android invoca `FiltroLlamadasService`, una implementación de
   `CallScreeningService`, cuando una llamada entrante se entrega al servicio.
3. El servicio obtiene el número disponible, consulta las reglas en SQLite y
   delega la decisión a `MotorFiltro`.
4. Si la regla indica bloqueo, el servicio responde a Android rechazando la
   llamada y omitiendo su notificación. Si no hay regla coincidente, responde
   permitiéndola.
5. Después de responder, intenta registrar la decisión en el historial. De
   este modo, la escritura del historial no retrasa la respuesta de filtrado.

La regla inicial bloquea el prefijo `400`. Por ejemplo, `400123456`,
`+34 400123456` y `0034 400123456` se normalizan y se comparan con esa regla.
El prefijo es configurable mediante las reglas de la aplicación.

El filtrado se realiza en el dispositivo: no se envía el número a un servidor
ni se necesita conexión a Internet para evaluar las reglas. Si el número no
está disponible, no se puede comparar y la llamada se permite. Si falla la
consulta de reglas SQLite, la implementación también permite la llamada y
registra el error en el log de Android, evitando bloquearla por un fallo
interno.

## Pruebas y evidencias

### Pruebas unitarias

Las pruebas de `MotorFiltroTest` cubren:

- Bloqueo de un número con prefijo `400` y normalización de `+34`.
- Lista blanca con prioridad sobre el prefijo, incluyendo `0034`.
- Aplicación de la regla de mayor prioridad.
- Desempate entre número exacto y prefijo.
- Ignorar reglas desactivadas.

Ejecutarlas con `./gradlew test`. Estas pruebas verifican la lógica de decisión;
no simulan el sistema de telefonía ni demuestran que una llamada real se haya
bloqueado.

### Evidencias que deben añadirse

No se incluyen capturas ni grabación de llamadas reales en este repositorio por
el momento. Para completar la entrega, añadir evidencias propias, por ejemplo:

| Evidencia | Qué debe mostrar |
|---|---|
| `docs/evidencias/pantalla-principal.png` | Aplicación abierta y estado del filtro. |
| `docs/evidencias/rol-filtrado.png` | Solicitud o estado del rol de filtrado del sistema. |
| `docs/evidencias/llamada-400-bloqueada.png` | Resultado de una llamada real de prueba cuyo número presentado comienza por 400. |
| `docs/evidencias/llamada-permitida.png` | Resultado de una llamada real de prueba desde un número que no coincide. |
| `docs/evidencias/pruebas-unitarias.png` | Resultado de `./gradlew test`. |

Realizar las llamadas de prueba únicamente con líneas y dispositivos autorizados.
En la grabación de hasta tres minutos, mostrar tanto la llamada bloqueada como
otra llamada permitida. No presentar el comprobador o la simulación de la app
como si fueran llamadas reales.

## Reflexión crítica

### 1. ¿Qué es `CallScreeningService` y qué función cumple en Android?

Es una API de Android que permite a una aplicación con el rol adecuado recibir
detalles de ciertas llamadas entrantes y responder al sistema si deben
permitirse o rechazarse. Android mantiene el control de la llamada: la
aplicación no reemplaza a la app Teléfono ni establece directamente la llamada.

### 2. ¿Por qué necesitamos solicitar el rol `ROLE_CALL_SCREENING`?

El rol autoriza a la aplicación a actuar como servicio de filtrado y permite a
Android dirigirle las llamadas que corresponda. Es una elección explícita del
usuario y evita que una aplicación filtre llamadas sin su consentimiento. Si
el usuario no concede o posteriormente revoca el rol, el servicio no podrá
realizar el filtrado.

### 3. ¿Por qué no necesitamos un servidor externo para realizar el filtrado?

La detección del prefijo y la decisión se hacen localmente con el número
entregado por Android y las reglas guardadas en SQLite. Un servidor no aporta
nada necesario para esta regla fija y requeriría enviar datos de llamadas fuera
del dispositivo. Por ello, esta aplicación no necesita conexión a Internet
para filtrar.

### 4. ¿Qué ocurre si el número telefónico está guardado en los contactos?

Android puede excluir del filtrado las llamadas de números guardados en
contactos, salvo que el servicio tenga el permiso de lectura de contactos
requerido por la plataforma. Esta aplicación no solicita `READ_CONTACTS`; por
tanto, no se debe asumir que el servicio recibirá para filtrar una llamada de
un contacto. El comportamiento exacto debe comprobarse en el dispositivo y la
versión de Android utilizados.

### 5. ¿Qué diferencias existen entre comprobar un número mediante una función y bloquear realmente una llamada?

Comprobar un número ejecuta una función con texto y reglas, y solo informa qué
decisión tomaría el motor. No interviene en la telefonía. Bloquear realmente
requiere que Android entregue una llamada entrante al `CallScreeningService`,
que la aplicación tenga concedido el rol y que el servicio responda a tiempo
con la instrucción de rechazo. Por eso las pruebas unitarias y simulaciones no
sustituyen una llamada real de demostración.

### 6. ¿Qué mejoras incorporarías en una futura versión?

- Añadir evidencias automatizadas y una prueba de integración en un dispositivo
  compatible, además de documentar modelo, versión de Android y condiciones de
  la llamada.
- Mejorar la gestión de errores y mostrar claramente si el rol fue revocado o
  si una llamada no se pudo evaluar.
- Permitir importar, exportar y hacer copias de seguridad de reglas con
  validación más detallada.
- Añadir opciones de privacidad para configurar la conservación y el borrado
  del historial.
- Ampliar la accesibilidad y ofrecer una interfaz de edición de reglas más
  clara.

## Estructura principal

```text
reto-llamadas400/
├── AndroidManifest.xml
├── README.md
├── res/
├── src/
│   ├── main/java/com/example/
│   │   ├── MotorFiltro.kt
│   │   ├── Regla.kt
│   │   └── filtro400/
│   │       ├── BaseDatos.kt
│   │       ├── FiltroLlamadasService.kt
│   │       └── MainActivity.kt
│   └── test/java/com/example/filtro400/
│       └── MotorFiltroTest.kt
└── build.gradle.kts
```
