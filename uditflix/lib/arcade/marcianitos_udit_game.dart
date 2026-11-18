
//
// UDIT ARCADE - MARCIANITOS UDIT
//
// Videojuego 2D estilo "Space Invaders" construido con Flame.
// La nave se mueve con el dedo/ratón y se dispara pulsando sobre el campo.
// Todo se dibuja con componentes nativos (formas y paint), sin recursos
// externos, para que funcione también en las pruebas automatizadas.
//

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../theme/udit_theme.dart';

/// Juego de disparar marcianitos para una demostración educativa.
class MarcianitosUditGame extends FlameGame
    with TapCallbacks, DragCallbacks {
  // Paleta UDITflix: negro, rojo y blanco.
  static const Color fondo = UditTheme.fondoOscuro;
  static const Color rojo = UditTheme.rojo;
  static const Color blanco = UditTheme.texto;

  // Parámetros de demostración (también verificados en los tests).
  static const double velocidadNave = 460;
  static const double velocidadBala = 560;
  static const double velocidadMarcianitoInicial = 70;
  static const int filas = 3;
  static const int columnas = 6;
  static const double separacionMarcianitos = 46;

  /// Se notifica a la UI cada vez que cambia la puntuación.
  final ValueChanged<int>? onPuntuacion;

  /// Se notifica cuando la partida termina.
  final VoidCallback? onGameOver;

  _Nave? _nave;
  _Escuadron? _escuadron;
  _Fondo? _fondo;
  final List<_Bala> _balas = [];
  final List<_BalaEnemiga> _balasEnemigas = [];

  int _puntuacion = 0;
  bool _terminado = false;
  bool _iniciado = false;
  double _tiempoDisparoEnemigo = 0;

  MarcianitosUditGame({
    this.onPuntuacion,
    this.onGameOver,
  });

  int get puntuacion => _puntuacion;
  bool get terminado => _terminado;
  bool get iniciado => _iniciado;
  int get totalMarcianitos => filas * columnas;

  /// La oleada acelera a medida que se eliminan marcianitos.
  double get velocidadMarcianitos {
    final eliminados = _puntuacion.clamp(0, totalMarcianitos - 1);
    return velocidadMarcianitoInicial + eliminados * 3.5;
  }

  @override
  Color backgroundColor() => fondo;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _reset();
  }

  /// Prepara una partida nueva desde cero.
  void _reset() {
    for (final bala in _balas) {
      bala.removeFromParent();
    }
    for (final bala in _balasEnemigas) {
      bala.removeFromParent();
    }
    _balas.clear();
    _balasEnemigas.clear();

    _escuadron?.removeFromParent();
    _nave?.removeFromParent();
    _fondo?.removeFromParent();

    _puntuacion = 0;
    _terminado = false;
    _iniciado = false;
    _tiempoDisparoEnemigo = 0;
    onPuntuacion?.call(0);

    _fondo = _Fondo();
    add(_fondo!);

    _nave = _Nave(position: Vector2(size.x / 2, size.y - 46));
    add(_nave!);

    _escuadron = _Escuadron();
    add(_escuadron!);
  }

  /// Reinicio público, invocado desde el botón de Game Over.
  void reiniciar() {
    _reset();
    resumeEngine();
  }

  void _moverNave(double x) {
    final nave = _nave;
    if (nave == null || _terminado) return;

    final mitad = nave.size.x / 2;
    final min = mitad;
    final max = size.x - mitad;
    nave.x = max > min ? x.clamp(min, max).toDouble() : size.x / 2;
  }

  void _disparar() {
    if (_terminado || _nave == null) return;
    if (!_iniciado) _iniciado = true;

    final bala = _Bala(
      position: Vector2(_nave!.x, _nave!.y - 20),
    );
    _balas.add(bala);
    add(bala);
    add(_Destello(position: Vector2(_nave!.x, _nave!.y - 24)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    _moverNave(event.canvasPosition.x);
    _disparar();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _moverNave(event.canvasEndPosition.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_terminado || !_iniciado) return;

    _tiempoDisparoEnemigo += dt;
    if (_tiempoDisparoEnemigo >= 1.9) {
      _tiempoDisparoEnemigo = 0;
      _disparoEnemigo();
    }

    _comprobarImpactos();
    _comprobarBalasEnemigas();
    _comprobarDerrota();
  }

  /// Un marcianito aleatorio lanza un láser hacia la nave.
  void _disparoEnemigo() {
    final escuadron = _escuadron;
    if (escuadron == null || escuadron.marcianitos.isEmpty) return;

    final vivo = escuadron.marcianitos[math.Random().nextInt(
          escuadron.marcianitos.length,
        )];
    final bala = _BalaEnemiga(
      position: Vector2(
        escuadron.x + vivo.position.x,
        escuadron.y + vivo.position.y + 14,
      ),
    );
    _balasEnemigas.add(bala);
    add(bala);
  }

  /// Comprueba si un láser enemigo alcanza a la nave.
  void _comprobarBalasEnemigas() {
    final nave = _nave;
    if (nave == null) return;

    for (final bala in List<_BalaEnemiga>.from(_balasEnemigas)) {
      if (!bala.isMounted) continue;

      final ancho = (nave.size.x + bala.size.x) / 2;
      final alto = (nave.size.y + bala.size.y) / 2;
      if ((bala.position.x - nave.x).abs() < ancho &&
          (bala.position.y - nave.y).abs() < alto) {
        bala.removeFromParent();
        _balasEnemigas.remove(bala);
        add(_Explosion(position: bala.position.clone(), color: MarcianitosUditGame.rojo));
        _perder();
        return;
      }
    }
  }

  /// Colisión AABB entre cada bala y los marcianitos vivos.
  void _comprobarImpactos() {
    final escuadron = _escuadron;
    if (escuadron == null) return;

    final balas = List<_Bala>.from(_balas);
    final marcianitos = List<_Marcianito>.from(escuadron.marcianitos);

    for (final bala in balas) {
      if (!bala.isMounted) continue;

      for (final marcianito in marcianitos) {
        if (!marcianito.isMounted) continue;

        final x = escuadron.x + marcianito.position.x;
        final y = escuadron.y + marcianito.position.y;
        final ancho = marcianito.size.x / 2 + bala.size.x / 2;
        final alto = marcianito.size.y / 2 + bala.size.y / 2;

        if ((bala.position.x - x).abs() < ancho &&
            (bala.position.y - y).abs() < alto) {
          add(_Explosion(position: Vector2(x, y), color: marcianito.color));
          bala.removeFromParent();
          _balas.remove(bala);
          marcianito.removeFromParent();
          escuadron.marcianitos.remove(marcianito);
          _sumarPunto();
          break;
        }
      }
    }
  }

  void _comprobarDerrota() {
    final escuadron = _escuadron;
    final nave = _nave;
    if (escuadron == null || nave == null) return;

    if (escuadron.marcianitos.isEmpty) {
      _perder();
      return;
    }

    final bordeInferior = size.y - 78;
    for (final marcianito in escuadron.marcianitos) {
      final x = escuadron.x + marcianito.position.x;
      final y = escuadron.y + marcianito.position.y + marcianito.size.y / 2;

      if (y >= bordeInferior) {
        _perder();
        return;
      }

      final choqueHorizontal =
          (x - nave.x).abs() < (marcianito.size.x + nave.size.x) / 2;
      if (choqueHorizontal && y >= nave.y - nave.size.y / 2) {
        _perder();
        return;
      }
    }
  }

  void _sumarPunto() {
    _puntuacion++;
    onPuntuacion?.call(_puntuacion);
  }

  void _perder() {
    if (_terminado) return;
    _terminado = true;
    if (_nave != null) {
      add(_Explosion(
        position: _nave!.position.clone(),
        color: MarcianitosUditGame.rojo,
      ));
    }
    onGameOver?.call();
    pauseEngine();
  }
}

/// Fondo animado: niebla roja, rejilla perspective y estrellas que caen.
class _Fondo extends PositionComponent
    with HasGameReference<MarcianitosUditGame> {
  final List<_Estrella> _estrellas = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(game.size.x, game.size.y);

    final random = math.Random(42);
    for (var i = 0; i < 55; i++) {
      _estrellas.add(
        _Estrella(
          x: random.nextDouble() * size.x,
          y: random.nextDouble() * size.y,
          velocidad: 12 + random.nextDouble() * 46,
          radio: random.nextDouble() < 0.18 ? 1.8 : 0.9,
          alpha: 0.18 + random.nextDouble() * 0.55,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final estrella in _estrellas) {
      estrella.y += estrella.velocidad * dt;
      if (estrella.y > size.y) {
        estrella.y = -4;
        estrella.x = math.Random().nextDouble() * size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final area = Rect.fromLTWH(0, 0, size.x, size.y);

    canvas.drawRect(
      area,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 0.85,
          colors: [
            const Color(0x2EE50914),
            const Color(0x120B0B0D),
            Colors.transparent,
          ],
        ).createShader(area),
    );

    final rejilla = Paint()..color = const Color(0x26E50914);
    final horizonte = size.y - 76;
    for (var i = -6; i <= 6; i++) {
      canvas.drawLine(
        Offset(size.x / 2, horizonte),
        Offset(size.x / 2 + i * size.x * 0.16, size.y),
        rejilla,
      );
    }
    for (var i = 0; i < 5; i++) {
      final y = horizonte + i * i * 3.2;
      if (y <= size.y) {
        canvas.drawLine(Offset(0, y), Offset(size.x, y), rejilla);
      }
    }

    for (final estrella in _estrellas) {
      canvas.drawCircle(
        Offset(estrella.x, estrella.y),
        estrella.radio,
        Paint()..color = Colors.white.withValues(alpha: estrella.alpha),
      );
    }
  }
}

class _Estrella {
  double x;
  double y;
  final double velocidad;
  final double radio;
  final double alpha;

  _Estrella({
    required this.x,
    required this.y,
    required this.velocidad,
    required this.radio,
    required this.alpha,
  });
}

/// Nave del jugador: triángulo blanco, cabina roja y propulsor animado.
class _Nave extends PositionComponent {
  double _t = 0;

  _Nave({required super.position})
      : super(
          size: Vector2(46, 34),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final centro = Offset(size.x / 2, size.y / 2);

    canvas.drawCircle(
      centro,
      size.x * 0.66,
      Paint()..color = const Color(0x1AE50914),
    );

    final longitud = 11 + math.sin(_t * 26) * 4;
    final llama = Path()
      ..moveTo(size.x * 0.38, size.y * 0.72)
      ..lineTo(size.x * 0.5, size.y + longitud)
      ..lineTo(size.x * 0.62, size.y * 0.72)
      ..close();
    canvas.drawPath(llama, Paint()..color = const Color(0x88E50914));

    final casco = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(size.x * 0.64, size.y * 0.76)
      ..lineTo(size.x * 0.36, size.y * 0.76)
      ..lineTo(0, size.y)
      ..close();

    canvas.drawPath(casco, Paint()..color = MarcianitosUditGame.blanco);
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.4, size.y * 0.44, size.x * 0.2, size.y * 0.34),
      Paint()..color = MarcianitosUditGame.rojo,
    );
  }
}

/// Bala propia con halo luminoso.
class _Bala extends PositionComponent {
  _Bala({required super.position})
      : super(
          size: Vector2(4, 14),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    y -= MarcianitosUditGame.velocidadBala * dt;
    if (y < -20) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-5, -10, 14, 34),
      Paint()..color = const Color(0x33E50914),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-2, -7, 8, 28),
      Paint()..color = const Color(0x99E50914),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-2, -7, 4, 14),
      Paint()..color = Colors.white,
    );
  }
}

