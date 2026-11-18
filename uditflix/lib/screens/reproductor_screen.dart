
//
// PANTALLA DEL REPRODUCTOR — UDITFLIX (ESTILO STREAMING)
//
// Reproductor real integrado con el paquete video_player.
// Mantiene la navegación existente: FichaScreen -> ReproductorScreen.
//
// Controles incluidos:
// - Play / Pause
// - Barra de progreso con seek
// - Tiempo transcurrido / duración
// - Pantalla completa
// - Gestión de errores de carga
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../data/videos.dart' show totalVideos, videoDe, videoPrincipalUrl;
import '../models/contenido.dart';
import '../theme/udit_theme.dart';
import '../widgets/udit_ui.dart';

/// Vídeo de demostración público y accesible (MP4, HTTP 200 y CORS
/// verificados). Se conserva como constante pública para los tests.
const String videoDemostracionUrl = videoPrincipalUrl;

class ReproductorScreen extends StatefulWidget {
  final Contenido contenido;

  /// Permite reutilizar el mismo reproductor en la ruta a pantalla completa.
  final VideoPlayerController? controlador;

  const ReproductorScreen({
    super.key,
    required this.contenido,
    this.controlador,
  });

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<ReproductorScreen> {
  VideoPlayerController? _controller;
  bool _creadoAqui = false;
  bool _cargando = true;
  String? _error;

  VideoPlayerController get controller => widget.controlador ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.controlador != null) {
      // La pantalla completa reutiliza el controlador ya inicializado.
      _cargando = false;
    } else {
      _iniciarVideo();
    }
  }

  Future<void> _iniciarVideo() async {
    final controlador = VideoPlayerController.networkUrl(
      Uri.parse(videoDe(widget.contenido)),
    );
    _controller = controlador;
    _creadoAqui = true;

    try {
      await controlador.initialize();
      if (!mounted) return;
      setState(() => _cargando = false);
      await controlador.play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudo cargar el vídeo. Comprueba tu conexión.';
      });
    }
  }

  @override
  void dispose() {
    // Solo el dueño del controlador lo libera; la vista normal sigue viva
    // mientras la pantalla completa está abierta.
    if (_creadoAqui) {
      controller.dispose();
    }
    super.dispose();
  }

  void _alternarReproduccion() {
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  void _reiniciar() {
    controller.seekTo(Duration.zero);
    controller.play();
    setState(() {});
  }

  Future<void> _abrirPantallaCompleta() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ReproductorScreen(
          contenido: widget.contenido,
          controlador: controller,
        ),
      ),
    );

    if (!mounted) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final esPantallaCompleta = widget.controlador != null;

    final contenido = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_cargando)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: UditTheme.rojo),
            ),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SurfacePanel(
                  borderColor: UditTheme.rojoOscuro,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 56,
                        color: UditTheme.rojoOscuro,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _cargando = true;
                            _error = null;
                          });
                          _iniciarVideo();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else ...[
          Expanded(
            child: Center(
              child: SurfacePanel(
                padding: const EdgeInsets.all(8),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio == 0
                        ? 16 / 9
                        : controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
          ),
          _ControlesVideo(
            controller: controller,
            alAlternar: _alternarReproduccion,
            alReiniciar: _reiniciar,
            alPantallaCompleta: _abrirPantallaCompleta,
          ),
          if (!esPantallaCompleta) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.contenido.titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: UditTheme.texto,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vídeo ${widget.contenido.id} de $totalVideos · ${widget.contenido.tipo}',
              style: const TextStyle(
                color: UditTheme.textoSuave,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),
          ],
        ],
      ],
    );

    if (esPantallaCompleta) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: contenido),
      );
    }

    return UditScaffold(
      appBar: AppBar(
        title: const Text('Reproductor UDITflix'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: contenido,
      ),
    );
  }
}

/// Controles básicos del reproductor, extraídos para mantener el build legible.
class _ControlesVideo extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback alAlternar;
  final VoidCallback alReiniciar;
  final VoidCallback alPantallaCompleta;

  const _ControlesVideo({
    required this.controller,
    required this.alAlternar,
    required this.alReiniciar,
    required this.alPantallaCompleta,
  });

  @override
  Widget build(BuildContext context) {
    final duracion = controller.value.duration;
    final posicion = controller.value.position;

    return SurfacePanel(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            colors: VideoProgressColors(
              playedColor: UditTheme.rojo,
              bufferedColor: UditTheme.superficieClara,
              backgroundColor: UditTheme.textoSuave.withValues(alpha: 0.28),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formato(posicion),
                  style: const TextStyle(
                    color: UditTheme.rojo,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formato(duracion),
                  style: const TextStyle(color: UditTheme.textoSuave),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BotonControl(
                tooltip: 'Reiniciar',
                icono: Icons.replay,
                onPressed: alReiniciar,
              ),
              const SizedBox(width: 18),
              _BotonControl(
                tooltip: controller.value.isPlaying ? 'Pausar' : 'Reproducir',
                icono: controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                onPressed: alAlternar,
                destacado: true,
              ),
              const SizedBox(width: 18),
              _BotonControl(
                tooltip: 'Pantalla completa',
                icono: Icons.fullscreen,
                onPressed: alPantallaCompleta,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formato(Duration duration) {
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return '${dosDigitos(duration.inMinutes)}:${dosDigitos(duration.inSeconds % 60)}';
  }
}

class _BotonControl extends StatelessWidget {
  final String tooltip;
  final IconData icono;
  final VoidCallback onPressed;
  final bool destacado;

  const _BotonControl({
    required this.tooltip,
    required this.icono,
    required this.onPressed,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destacado ? UditTheme.rojo : UditTheme.texto;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: destacado ? 0.16 : 0.06),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icono, color: color, size: destacado ? 30 : 22),
      ),
    );
  }
}
