package com.example.filtro400

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

data class LlamadaHistorial(
    val numero: String,
    val bloqueada: Boolean,
    val regla: String,
    val simulada: Boolean
)

class BaseDatos(context: Context) :
    SQLiteOpenHelper(context, "filtro_llamadas.db", null, 3) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE reglas (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                valor TEXT NOT NULL,
                tipo TEXT NOT NULL,
                activa INTEGER NOT NULL DEFAULT 1,
                prioridad INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent()
        )

        db.execSQL(
            """
            CREATE TABLE historial (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                numero TEXT NOT NULL,
                decision TEXT NOT NULL,
                regla TEXT NOT NULL,
                fecha INTEGER NOT NULL,
                simulada INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent()
        )

        val reglaInicial = ContentValues().apply {
            put("valor", "400")
            put("tipo", TipoRegla.PREFIJO.name)
            put("activa", 1)
            put("prioridad", 0)
        }
        db.insert("reglas", null, reglaInicial)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS reglas (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                valor TEXT NOT NULL DEFAULT '',
                tipo TEXT NOT NULL DEFAULT 'PREFIJO',
                activa INTEGER NOT NULL DEFAULT 1,
                prioridad INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent()
        )

        asegurarColumna(db, "reglas", "valor", "TEXT NOT NULL DEFAULT ''")
        asegurarColumna(db, "reglas", "tipo", "TEXT NOT NULL DEFAULT 'PREFIJO'")
        asegurarColumna(db, "reglas", "activa", "INTEGER NOT NULL DEFAULT 1")
        asegurarColumna(db, "reglas", "prioridad", "INTEGER NOT NULL DEFAULT 0")

        val columnas = mutableSetOf<String>()
        db.rawQuery("PRAGMA table_info(reglas)", null).use { cursor ->
            while (cursor.moveToNext()) columnas.add(cursor.getString(1))
        }
        if ("prefijo" in columnas) {
            db.execSQL("UPDATE reglas SET valor = prefijo WHERE valor = ''")
        }

        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS historial (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                numero TEXT NOT NULL,
                decision TEXT NOT NULL,
                regla TEXT NOT NULL,
                fecha INTEGER NOT NULL
            )
            """.trimIndent()
        )
        asegurarColumna(db, "historial", "simulada", "INTEGER NOT NULL DEFAULT 0")
    }

    private fun asegurarColumna(
        db: SQLiteDatabase,
        tabla: String,
        nombre: String,
        definicion: String
    ) {
        val existe = db.rawQuery("PRAGMA table_info($tabla)", null).use { cursor ->
            var encontrada = false
            while (cursor.moveToNext()) {
                if (cursor.getString(1) == nombre) encontrada = true
            }
            encontrada
        }
        if (!existe) db.execSQL("ALTER TABLE $tabla ADD COLUMN $nombre $definicion")
    }

    fun obtenerReglas(): List<Regla> {
        val reglas = mutableListOf<Regla>()
        val cursor = readableDatabase.query(
            "reglas", arrayOf("id", "valor", "tipo", "activa", "prioridad"),
            null, null, null, null, "prioridad DESC, id ASC"
        )
        cursor.use {
            while (it.moveToNext()) {
                reglas.add(
                    Regla(
                        id = it.getLong(0),
                        valor = it.getString(1),
                        tipo = TipoRegla.valueOf(it.getString(2)),
                        activa = it.getInt(3) == 1,
                        prioridad = it.getInt(4)
                    )
                )
            }
        }
        return reglas
    }

    fun insertarRegla(valor: String, tipo: TipoRegla, prioridad: Int): Long {
        val datos = ContentValues().apply {
            put("valor", valor)
            put("tipo", tipo.name)
            put("activa", 1)
            put("prioridad", prioridad)
        }
        return writableDatabase.insertOrThrow("reglas", null, datos)
    }

    fun modificarRegla(id: Long, valor: String, tipo: TipoRegla, prioridad: Int): Int {
        val datos = ContentValues().apply {
            put("valor", valor)
            put("tipo", tipo.name)
            put("prioridad", prioridad)
        }
        return writableDatabase.update("reglas", datos, "id = ?", arrayOf(id.toString()))
    }

    fun cambiarEstadoRegla(id: Long, activa: Boolean): Int {
        val datos = ContentValues().apply { put("activa", if (activa) 1 else 0) }
        return writableDatabase.update("reglas", datos, "id = ?", arrayOf(id.toString()))
    }

    fun eliminarRegla(id: Long): Int {
        return writableDatabase.delete("reglas", "id = ?", arrayOf(id.toString()))
    }

    fun importarReglas(reglas: List<Regla>) {
        val db = writableDatabase
        db.beginTransaction()
        try {
            reglas.forEach { regla ->
                val datos = ContentValues().apply {
                    put("valor", regla.valor)
                    put("tipo", regla.tipo.name)
                    put("activa", if (regla.activa) 1 else 0)
                    put("prioridad", regla.prioridad)
                }
                db.insertOrThrow("reglas", null, datos)
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
    }

    fun registrarDecision(numero: String, resultado: ResultadoFiltro, simulada: Boolean = false) {
        val datos = ContentValues().apply {
            put("numero", numero)
            put("decision", if (resultado.bloquear) "BLOQUEADA" else "PERMITIDA")
            put("regla", resultado.reglaAplicada)
            put("fecha", System.currentTimeMillis())
            put("simulada", if (simulada) 1 else 0)
        }
        writableDatabase.insertOrThrow("historial", null, datos)
    }

    fun totalBloqueadas(): Int {
        val cursor = readableDatabase.rawQuery(
            "SELECT COUNT(*) FROM historial WHERE decision = 'BLOQUEADA' AND simulada = 0",
            null
        )
        cursor.use { return if (it.moveToFirst()) it.getInt(0) else 0 }
    }

    fun bloqueosPorRegla(): List<Pair<String, Int>> {
        val resultados = mutableListOf<Pair<String, Int>>()
        val cursor = readableDatabase.rawQuery(
            """
            SELECT regla, COUNT(*) AS total FROM historial
            WHERE decision = 'BLOQUEADA' AND simulada = 0
            GROUP BY regla ORDER BY total DESC
            """.trimIndent(),
            null
        )
        cursor.use {
            while (it.moveToNext()) {
                resultados.add(it.getString(0) to it.getInt(1))
            }
        }
        return resultados
    }

    fun obtenerHistorial(): List<String> {
        val lineas = mutableListOf<String>()
        val cursor = readableDatabase.rawQuery(
            "SELECT numero, decision, regla, simulada FROM historial ORDER BY fecha DESC LIMIT 50",
            null
        )
        cursor.use {
            while (it.moveToNext()) {
                val simulacion = if (it.getInt(3) == 1) " [simulación]" else ""
                lineas.add("${it.getString(0)} -> ${it.getString(1)} (${it.getString(2)})$simulacion")
            }
        }
        return lineas
    }

    fun obtenerHistorialReciente(): List<LlamadaHistorial> {
        val llamadas = mutableListOf<LlamadaHistorial>()
        val cursor = readableDatabase.query(
            "historial",
            arrayOf("numero", "decision", "regla", "simulada"),
            null,
            null,
            null,
            null,
            "fecha DESC",
            "5"
        )
        cursor.use {
            while (it.moveToNext()) {
                llamadas.add(
                    LlamadaHistorial(
                        numero = it.getString(0),
                        bloqueada = it.getString(1) == "BLOQUEADA",
                        regla = it.getString(2),
                        simulada = it.getInt(3) == 1
                    )
                )
            }
        }
        return llamadas
    }
}