
//
// COMPONENTES VISUALES DE UDITFLIX
//
// Biblioteca interna con la identidad visual de una plataforma de
// streaming: negro de sala de cine, rojo corporativo, filas horizontales
// y panels sobrios. No añade dependencias ni modifica la lógica.
//

import 'package:flutter/material.dart';

import '../theme/udit_theme.dart';

/// Scaffold base con el fondo negro/degradado de UDITflix.
class UditScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;

  const UditScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: UditTheme.fondo),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: appBar,
        body: SafeArea(child: body),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

/// Superficie oscura sobria, usada en fichas, reproductor y arcade.
class SurfacePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SurfacePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: UditTheme.superficie,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? const Color(0x24FFFFFF),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return panel;

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: panel,
    );
  }
}

/// Cabecera de una fila del catálogo, estilo Netflix.
class RowHeader extends StatelessWidget {
  final String titulo;
  final String? accion;

  const RowHeader({
    super.key,
    required this.titulo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                letterSpacing: -0.2,
              ),
        ),
        const Spacer(),
        if (accion != null)
          Text(
            accion!,
            style: const TextStyle(
              color: UditTheme.textoSuave,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

/// Etiqueta roja de tipo de contenido (Vídeo / Cómic / Juego).
class ContentBadge extends StatelessWidget {
  final String tipo;

  const ContentBadge({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: UditTheme.rojo.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: UditTheme.rojo.withValues(alpha: 0.75)),
      ),
      child: Text(
        tipo.toUpperCase(),
        style: const TextStyle(
          color: UditTheme.rojo,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Imagen de cabecera con degradado inferior y fallback seguro.
class BackdropImage extends StatelessWidget {
  final String url;
  final double height;
  final Widget? overlay;
  final BorderRadius borderRadius;

  const BackdropImage({
    super.key,
    required this.url,
    this.height = 220,
    this.overlay,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const DecoratedBox(
                  decoration: BoxDecoration(gradient: UditTheme.acento),
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: UditTheme.sombraInferior),
              ),
            ),
            ?overlay,
          ],
        ),
      ),
    );
  }
}
