package com.example.filtro400

object MotorFiltro {

    fun normalizarNumero(numero: String): String {
        val digitos = numero.filter { it.isDigit() }
        return when {
            digitos.startsWith("0034") && digitos.length > 4 -> digitos.drop(4)
            digitos.startsWith("34") && digitos.length == 11 -> digitos.drop(2)
            else -> digitos
        }
    }

    fun evaluar(numero: String, reglas: List<Regla>): ResultadoFiltro {
        val numeroNormalizado = normalizarNumero(numero)
        if (numeroNormalizado.isBlank()) {
            return ResultadoFiltro(false, "Número no disponible")
        }

        val reglasActivas = reglas.filter { it.activa }

        // 1. Prioridad absoluta: Lista blanca
        val reglaPermitida = reglasActivas.firstOrNull { regla ->
            regla.tipo == TipoRegla.LISTA_BLANCA && coincide(numeroNormalizado, regla)
        }
        if (reglaPermitida != null) {
            return ResultadoFiltro(false, "Lista blanca: ${reglaPermitida.valor}")
        }

        // 2. Aplicar reglas de bloqueo según prioridad
        val reglaBloqueo = reglasActivas
            .filter { it.tipo != TipoRegla.LISTA_BLANCA }
            .sortedWith(
                compareByDescending<Regla> { it.prioridad }
                    .thenBy { if (it.tipo == TipoRegla.NUMERO_BLOQUEADO) 0 else 1 }
            )
            .firstOrNull { regla -> coincide(numeroNormalizado, regla) }

        return if (reglaBloqueo == null) {
            ResultadoFiltro(false, "Sin regla de bloqueo")
        } else {
            ResultadoFiltro(true, "${nombreTipo(reglaBloqueo.tipo)}: ${reglaBloqueo.valor}")
        }
    }

    private fun coincide(numero: String, regla: Regla): Boolean {
        val valor = normalizarNumero(regla.valor)
        return when (regla.tipo) {
            TipoRegla.PREFIJO -> numero.startsWith(valor)
            TipoRegla.NUMERO_BLOQUEADO, TipoRegla.LISTA_BLANCA -> numero == valor
        }
    }

    private fun nombreTipo(tipo: TipoRegla): String = when (tipo) {
        TipoRegla.PREFIJO -> "Prefijo"
        TipoRegla.NUMERO_BLOQUEADO -> "Número bloqueado"
        TipoRegla.LISTA_BLANCA -> "Lista blanca"
    }
}