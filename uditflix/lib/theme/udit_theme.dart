
//
// TEMA VISUAL DE UDITFLIX (ESTILO STREAMING)
//
// Negro de sala de cine, rojo corporativo y tipografía compacta.
// Se aplica de forma global desde main.dart para que todas las
// pantallas compartan la misma identidad visual.
//

import 'package:flutter/material.dart';

abstract final class UditTheme {
  static const Color negro = Color(0xFF000000);
  static const Color fondoOscuro = Color(0xFF0B0B0D);
  static const Color superficie = Color(0xFF18181B);
  static const Color superficieClara = Color(0xFF242427);
  static const Color rojo = Color(0xFFE50914);
  static const Color rojoOscuro = Color(0xFFB0060F);
  static const Color texto = Color(0xFFFFFFFF);
  static const Color textoSuave = Color(0xFFB3B3B3);

  /// Fondo base de la aplicación.
  static const LinearGradient fondo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [negro, fondoOscuro],
  );

  /// Degradado de acento para botones y detalles destacados.
  static const LinearGradient acento = LinearGradient(
    colors: [rojo, rojoOscuro],
  );

  /// Degradado que oscurece la parte inferior de las imágenes.
  static const LinearGradient sombraInferior = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x99000000),
      Color(0xE6000000),
    ],
  );

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: rojo,
        onPrimary: texto,
        secondary: texto,
        onSecondary: negro,
        surface: superficie,
        onSurface: texto,
        surfaceContainerHighest: superficieClara,
        error: rojo,
        onError: texto,
      ),
      scaffoldBackgroundColor: negro,
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: texto,
        iconTheme: IconThemeData(color: texto),
        titleTextStyle: TextStyle(
          color: rojo,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      iconTheme: const IconThemeData(color: texto),
      textTheme: base.textTheme
          .apply(bodyColor: texto, displayColor: texto)
          .copyWith(
            displaySmall: const TextStyle(
              color: texto,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            headlineMedium: const TextStyle(
              color: texto,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            titleLarge: const TextStyle(
              color: texto,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            bodyMedium: const TextStyle(
              color: textoSuave,
              fontSize: 14,
              height: 1.5,
            ),
            labelLarge: const TextStyle(
              color: texto,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: rojo,
          foregroundColor: texto,
          disabledBackgroundColor: superficieClara,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: texto,
          side: const BorderSide(color: Color(0x80FFFFFF), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: texto),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x2EFFFFFF),
        thickness: 1,
      ),
    );
  }
}
