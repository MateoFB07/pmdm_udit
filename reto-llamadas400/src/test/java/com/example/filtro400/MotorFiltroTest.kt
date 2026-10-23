package com.example.filtro400

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class MotorFiltroTest {

    @Test
    fun bloqueaUnNumeroQueEmpiezaPorElPrefijoConfigurado() {
        val reglas = listOf(regla("400", TipoRegla.PREFIJO))

        val resultado = MotorFiltro.evaluar("+34 400123456", reglas)

        assertTrue(resultado.bloquear)
        assertTrue(resultado.reglaAplicada.contains("400"))
    }

    @Test
    fun laListaBlancaTienePrioridadSobreLosBloqueos() {
        val reglas = listOf(
            regla("400", TipoRegla.PREFIJO, prioridad = 100),
            regla("400123456", TipoRegla.LISTA_BLANCA)
        )

        val resultado = MotorFiltro.evaluar("0034 400123456", reglas)

        assertFalse(resultado.bloquear)
        assertTrue(resultado.reglaAplicada.startsWith("Lista blanca"))
    }

    @Test
    fun unaPrioridadMayorSeAplicaAntesQueUnaMenor() {
        val reglas = listOf(
            regla("400", TipoRegla.PREFIJO, prioridad = 1),
            regla("400123456", TipoRegla.NUMERO_BLOQUEADO, prioridad = 2)
        )

        val resultado = MotorFiltro.evaluar("400123456", reglas)

        assertTrue(resultado.bloquear)
        assertTrue(resultado.reglaAplicada.startsWith("Número bloqueado"))
    }

    @Test
    fun aIgualPrioridadGanaElNumeroExacto() {
        val reglas = listOf(
            regla("400", TipoRegla.PREFIJO),
            regla("400123456", TipoRegla.NUMERO_BLOQUEADO)
        )

        val resultado = MotorFiltro.evaluar("400123456", reglas)

        assertTrue(resultado.reglaAplicada.startsWith("Número bloqueado"))
    }

    @Test
    fun lasReglasDesactivadasNoSeAplican() {
        val resultado = MotorFiltro.evaluar(
            "400123456",
            listOf(regla("400", TipoRegla.PREFIJO, activa = false))
        )

        assertFalse(resultado.bloquear)
    }

    private fun regla(
        valor: String,
        tipo: TipoRegla,
        activa: Boolean = true,
        prioridad: Int = 0
    ) = Regla(0, valor, tipo, activa, prioridad)
}
