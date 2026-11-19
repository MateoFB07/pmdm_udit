# UDITflix

Aplicación de catálogo de contenidos desarrollada en Flutter a partir del demo realizado en clase. Muestra una lista de contenidos simulados con estética de plataforma de streaming, permite abrir la ficha de cada contenido, reproducir vídeos y acceder al minijuego UDIT Arcade.

## Tecnología y justificación de la decisión

Se ha elegido **Flutter** (con **Dart** y Material 3) como tecnología de la aplicación:

- **Una sola base de código** para Android, iOS y web, con la misma interfaz y comportamiento en todas las plataformas. Desarrollar de forma nativa en Kotlin/Java y Swift exigiría dos proyectos distintos, y otras opciones híbridas añadirían una capa puente entre el código y la interfaz.
- **Interfaz propia y consistente**: los widgets permiten construir el catálogo, el tema visual y los componentes reutilizables (`SurfacePanel`, `ContentBadge`, `BackdropImage`) sin depender de librerías de UI externas.
- **Integración del juego**: el minijuego se implementa con **Flame** y se integra en la app mediante `GameWidget`, compartiendo el mismo proyecto y el mismo tema que el resto de pantallas.
- **Iteración rápida**: hot reload y un conjunto de pruebas automatizadas con `flutter test` facilitan desarrollar y verificar el catálogo.
- **Datos desacoplados**: la información está en una lista simulada, pero aislada en `lib/data/`, de forma que se puede sustituir por una API REST sin cambiar la interfaz.

El proyecto se ha verificado con `flutter analyze` (sin incidencias), `flutter test` (8 pruebas superadas) y `flutter build apk --debug` (compilación correcta).

## Estructura del proyecto

```text
uditflix/
├── lib/
│   ├── main.dart                    # Punto de entrada; aplica UditTheme.theme
│   ├── data/
│   │   ├── contenidos.dart          # Lista de contenidos de ejemplo
│   │   ├── imagenes.dart            # URLs de las carátulas
│   │   └── videos.dart              # URLs de los vídeos de demostración
│   ├── models/
│   │   └── contenido.dart           # Modelo Contenido: id, título, descripción, tipo, duración
│   ├── screens/
│   │   ├── catalogo_screen.dart     # Catálogo: filas con ListView.builder
│   │   ├── ficha_screen.dart        # Detalle de cada contenido
│   │   ├── reproductor_screen.dart  # Reproductor de vídeo
│   │   └── arcade_screen.dart       # Pantalla del minijuego
│   ├── theme/
│   │   └── udit_theme.dart          # Colores, tipografías y estilos globales
│   ├── widgets/
│   │   └── udit_ui.dart             # Componentes visuales reutilizables
│   └── arcade/
│       └── marcianitos_udit_game.dart  # Motor del juego con Flame
├── test/                            # Pruebas de widgets y de datos
├── android/ ios/ web/ linux/ macos/ windows/  # Carpetas nativas de Flutter
├── pubspec.yaml                     # Dependencias del proyecto
└── analysis_options.yaml            # Reglas de análisis estático
```

La pantalla de catálogo usa `ListView.builder` en cada fila horizontal (`_Fila` en `lib/screens/catalogo_screen.dart`): `itemCount` indica cuántos contenidos hay y `itemBuilder` construye cada tarjeta a partir de la lista `contenidos` de `lib/data/contenidos.dart`. Los colores, iconos y estilos propios se centralizan en `lib/theme/udit_theme.dart` y se aplican globalmente desde `main.dart`.

## Ejecución

```bash
flutter pub get
flutter run
flutter test
```

La versión de Flutter utilizada durante el desarrollo es 3.47.6 (Dart 3.13.5), canal stable.