/// Láser enemigo que desciende desde la oleada.
class _BalaEnemiga extends PositionComponent
    with HasGameReference<MarcianitosUditGame> {
  _BalaEnemiga({required super.position})
      : super(
          size: Vector2(4, 16),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    y += 230 * dt;
    if (y > game.size.y + 20) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-5, -10, 14, 36),
      Paint()..color = const Color(0x33FF6B6B),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-2, -8, 4, 32),
      Paint()..color = const Color(0xFFFF6B6B),
    );
  }
}

/// Destello breve al disparar.
class _Destello extends PositionComponent {
  static const double _duracion = 0.14;
  double _vida = _duracion;

  _Destello({required super.position})
      : super(
          size: Vector2(18, 18),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _vida -= dt;
    if (_vida <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_vida / _duracion).clamp(0.0, 1.0);
    final centro = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      centro,
      size.x / 2 * (1.5 - t * 0.5),
      Paint()..color = Colors.white.withValues(alpha: 0.9 * t),
    );
    canvas.drawCircle(
      centro,
      size.x,
      Paint()..color = const Color(0x44E50914).withValues(alpha: t),
    );
  }
}

/// Explosion de partículas al destruir un marcianito o perder la nave.
class _Explosion extends PositionComponent {
  final Color color;
  final List<_Particula> _particulas = [];
  static const double _duracion = 0.65;
  double _vida = _duracion;

