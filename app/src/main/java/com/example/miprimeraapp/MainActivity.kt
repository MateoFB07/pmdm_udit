package com.example.miprimeraapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.example.miprimeraapp.ui.theme.MiPrimeraAppTheme

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MiPrimeraAppTheme {
                Greeting()
            }
        }
    }
}

@Composable
fun Greeting() {
    val nombre = "Mateo"
    val curso = "2º DAM"
    val mensaje = "Android Studio y Kotlin"

    Text(
        text = "Hola, me llamo $nombre y estoy cursando $curso\nEstoy usando $mensaje"
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    MiPrimeraAppTheme {
        Greeting()
    }
}
