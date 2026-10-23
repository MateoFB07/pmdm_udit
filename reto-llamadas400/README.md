# Filtro de llamadas

Aplicación Android en Kotlin para administrar reglas de bloqueo sin reemplazar
la aplicación de teléfono. El servicio real usa `CallScreeningService` y requiere
que el usuario conceda el rol de filtrado desde la propia aplicación.

## Funciones

- Crear reglas para bloquear un número exacto o un prefijo, y para permitir
  números mediante la lista blanca.
- Activar o desactivar el bloqueo automático del prefijo 400 desde la pantalla.
- Bloquear o permitir el número escrito en el cuadro principal con los botones
  específicos; desbloquearlo crea una regla de lista blanca para que prevalezca
  incluso sobre el prefijo 400.
- Modificar tipo, número y prioridad de una regla; activar, desactivar o borrar
  reglas pulsando sobre ellas.
- Guardar reglas e historial localmente en SQLite.
- Consultar llamadas bloqueadas, reglas aplicadas y las últimas decisiones.
- Importar y exportar reglas en CSV con las columnas
  `tipo,valor,activa,prioridad`.
- Simular una llamada desde la pantalla para probar las reglas sin recibir una
  llamada real.

## Decisiones de funcionamiento

La lista blanca siempre permite el número aunque coincida con una regla de
bloqueo. Para el resto, se revisa primero la regla activa con mayor prioridad;
si hay empate, gana el bloqueo de número exacto frente al prefijo. El prefijo
400 inicial conserva el comportamiento de las fases anteriores. Los números
con prefijo español `+34` o `0034` se normalizan antes de compararse.

El servicio responde a Android antes de escribir el historial, para no retrasar
la llamada por una operación de registro. Si SQLite falla al consultar reglas,
la llamada se permite y el error queda en el registro de Android. El historial
se conserva solo en el dispositivo y contiene el número, la decisión, la regla
y la fecha. Las simulaciones se marcan en el historial y no cuentan como
bloqueos reales en las estadísticas.

## Compilar y probar

Desde esta carpeta:

```sh
./gradlew test assembleDebug
```

El APK de depuración se genera en
`build/outputs/apk/debug/filtro400-debug.apk`. Las pruebas unitarias cubren el
prefijo, la normalización española, la lista blanca, las prioridades y las
reglas desactivadas. Las llamadas reales requieren un dispositivo compatible y
el rol de filtrado; no se han validado con una llamada de operador.

## Dificultades y límites

Android decide qué llamadas entrega al servicio y puede limitar los números
disponibles. Por eso se permite el paso cuando el número no está disponible y
se recomienda comprobar el filtrado real en un dispositivo autorizado. La
interfaz es intencionadamente sencilla y usa componentes Android básicos para
que el código sea fácil de mantener y ampliar.
