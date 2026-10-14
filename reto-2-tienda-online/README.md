# Reto 2 · E-Commerce Adaptativo (Responsive UI)

**Módulo:** 0489 · Programación Multimedia y Dispositivos Móviles  
**Autor:** Mateo Fernández Blasco  
**Tecnología:** Kotlin + Jetpack Compose (Android nativo)  
**RA vinculado:** RA1 y RA2 · Interfaces adaptables y limitaciones del dispositivo

## 📱 Producto Final (Capturas)

<img width="1344" height="2992" alt="Screenshot_20261014_210102" src="https://github.com/user-attachments/assets/7a334ee1-9216-4030-85b9-b8929ce1d2b7" />

<img width="2560" height="1600" alt="Screenshot_20261014_210008" src="https://github.com/user-attachments/assets/59388894-cd93-4d8e-86b1-93dbfd140a2f" />


## 🎯 Objetivo del reto
Comprender la fragmentación de pantallas en Android y resolver los problemas de visualización en distintos perfiles de dispositivos. Pasar de un diseño estático (una lista infinita que se deforma) a una interfaz *responsive* (una cuadrícula inteligente) utilizando componentes de Jetpack Compose que calculan el espacio disponible en tiempo real.

## 🛠️ Componentes y conceptos utilizados

| Componente / Concepto | Para qué se usa en esta app |
| :--- | :--- |
| **LazyVerticalGrid** | Sustituye a `LazyColumn` en `CatalogoHamburguesas` para renderizar visualmente el catálogo de recambios en formato cuadrícula. |
| **GridCells.Adaptive** | Configurado a `250.dp` para calcular dinámicamente cuántas columnas de recambios caben en pantalla sin forzar un número fijo. |
| **Card** | Contenedor elevado que agrupa la imagen del componente, título, estado de favorito, precio y botón de compra. |
| **ContentScale.Crop** | Mantiene la relación de aspecto de las imágenes de recambios (`alternador`, `bateria`, `freno_brembo`...) rellenando `180.dp` de alto sin deformación al rotar. |
| **maxLines & TextOverflow** | Limita el nombre del recambio a 1 línea con `TextOverflow.Ellipsis` (`...`) para evitar que títulos largos descuadren la altura de las tarjetas. |
| **Mock Data (Datos)** | Definición de `data class Producto` y lista local `catalogoHamburguesas` con recambios de automoción y estado mutable `esFavorito`. |
| **State & Filtering** | Gestión de estado local con `remember` y `mutableStateOf` para alternar la vista entre todos los productos y el filtro `❤️ Favoritos`. |

## 🧐 Reflexión y Pensamiento Crítico

1. **Sobre la adaptabilidad:** ¿Por qué hemos usado `GridCells.Adaptive(minSize = ...)` en lugar de fijar el número de columnas con `GridCells.Fixed(2)`? ¿Qué ventaja tiene en el mundo real?
   > Usar `GridCells.Adaptive(250.dp)` permite que Jetpack Compose calcule automáticamente el número de columnas idóneo según el ancho real de la pantalla. Si fijamos `GridCells.Fixed(2)`, en un móvil vertical se verá bien, pero en una tablet de 10 pulgadas o en un plegable las tarjetas se estirarán horizontalmente de forma desproporcionada. En el mundo real, donde existen miles de modelos Android con distintas resoluciones y densidades de píxeles, `Adaptive` garantiza que la UI sea escalable y legible en cualquier factor de forma sin duplicar código.

2. **Sobre el diseño UI:** ¿Qué ocurría con las tarjetas si el nombre de un producto era muy largo y ocupaba dos líneas mientras los demás ocupaban una? ¿Cómo lo hemos solucionado?
   > Si un producto tenía un nombre extenso (por ejemplo, "Aceite 5W30 Sintético Multiválvulas"), la tarjeta aumentaba su altura vertical en comparación con las adyacentes, rompiendo la alineación visual de la cuadrícula y desalineando los botones de "Añadir al carrito". Lo solucionamos en el componente `Text` añadiendo `maxLines = 1` y `overflow = TextOverflow.Ellipsis`, lo que trunca el texto sobrante con puntos suspensivos y mantiene constante la altura de todas las tarjetas.

3. **Sobre las imágenes:** ¿Por qué es importante usar `ContentScale.Crop` en la imagen del producto cuando cambiamos el ancho de la tarjeta al rotar la pantalla?
   > Al pasar de modo vertical a horizontal (o a una pantalla más ancha), la tarjeta cambia sus dimensiones horizontales. Si no especificamos `ContentScale.Crop`, la imagen se estiraría o comprimiría perdiendo su proporción original. `ContentScale.Crop` escala la imagen uniformemente para cubrir todo el ancho y los `180.dp` de alto asignados, recortando sutilmente los sobrantes horizontales o verticales sin distorsionar el aspecto visual del recambio.

4. **Visión de futuro:** Ahora mismo nuestros productos están escritos directamente en el código (*hardcodeados*). ¿Qué crees que necesitaría nuestra app en el futuro para que esta tienda mostrara productos reales de internet?
   > Para convertirla en una aplicación de comercio electrónico real, se necesitaría integrar una arquitectura en capas (MVVM):
   > - **Capa de Red / API REST:** Utilizar librerías como Retrofit o Ktor Client para realizar peticiones HTTP (GET/POST) a un servidor backend o servicio BaaS (como Firebase o Supabase).
   > - **Carga asíncrona de imágenes:** Sustituir `painterResource` por librerías de procesamiento de imágenes remotas como Coil (`rememberAsyncImagePainter`), gestionando estados de carga y error.
   > - **Parseo de datos:** Mapear las respuestas JSON del servidor a objetos `Producto` utilizando Kotlinx Serialization o Gson.
   > - **Persistencia local:** Implementar Room Database para guardar favoritos y permitir la consulta del catálogo sin conexión a internet (*offline-first*).

## 🚀 Cómo ejecutar el proyecto
1. Clonar el repositorio y abrir en Android Studio (Panda o superior).
2. Sincronizar las dependencias Gradle del proyecto `tiendaonline`.
3. Ejecutar (▶) la `MainActivity` en un emulador de móvil (ej. Pixel 6 / API 34).
4. Girar la pantalla del emulador a modo horizontal (Landscape) o lanzar la app en un emulador de Tablet para verificar el reordenamiento automático de las tarjetas en la cuadrícula.

## 🐞 Dificultades y cómo las resolví
- **Sincronización del estado de favoritos:** Inicialmente, al pulsar sobre el icono de corazón en la tarjeta, el atributo interno `producto.esFavorito` mutaba pero la interfaz gráfica de Compose no redibujaba el icono en pantalla.
    - *Solución:* Se vinculó el estado local de la tarjeta mediante `var esFavoritoState by remember(producto.esFavorito) { mutableStateOf(producto.esFavorito) }`. De este modo, Compose detecta la reevaluación del estado al hacer clic en el `IconButton` y re-renderiza dinámicamente el emoji entre `❤️` y `🤍`, actualizando en tiempo real la lista filtrada de la `PantallaPrincipal`.
