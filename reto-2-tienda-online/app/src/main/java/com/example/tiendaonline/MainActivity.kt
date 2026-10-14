package com.example.tiendaonline

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.tiendaonline.ui.theme.TiendaOnlineTheme
import kotlinx.coroutines.delay


// ACTIVITY PRINCIPAL
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            // TiendaOnlineTheme: aplica los colores y
            // tipografías por defecto a todo lo que hay dentro
            TiendaOnlineTheme {
                // Surface: el "Lienzo" de fondo que ocupa la pantalla.
                Surface(
                    modifier = Modifier.fillMaxSize()
                ) {
                    PantallaPrincipal()
                }
            }
        }
    }
}
// MODELO DE DATOS
// EL MOLDE QUE DEFINE QUÉ INFORMACIÓN TIENE CADA PRODUCTO

data class Producto (
    val nombre : String, // Nombre identificativo del producto
    val precio : String, // Precio con la moneda incluida
    val imagenResId : Int, // Identificador del recurso de imagen res/drawable
    var esFavorito : Boolean = false // Propiedad booleana que indica si el producto es favorito (false por defecto)
)

// DATOS DE PRUEBA (HARDCODEADOS)
// DE MOMENTO VIVEN AQUÍ MISMO, EN EL CÓDIGO. NO VIENEN DE NINGÚN SERVIDOR NI BBDD.

val catalogoHamburguesas = listOf (
    Producto (
        nombre = "Alternador",
        precio = "150 €",
        imagenResId = R.drawable.alternador
    ),
    Producto (
        nombre = "Bateria",
        precio = "89,99€",
        imagenResId = R.drawable.bateria
    ),
    Producto (
        nombre = "Aceite 5W30",
        precio = "169,89 €",
        imagenResId = R.drawable.aceite_5w30
    ),
    Producto (
        nombre = "Bombilla",
        precio = "3,21 €",
        imagenResId = R.drawable.bombilla
    ),
    Producto (
        nombre = "Frenos",
        precio = "120 €",
        imagenResId = R.drawable.freno_brembo
    ),
    Producto (
        nombre = "Neumáticos",
        precio = "321 €",
        imagenResId = R.drawable.rueda_coche
    ),
    Producto (
        nombre = "Matricula",
        precio = "19,99 €",
        imagenResId = R.drawable.placa_matricula
    )
)

