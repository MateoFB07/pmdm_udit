package com.example.filtro400

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import android.database.sqlite.SQLiteException

class FiltroLlamadasService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val numero = callDetails.handle?.schemeSpecificPart
        val numeroParaRegistro = numero ?: "Número no disponible"

        val resultado = try {
            if (!filtroActivo()) {
                ResultadoFiltro(false, "Filtrado desactivado")
            } else if (numero == null) {
                ResultadoFiltro(false, "Número no disponible")
            } else {
                val baseDatos = BaseDatos(applicationContext)
                try {
                    MotorFiltro.evaluar(numero, baseDatos.obtenerReglas())
                } finally {
                    baseDatos.close()
                }
            }
        } catch (error: SQLiteException) {
            Log.e("FiltroLlamadas", "No se pudieron consultar las reglas", error)
            ResultadoFiltro(false, "No se pudieron consultar las reglas")
        }

        responder(callDetails, resultado.bloquear)

        try {
            val baseDatosHistorial = BaseDatos(applicationContext)
            try {
                baseDatosHistorial.registrarDecision(numeroParaRegistro, resultado)
            } finally {
                baseDatosHistorial.close()
            }
        } catch (error: SQLiteException) {
            Log.e("FiltroLlamadas", "No se pudo guardar la decisión en el historial", error)
        }
    }

    private fun filtroActivo(): Boolean {
        return getSharedPreferences(PREFERENCIAS, MODE_PRIVATE)
            .getBoolean(FILTRO_ACTIVO, false)
    }

    private fun responder(callDetails: Call.Details, bloquear: Boolean) {
        val respuesta = if (bloquear) {
            CallResponse.Builder()
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipNotification(true)
                .build()
        } else {
            CallResponse.Builder()
                .setDisallowCall(false)
                .build()
        }
        respondToCall(callDetails, respuesta)
    }

    companion object {
        const val PREFERENCIAS = "filtro_llamadas"
        const val FILTRO_ACTIVO = "filtro_activo"
    }
}