  _Explosion({required super.position, required this.color})
      : super(size: Vector2(2, 2), anchor: Anchor.center) {
    final random = math.Random();
    for (var i = 0; i < 14; i++) {
      final angulo = (i / 14) * math.pi * 2 + random.nextDouble() * 0.35;
      final velocidad = 70 + random.nextDouble() * 130;
      _particulas.add(
        _Particula(
          vx: math.cos(angulo) * velocidad,
          vy: math.sin(angulo) * velocidad,
          tam: 2 + random.nextDouble() * 3,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _vida -= dt;
    for (final particula in _particulas) {
      particula.x += particula.vx * dt;
      particula.y += particula.vy * dt;
      particula.vy += 140 * dt;
    }
    if (_vida <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_vida / _duracion).clamp(0.0, 1.0);
    for (final particula in _particulas) {
      canvas.drawRect(
        Rect.fromLTWH(
          particula.x - particula.tam / 2,
          particula.y - particula.tam / 2,
          particula.tam,
          particula.tam,
        ),
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }
}

class _Particula {
  double x = 0;
  double y = 0;
  final double vx;
  double vy;
  final double tam;

  _Particula({
    required this.vx,
    required this.vy,
    required this.tam,
  });
}

/// Formación de marcianitos que se desplaza en bloque y baja al rebotar.
class _Escuadron extends PositionComponent
    with HasGameReference<MarcianitosUditGame> {
  final List<_Marcianito> marcianitos = [];
  double _direccion = 1;

  _Escuadron() : super(position: Vector2(0, 46));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const columnas = MarcianitosUditGame.columnas;
    const filas = MarcianitosUditGame.filas;
    const separacion = MarcianitosUditGame.separacionMarcianitos;

    size = Vector2((columnas - 1) * separacion + 34, filas * 38 + 24);

    for (var fila = 0; fila < filas; fila++) {
      for (var columna = 0; columna < columnas; columna++) {
        final marcianito = _Marcianito(fila: fila);
        marcianito.position = Vector2(
          columna * separacion + 17,
          fila * 38 + 12,
        );
        marcianitos.add(marcianito);
        add(marcianito);
      }
    }

    x = (game.size.x - size.x) / 2;
    if (x < 12) x = 12;
  }

  @override
  void update(double dt) {
    super.update(dt);

    const margen = 14.0;
    x += game.velocidadMarcianitos * _direccion * dt;

    final limiteDerecho = game.size.x - margen - size.x;
    if (x <= margen || x >= limiteDerecho) {
      _direccion *= -1;
      y += 16;
      x = limiteDerecho > margen
          ? x.clamp(margen, limiteDerecho).toDouble()
          : margen;
    }
  }
}

/// Marcianito animado, dibujado con bloques y con halo de neón.
class _Marcianito extends PositionComponent {
  final int fila;
  double _t = 0;

  _Marcianito({required this.fila})
      : super(
          size: Vector2(32, 24),
          anchor: Anchor.center,
        );

  Color get color =>
      fila == 1 ? UditTheme.rojoOscuro : MarcianitosUditGame.rojo;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final cuerpo = Paint()..color = color;
    final ojo = Paint()..color = Colors.black;
    final brillo = math.sin(_t * 6) * 0.12;
    final paso = math.sin(_t * 9) > 0 ? 2.0 : 0.0;

    canvas.drawCircle(
      const Offset(16, 12),
      21,
      Paint()..color = color.withValues(alpha: 0.12 + brillo),
    );

    canvas.drawRect(Rect.fromLTWH(6, 0, 20, 5), cuerpo);
    canvas.drawRect(Rect.fromLTWH(0, 5, 32, 11), cuerpo);
    canvas.drawRect(Rect.fromLTWH(3, 16, 8, 8 - paso), cuerpo);
    canvas.drawRect(Rect.fromLTWH(21, 16 + paso, 8, 8 - paso), cuerpo);

    canvas.drawRect(Rect.fromLTWH(8, 8, 5, 5), ojo);
    canvas.drawRect(Rect.fromLTWH(19, 8, 5, 5), ojo);
  }
}