// CATÁLOGO
// LazyColumn: pinta una lista que se puede recorrer en scroll en vertical.
// Solo dibuja en memoria lo que se ve en pantalla (por eso se llama "lazy", perezoso): es eficiente
// aunque la lista tenga cientos de elementos.
@Composable
fun CatalogoHamburguesas (productos : List<Producto>) {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(250.dp),
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        // horizontalArrangement: Controla el espacio entre las columnas de la cuadrícula
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        // verticalArrangement: Controla el espacio vertical entre las filas de la cuadrícula
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(productos) { producto ->
            TarjetaProducto(producto)
        }
    }
}
// TARJETA DE PRODUCTO
// Un "caja" (card) con imagen arriba y datos + botón.
@Composable
fun TarjetaProducto(producto: Producto) {
    // Card: una superficie elevada, con sombra y border redondeados // por defecto - ideal para
    // agrupar visualmente la info de un producto.
    Card (
        modifier = Modifier.fillMaxWidth()
    ) {
        Column (
            modifier = Modifier.padding(16.dp)
        ) {
            // Column: apila sus elementos de arriba a abajo (flexbox).
            Column {
                Image(
                    painter = painterResource(
                        id = producto.imagenResId
                    ),
                    // Para accesibilidad (lectores de pantalla)
                    contentDescription = producto.nombre,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp), // Alto - fijo es justo -- "se rompe al rotar"
                    contentScale = ContentScale.Crop // Recorta la imagen sin deformar
                )
                // Segunda Column, con margen interior, para el texto y el botón.
                Column (
                    modifier = Modifier.padding(12.dp)
                ) {
                    // Estado local mutable sincronizado con la propiedad del producto para avisar a Compose que redibuje la vista
                    var esFavoritoState by remember(producto.esFavorito) { mutableStateOf(producto.esFavorito) }

                    // Fila que distribuye el título del producto a la izquierda y el botón de favorito a la derecha
                    Row(
                        modifier = Modifier.fillMaxWidth(), // La fila se extiende a todo el ancho disponible
                        // horizontalArrangement: Coloca el título en la izquierda y el botón de corazón en la derecha
                        horizontalArrangement = Arrangement.SpaceBetween,
                        // verticalAlignment: Alinea verticalmente al centro el texto y el botón de icono
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Texto que muestra el nombre del producto
                        Text (
                            text = producto.nombre, // Muestra el nombre asignado al producto
                            fontSize = 18.sp, // Tamaño de fuente en puntos de escala (sp)
                            fontWeight = FontWeight.Bold, // Texto en negrita
                            maxLines = 1, // Restringe el texto a 1 sola línea
                            overflow = TextOverflow.Ellipsis, // Coloca puntos suspensivos si el texto es muy largo
                            modifier = Modifier.weight(1f) // Le da prioridad de espacio horizontal al texto dejando espacio para el icono
                        )
                        // Botón con icono interactivo para cambiar el estado de favorito al hacer clic
                        IconButton(onClick = {
                            // Invierte el estado booleano dentro del objeto producto (de false a true o de true a false)
                            producto.esFavorito = !producto.esFavorito
                            // Actualiza la variable de estado para refrescar el icono en la interfaz
                            esFavoritoState = producto.esFavorito
                        }) {
                            // Renderiza un icono de corazón rojo si es favorito o un corazón blanco si no lo es
                            Text(
                                text = if (esFavoritoState) "❤️" else "🤍", // Elige el emoji a mostrar
                                fontSize = 20.sp // Tamaño del emoji de corazón
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(8.dp)) // Hueco pequeño.
                    Text (
                        text = producto.precio,
                        fontSize = 16.sp,
                        color = MaterialTheme.colorScheme.primary // Color del tema.
                    )
                    Spacer(modifier = Modifier.height(8.dp)) // Hueco mediano.

                    Button (
                        onClick = {
                            // De momento, no hace nada: la interactividad.
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(text = "Añadir al carrito")
                    }
                }
            }
        }
    }
}

// PANTALLA DE PORTADA
@Composable // PERMITE PINTAR ALGO EN LA PANTALLA
fun PantallaPrincipal() {

    // Remember + mutableStateOf: crea una variable que Compose vigila.
    // Cuando su valor cambia, Compose vuelve a dibujar la pantalla solo
    // sin que tengas que hacer nada más.

    var mostrarPortada by remember { mutableStateOf(true) }

    // Variable de estado que recuerda si el usuario activó la vista de solo favoritos (true) o todos (false)
    var mostrarSoloFavoritos by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {  // Lanza una tarea que se ejecuta una sola vez.
        // Cuando la pantalla aparece, debe esperar 1.5 seg y luego
        // cambia de estado para ocultar la portada.
        delay (1500)
        mostrarPortada = false
    }

    if(mostrarPortada) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text ("🛒 Tienda Online", fontSize = 32.sp, fontWeight = FontWeight.Bold)
        }
    }
    else {
        // Columna vertical principal que agrupa la cabecera superior y el catálogo de productos
        Column(modifier = Modifier.fillMaxSize()) {
            // Fila superior que contiene el título de la aplicación y el botón para filtrar favoritos
            Row(
                modifier = Modifier
                    .fillMaxWidth() // La fila ocupa todo el ancho de la pantalla
                    .padding(16.dp), // Añade un margen de 16dp alrededor de la cabecera
                horizontalArrangement = Arrangement.SpaceBetween, // Separa el título a la izquierda y el botón a la derecha
                verticalAlignment = Alignment.CenterVertically // Centra verticalmente los elementos de la cabecera
            ) {
                // Texto con el título principal de la tienda
                Text("🛒 Tienda Online", fontSize = 20.sp, fontWeight = FontWeight.Bold)

                // Botón interactivo para alternar la vista entre todos los productos y solo los favoritos
                Button(onClick = { mostrarSoloFavoritos = !mostrarSoloFavoritos }) {
                    // Cambia dinámicamente el texto del botón según el estado del filtro
                    Text(if (mostrarSoloFavoritos) "Ver Todos" else "❤️ Favoritos")
                }
            }

            // Variable que calcula qué productos se deben enviar al catálogo
            val productosAMostrar = if (mostrarSoloFavoritos) {
                // Si mostrarSoloFavoritos es true, filtra la lista conservando únicamente los productos donde esFavorito sea true
                catalogoHamburguesas.filter { it.esFavorito }
            } else {
                // Si mostrarSoloFavoritos es false, devuelve la lista completa de productos
                catalogoHamburguesas
            }

            // Comprueba si la vista de favoritos está activa pero la lista filtrada está vacía
            if (mostrarSoloFavoritos && productosAMostrar.isEmpty()) {
                // Muestra un contenedor centrado en pantalla con un mensaje informativo
                Box(
                    modifier = Modifier.fillMaxSize(), // Ocupa todo el alto y ancho restante de la pantalla
                    contentAlignment = Alignment.Center // Alinea el texto en el centro absoluto
                ) {
                    // Texto indicando que aún no hay productos en la lista de favoritos
                    Text("No tienes productos en favoritos aún ❤️", fontSize = 18.sp)
                }
            } else {
                // Si hay productos para mostrar (o está en vista general), pinta la cuadrícula del catálogo
                CatalogoHamburguesas(productosAMostrar)
            }
        }
    }
}
