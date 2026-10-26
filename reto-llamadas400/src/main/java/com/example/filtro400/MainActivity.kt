package com.example.filtro400

import android.app.role.RoleManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.io.OutputStreamWriter

class MainActivity : AppCompatActivity() {

    private lateinit var tvEstado: TextView
    private lateinit var etNuevoPrefijo: EditText
    private lateinit var btnBloquear400: Button
    private lateinit var btnBloquearNumero: Button
    private lateinit var btnDesbloquearNumero: Button
    private lateinit var btnMasOpciones: Button
    private lateinit var contenedorHistorial: LinearLayout
    private lateinit var baseDatos: BaseDatos
    private var receptorHistorialRegistrado = false

    private val receptorHistorial = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == FiltroLlamadasService.ACTION_HISTORIAL_ACTUALIZADO) {
                actualizarHistorialUi()
            }
        }
    }

    private val solicitarRolFiltro = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { resultado ->
        if (resultado.resultCode == RESULT_OK) {
            getSharedPreferences(FiltroLlamadasService.PREFERENCIAS, MODE_PRIVATE)
                .edit()
                .putBoolean(FiltroLlamadasService.FILTRO_ACTIVO, true)
                .apply()

            actualizarEstadoUi()
            Toast.makeText(this, "Filtro activado correctamente", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "No se concedió el rol de filtrado", Toast.LENGTH_SHORT).show()
        }
    }

    private val crearCsv = registerForActivityResult(
        ActivityResultContracts.CreateDocument("text/csv")
    ) { uri -> if (uri != null) exportarCsv(uri) }

    private val abrirCsv = registerForActivityResult(
        ActivityResultContracts.OpenDocument()
    ) { uri -> if (uri != null) importarCsv(uri) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        baseDatos = BaseDatos(this)

        tvEstado = findViewById(R.id.tvEstado)
        etNuevoPrefijo = findViewById(R.id.etNuevoPrefijo)
        btnBloquear400 = findViewById(R.id.btnBloquear400)
        btnBloquearNumero = findViewById(R.id.btnBloquearNumero)
        btnDesbloquearNumero = findViewById(R.id.btnDesbloquearNumero)
        btnMasOpciones = findViewById(R.id.btnMasOpciones)
        contenedorHistorial = findViewById(R.id.contenedorHistorial)

        btnBloquear400.setOnClickListener { alternarBloqueo400() }
        btnBloquearNumero.setOnClickListener { guardarNumeroExacto(TipoRegla.NUMERO_BLOQUEADO) }
        btnDesbloquearNumero.setOnClickListener { guardarNumeroExacto(TipoRegla.LISTA_BLANCA) }
        btnMasOpciones.setOnClickListener { mostrarMasOpciones() }

        actualizarEstadoUi()
        actualizarHistorialUi()
    }

    private fun mostrarMasOpciones() {
        val contenido = layoutInflater.inflate(R.layout.dialog_more_options, null)
        val dialogo = AlertDialog.Builder(this)
            .setView(contenido)
            .create()

        val acciones = listOf(
            R.id.opcionAnadir to { mostrarDialogoTipoRegla() },
            R.id.opcionReglas to { mostrarReglas() },
            R.id.opcionProbar to { mostrarDialogoSimulacion() },
            R.id.opcionHistorial to { mostrarEstadisticas() },
            R.id.opcionImportar to { abrirCsv.launch(arrayOf("text/*", "application/*")) },
            R.id.opcionExportar to { crearCsv.launch("reglas_filtro.csv") }
        )
        acciones.forEach { (id, accion) ->
            contenido.findViewById<LinearLayout>(id).setOnClickListener {
                dialogo.dismiss()
                accion()
            }
        }

        dialogo.show()
        dialogo.window?.setBackgroundDrawableResource(android.R.color.transparent)
    }

    private fun mostrarReglas() {
        val reglas = baseDatos.obtenerReglas()
        if (reglas.isEmpty()) {
            Toast.makeText(this, "Todavía no hay reglas guardadas", Toast.LENGTH_SHORT).show()
            return
        }
        val etiquetas = reglas.map { regla ->
            val estado = if (regla.activa) "Activa" else "Desactivada"
            "${regla.valor} · ${etiquetaTipo(regla.tipo)} · $estado"
        }.toTypedArray()

        androidx.appcompat.app.AlertDialog.Builder(this)
            .setTitle("Reglas guardadas")
            .setItems(etiquetas) { _, indice -> mostrarAccionesRegla(reglas[indice]) }
            .setNegativeButton("Cerrar", null)
            .show()
    }

    private fun actualizarHistorialUi() {
        if (!::contenedorHistorial.isInitialized || !::baseDatos.isInitialized) return

        contenedorHistorial.removeAllViews()
        val llamadas = baseDatos.obtenerHistorialReciente()
        if (llamadas.isEmpty()) {
            val vacio = TextView(this).apply {
                text = "Aquí aparecerán las llamadas cuando el filtro registre actividad."
                setTextColor(getColor(R.color.texto_secundario))
                textSize = 13f
                setPadding(dp(14), dp(14), dp(14), dp(14))
            }
            contenedorHistorial.addView(vacio)
            return
        }

        llamadas.forEachIndexed { indice, llamada ->
            val fila = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                background = getDrawable(R.drawable.fondo_opcion_menu)
                setPadding(dp(14), dp(12), dp(14), dp(12))
            }
            val encabezado = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = android.view.Gravity.CENTER_VERTICAL
            }
            val numero = TextView(this).apply {
                text = llamada.numero
                setTextColor(getColor(R.color.texto_principal))
                textSize = 15f
                setTypeface(typeface, android.graphics.Typeface.BOLD)
                maxLines = 1
                ellipsize = android.text.TextUtils.TruncateAt.END
            }
            encabezado.addView(
                numero,
                LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            )

            val estado = TextView(this).apply {
                text = if (llamada.bloqueada) "Bloqueada" else "Permitida"
                setTextColor(
                    getColor(if (llamada.bloqueada) R.color.rojo else R.color.verde)
                )
                textSize = 11f
                setTypeface(typeface, android.graphics.Typeface.BOLD)
                background = GradientDrawable().apply {
                    setColor(
                        getColor(if (llamada.bloqueada) R.color.rojo_suave else R.color.verde_suave)
                    )
                    cornerRadius = dp(50).toFloat()
                }
                setPadding(dp(10), dp(6), dp(10), dp(6))
            }
            encabezado.addView(estado)
            fila.addView(encabezado)

            val detalle = TextView(this).apply {
                text = buildString {
                    append(llamada.regla)
                    if (llamada.simulada) append(" · Simulación")
                }
                setTextColor(getColor(R.color.texto_secundario))
                textSize = 12f
                maxLines = 1
                ellipsize = android.text.TextUtils.TruncateAt.END
                val margen = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                margen.topMargin = dp(5)
                layoutParams = margen
            }
            fila.addView(detalle)

            val margen = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            if (indice > 0) margen.topMargin = dp(8)
            contenedorHistorial.addView(fila, margen)
        }
    }

    private fun dp(valor: Int): Int =
        (valor * resources.displayMetrics.density).toInt()

    private fun activarFiltro() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                solicitarRolFiltro.launch(intent)
            } else {
                Toast.makeText(this, "Este dispositivo no permite filtrar llamadas", Toast.LENGTH_LONG).show()
            }
        } else {
            Toast.makeText(this, "Requiere Android 10 o superior", Toast.LENGTH_SHORT).show()
        }
    }

    private fun desactivarFiltro() {
        getSharedPreferences(FiltroLlamadasService.PREFERENCIAS, MODE_PRIVATE)
            .edit()
            .putBoolean(FiltroLlamadasService.FILTRO_ACTIVO, false)
            .apply()

        actualizarEstadoUi()
        Toast.makeText(this, "Filtro desactivado", Toast.LENGTH_SHORT).show()
    }

    private fun alternarBloqueo400() {
        val reglas400 = baseDatos.obtenerReglas().filter {
            it.tipo == TipoRegla.PREFIJO && MotorFiltro.normalizarNumero(it.valor) == "400"
        }
        val reglaActiva = reglas400.any { it.activa }
        val filtroActivo = getSharedPreferences(FiltroLlamadasService.PREFERENCIAS, MODE_PRIVATE)
            .getBoolean(FiltroLlamadasService.FILTRO_ACTIVO, false)
        val rolConcedido = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            (getSystemService(Context.ROLE_SERVICE) as RoleManager)
                .isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
        if (reglaActiva && filtroActivo && rolConcedido) {
            reglas400.forEach { baseDatos.cambiarEstadoRegla(it.id, false) }
            actualizarEstadoUi()
            Toast.makeText(this, "Bloqueo automático del prefijo 400 desactivado", Toast.LENGTH_SHORT).show()
            return
        }

        if (!reglaActiva && reglas400.isEmpty()) {
            baseDatos.insertarRegla("400", TipoRegla.PREFIJO, 0)
        } else if (!reglaActiva) {
            reglas400.forEach { baseDatos.cambiarEstadoRegla(it.id, true) }
        }
        actualizarEstadoUi()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (!roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
                Toast.makeText(this, "Este dispositivo no permite filtrar llamadas", Toast.LENGTH_LONG).show()
            } else if (roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)) {
                activarFiltradoGuardado()
            } else {
                solicitarRolFiltro.launch(roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING))
            }
        } else {
            Toast.makeText(this, "Requiere Android 10 o superior", Toast.LENGTH_SHORT).show()
        }
    }

    private fun guardarNumeroExacto(tipo: TipoRegla) {
        val numero = etNuevoPrefijo.text.toString().trim()
        if (!valorValido(numero)) {
            Toast.makeText(this, "Escribe un número válido en el cuadro", Toast.LENGTH_SHORT).show()
            return
        }

        val normalizado = MotorFiltro.normalizarNumero(numero)
        val reglaExistente = baseDatos.obtenerReglas().firstOrNull {
            it.tipo == tipo && MotorFiltro.normalizarNumero(it.valor) == normalizado
        }
        if (reglaExistente == null) {
            baseDatos.insertarRegla(numero, tipo, 0)
        } else if (!reglaExistente.activa) {
            baseDatos.cambiarEstadoRegla(reglaExistente.id, true)
        }

        etNuevoPrefijo.text.clear()
        actualizarEstadoUi()
        val mensaje = if (tipo == TipoRegla.NUMERO_BLOQUEADO) {
            "Número añadido a la lista de bloqueo"
        } else {
            "Número permitido; la lista blanca prevalece sobre las reglas de bloqueo"
        }
        Toast.makeText(this, mensaje, Toast.LENGTH_LONG).show()
    }

    private fun activarFiltradoGuardado() {
        getSharedPreferences(FiltroLlamadasService.PREFERENCIAS, MODE_PRIVATE)
            .edit()
            .putBoolean(FiltroLlamadasService.FILTRO_ACTIVO, true)
            .apply()
        actualizarEstadoUi()
        Toast.makeText(this, "Bloqueo automático del 400 activado", Toast.LENGTH_SHORT).show()
    }

    private fun mostrarDialogoTipoRegla() {
        val valor = etNuevoPrefijo.text.toString().trim()
        if (!valorValido(valor)) {
            Toast.makeText(this, "Escribe un número válido", Toast.LENGTH_SHORT).show()
            return
        }

        val opciones = arrayOf("Prefijo de bloqueo", "Número bloqueado exacto", "Lista blanca (Permitir)")
        AlertDialog.Builder(this)
            .setTitle("Selecciona el tipo de regla")
            .setItems(opciones) { _, which ->
                val tipo = when (which) {
                    0 -> TipoRegla.PREFIJO
                    1 -> TipoRegla.NUMERO_BLOQUEADO
                    else -> TipoRegla.LISTA_BLANCA
                }
                baseDatos.insertarRegla(valor, tipo, 0)
                etNuevoPrefijo.text.clear()
                actualizarEstadoUi()
                Toast.makeText(this, "Regla guardada correctamente", Toast.LENGTH_SHORT).show()
            }
            .show()
    }

    private fun mostrarDialogoSimulacion() {
        val campoNumero = EditText(this).apply { hint = "Ejemplo: +34 400123456" }
        AlertDialog.Builder(this)
            .setTitle("Simular llamada")
            .setView(campoNumero)
            .setPositiveButton("Simular") { _, _ ->
                val numero = campoNumero.text.toString().trim()
                if (valorValido(numero)) {
                    val resultado = MotorFiltro.evaluar(numero, baseDatos.obtenerReglas())
                    baseDatos.registrarDecision(numero, resultado, simulada = true)
                    actualizarHistorialUi()
                    val accion = if (resultado.bloquear) "BLOQUEADA" else "PERMITIDA"
                    Toast.makeText(this, "$accion. Motivo: ${resultado.reglaAplicada}", Toast.LENGTH_LONG).show()
                } else {
                    Toast.makeText(this, "Escribe un número válido", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun mostrarEstadisticas() {
        val texto = buildString {
            appendLine("Total llamadas bloqueadas: ${baseDatos.totalBloqueadas()}")
            appendLine("\nBloqueos por regla:")
            val porRegla = baseDatos.bloqueosPorRegla()
            if (porRegla.isEmpty()) appendLine("Sin registros.")
            porRegla.forEach { (regla, total) -> appendLine("• $regla: $total") }
            appendLine("\nÚltimo historial:")
            val historial = baseDatos.obtenerHistorial()
            if (historial.isEmpty()) appendLine("Sin actividad.")
            historial.forEach { appendLine(it) }
        }

        AlertDialog.Builder(this)
            .setTitle("Estadísticas e Historial")
            .setMessage(texto)
            .setPositiveButton("Cerrar", null)
            .show()
    }

    private fun exportarCsv(uri: Uri) {
        try {
            val salida = contentResolver.openOutputStream(uri)
                ?: throw IOException("No se pudo abrir el archivo para escribir")
            salida.use {
                OutputStreamWriter(it, Charsets.UTF_8).use { escritor ->
                    escritor.appendLine("tipo,valor,activa,prioridad")
                    baseDatos.obtenerReglas().forEach { r ->
                        escritor.appendLine(
                            listOf(r.tipo.name, r.valor, if (r.activa) "1" else "0", r.prioridad.toString())
                                .joinToString(",") { campo -> escaparCsv(campo) }
                        )
                    }
                }
            }
            Toast.makeText(this, "Reglas exportadas a CSV", Toast.LENGTH_SHORT).show()
        } catch (e: IOException) {
            mostrarError("No se pudo exportar el CSV", e)
        } catch (e: SecurityException) {
            mostrarError("No se pudo acceder al archivo", e)
        }
    }

    private fun importarCsv(uri: Uri) {
        try {
            val reglasImportadas = mutableListOf<Regla>()
            val entrada = contentResolver.openInputStream(uri)
                ?: throw IOException("No se pudo abrir el archivo")
            entrada.use {
                val lineas = BufferedReader(InputStreamReader(it, Charsets.UTF_8)).readLines()
                if (lineas.isEmpty() || lineas.first().removePrefix("\uFEFF").trim() != "tipo,valor,activa,prioridad") {
                    throw IllegalArgumentException("La cabecera debe ser tipo,valor,activa,prioridad")
                }
                lineas.drop(1).forEachIndexed { indice, linea ->
                    if (linea.isNotBlank()) {
                        val columnas = parsearCsv(linea)
                        if (columnas.size != 4) {
                            throw IllegalArgumentException("La fila ${indice + 2} debe tener 4 columnas")
                        }
                        val tipo = TipoRegla.valueOf(columnas[0].trim())
                        val valor = columnas[1].trim()
                        if (!valorValido(valor)) {
                            throw IllegalArgumentException("Número no válido en la fila ${indice + 2}")
                        }
                        val activa = when (columnas[2].trim()) {
                            "1" -> true
                            "0" -> false
                            else -> throw IllegalArgumentException("Estado no válido en la fila ${indice + 2}")
                        }
                        val prioridad = columnas[3].trim().toIntOrNull()
                            ?: throw IllegalArgumentException("Prioridad no válida en la fila ${indice + 2}")
                        reglasImportadas.add(Regla(0, valor, tipo, activa, prioridad))
                    }
                }
            }
            if (reglasImportadas.isEmpty()) {
                throw IllegalArgumentException("El archivo no contiene reglas")
            }
            baseDatos.importarReglas(reglasImportadas)
            actualizarEstadoUi()
            Toast.makeText(this, "Importadas ${reglasImportadas.size} reglas", Toast.LENGTH_SHORT).show()
        } catch (e: IOException) {
            mostrarError("No se pudo leer el CSV", e)
        } catch (e: IllegalArgumentException) {
            mostrarError("CSV no válido", e)
        } catch (e: SecurityException) {
            mostrarError("No se pudo acceder al archivo", e)
        }
    }

    private fun mostrarAccionesRegla(regla: Regla) {
        val opciones = arrayOf(
            "Modificar",
            if (regla.activa) "Desactivar" else "Activar",
            "Eliminar"
        )
        AlertDialog.Builder(this)
            .setTitle("${regla.valor} (${regla.tipo.name})")
            .setItems(opciones) { _, seleccion ->
                when (seleccion) {
                    0 -> mostrarDialogoEdicion(regla)
                    1 -> {
                        baseDatos.cambiarEstadoRegla(regla.id, !regla.activa)
                        actualizarEstadoUi()
                    }
                    2 -> confirmarEliminacion(regla)
                }
            }
            .show()
    }

    private fun mostrarDialogoEdicion(regla: Regla) {
        val campoValor = EditText(this).apply {
            setText(regla.valor)
            hint = "Número o prefijo"
            inputType = android.text.InputType.TYPE_CLASS_PHONE
        }
        val campoPrioridad = EditText(this).apply {
            setText(regla.prioridad.toString())
            hint = "Prioridad"
            inputType = android.text.InputType.TYPE_CLASS_NUMBER or
                android.text.InputType.TYPE_NUMBER_FLAG_SIGNED
        }
        val selectorTipo = Spinner(this).apply {
            adapter = ArrayAdapter(
                this@MainActivity,
                android.R.layout.simple_spinner_dropdown_item,
                TipoRegla.entries.map(::etiquetaTipo)
            )
            setSelection(TipoRegla.entries.indexOf(regla.tipo))
        }
        val contenido = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val margen = (16 * resources.displayMetrics.density).toInt()
            setPadding(margen, 0, margen, 0)
            addView(campoValor)
            addView(selectorTipo)
            addView(campoPrioridad)
        }

        AlertDialog.Builder(this)
            .setTitle("Modificar regla")
            .setView(contenido)
            .setPositiveButton("Guardar") { _, _ ->
                val valor = campoValor.text.toString().trim()
                val prioridad = campoPrioridad.text.toString().trim().toIntOrNull()
                if (!valorValido(valor) || prioridad == null) {
                    Toast.makeText(this, "Revisa el número y la prioridad", Toast.LENGTH_SHORT).show()
                    return@setPositiveButton
                }
                val tipo = TipoRegla.entries[selectorTipo.selectedItemPosition]
                baseDatos.modificarRegla(regla.id, valor, tipo, prioridad)
                actualizarEstadoUi()
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun confirmarEliminacion(regla: Regla) {
        AlertDialog.Builder(this)
            .setTitle("Eliminar regla")
            .setMessage("¿Borrar la regla '${regla.valor}'?")
            .setPositiveButton("Borrar") { _, _ ->
                baseDatos.eliminarRegla(regla.id)
                actualizarEstadoUi()
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun valorValido(valor: String): Boolean =
        valor.isNotBlank() && valor.length <= 30 &&
            valor.any(Char::isDigit) &&
            valor.all { it.isDigit() || it == '+' || it == ' ' || it == '-' || it == '(' || it == ')' }

    private fun etiquetaTipo(tipo: TipoRegla): String = when (tipo) {
        TipoRegla.PREFIJO -> "Prefijo de bloqueo"
        TipoRegla.NUMERO_BLOQUEADO -> "Número bloqueado exacto"
        TipoRegla.LISTA_BLANCA -> "Lista blanca"
    }

    private fun escaparCsv(valor: String): String =
        "\"${valor.replace("\"", "\"\"")}\""

    private fun parsearCsv(linea: String): List<String> {
        val columnas = mutableListOf<String>()
        val campo = StringBuilder()
        var entreComillas = false
        var indice = 0
        while (indice < linea.length) {
            val caracter = linea[indice]
            when {
                caracter == '"' && entreComillas && indice + 1 < linea.length && linea[indice + 1] == '"' -> {
                    campo.append('"')
                    indice++
                }
                caracter == '"' -> entreComillas = !entreComillas
                caracter == ',' && !entreComillas -> {
                    columnas.add(campo.toString())
                    campo.clear()
                }
                else -> campo.append(caracter)
            }
            indice++
        }
        if (entreComillas) throw IllegalArgumentException("Hay comillas sin cerrar")
        columnas.add(campo.toString())
        return columnas
    }

    private fun mostrarError(mensaje: String, error: Exception) {
        val detalle = error.localizedMessage
        Toast.makeText(this, if (detalle.isNullOrBlank()) mensaje else "$mensaje: $detalle", Toast.LENGTH_LONG).show()
    }

    private fun actualizarEstadoUi() {
        val activo = getSharedPreferences(FiltroLlamadasService.PREFERENCIAS, MODE_PRIVATE)
            .getBoolean(FiltroLlamadasService.FILTRO_ACTIVO, false)
        val bloqueo400 = baseDatos.obtenerReglas().any {
            it.tipo == TipoRegla.PREFIJO &&
                MotorFiltro.normalizarNumero(it.valor) == "400" && it.activa
        }

        tvEstado.text = "Filtro general: ${if (activo) "activo" else "desactivado"} · " +
            "prefijo 400: ${if (bloqueo400) "activo" else "desactivado"}"
        val rolDisponible = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            (getSystemService(Context.ROLE_SERVICE) as RoleManager)
                .isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
        val proteccionActiva = activo && bloqueo400 && rolDisponible
        tvEstado.text = when {
            proteccionActiva -> "Protección activa · se bloquean las llamadas que empiezan por 400"
            !rolDisponible -> "Pulsa el botón para activar y conceder permiso de llamadas"
            bloqueo400 -> "Prefijo 400 preparado · activa el filtro para empezar"
            else -> "Protección desactivada"
        }
        btnBloquear400.text = if (bloqueo400 && activo) {
            "Desactivar bloqueo del 400"
        } else {
            "Activar bloqueo del 400"
        }
    }

    override fun onDestroy() {
        baseDatos.close()
        super.onDestroy()
    }

    override fun onStart() {
        super.onStart()
        val filtro = IntentFilter(FiltroLlamadasService.ACTION_HISTORIAL_ACTUALIZADO)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receptorHistorial, filtro, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(receptorHistorial, filtro)
        }
        receptorHistorialRegistrado = true
    }

    override fun onStop() {
        if (receptorHistorialRegistrado) {
            unregisterReceiver(receptorHistorial)
            receptorHistorialRegistrado = false
        }
        super.onStop()
    }

    override fun onResume() {
        super.onResume()
        if (::baseDatos.isInitialized && ::tvEstado.isInitialized) {
            actualizarEstadoUi()
            actualizarHistorialUi()
        }
    }

}