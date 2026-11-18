
//
// PANTALLA UDIT ARCADE — UDITFLIX (ESTILO STREAMING)
//
// Aloja el videojuego Marcianitos UDIT dentro de la aplicación UDITflix.
// La UI (puntuación, instrucciones y Game Over) se construye con Flutter
// y se comunica con el motor Flame mediante callbacks.
//

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../arcade/marcianitos_udit_game.dart';
import '../theme/udit_theme.dart';
import '../widgets/udit_ui.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen> {
  late final MarcianitosUditGame _game;
  int _puntuacion = 0;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _game = MarcianitosUditGame(
      onPuntuacion: (puntos) {
        if (!mounted) return;
        setState(() => _puntuacion = puntos);
      },
      onGameOver: () {
        if (!mounted) return;
        setState(() => _gameOver = true);
      },
    );
  }

  void _reiniciar() {
    setState(() {
      _gameOver = false;
      _puntuacion = 0;
    });
    _game.reiniciar();
  }

  @override
  Widget build(BuildContext context) {
    return UditScaffold(
      appBar: AppBar(
        title: const Text('UDIT Arcade'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SurfacePanel(
              borderColor: UditTheme.rojo.withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: UditTheme.rojo,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff,
                          size: 18,
                          color: UditTheme.texto,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Marcianitos UDIT',
                        style: TextStyle(
                          color: UditTheme.texto,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: UditTheme.rojo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: UditTheme.rojo.withValues(alpha: 0.65),
                      ),
                    ),
                    child: Text(
                      'Puntos: $_puntuacion',
                      style: const TextStyle(
                        color: UditTheme.rojo,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SurfacePanel(
                padding: const EdgeInsets.all(6),
                borderColor: UditTheme.rojo.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Stack(
                    children: [
                      GameWidget(game: _game),
                      if (!_gameOver && _puntuacion == 0)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Text(
                                'Toca para disparar',
                                style: TextStyle(
                                  color: UditTheme.texto,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: UditTheme.rojo,
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_gameOver)
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xB3000000),
                            child: Center(
                              child: SurfacePanel(
                                borderColor: UditTheme.rojo,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      size: 48,
                                      color: UditTheme.rojo,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _puntuacion >=
                                              MarcianitosUditGame.filas *
                                                  MarcianitosUditGame.columnas
                                          ? '¡Victoria!'
                                          : 'Game Over',
                                      style: const TextStyle(
                                        color: UditTheme.texto,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Puntuación: $_puntuacion',
                                      style: const TextStyle(
                                        color: UditTheme.textoSuave,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton.icon(
                                      onPressed: _reiniciar,
                                      icon: const Icon(Icons.replay),
                                      label: const Text('Jugar de nuevo'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Text(
              'Toca para mover la nave y disparar. Elimina a todos los marcianitos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UditTheme.textoSuave,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
