package com.example.filtro400

enum class TipoRegla {
    NUMERO_BLOQUEADO,
    LISTA_BLANCA,
    PREFIJO
}

data class Regla(
    val id: Long,
    val valor: String,
    val tipo: TipoRegla,
    val activa: Boolean,
    val prioridad: Int
)

data class ResultadoFiltro(
    val bloquear: Boolean,
    val reglaAplicada: String
)