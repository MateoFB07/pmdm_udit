
//
// PANTALLA DEL CATÁLOGO — UDITFLIX (ESTILO STREAMING)
//
// Mantiene la navegación original:
//   Catálogo -> FichaScreen -> ReproductorScreen / ArcadeScreen
//
// Diseño: cartel destacado a pantalla ancha, barra superior con logotipo
// rojo y filas horizontales de tarjetas (ListView.builder).
//

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../data/imagenes.dart';
import '../models/contenido.dart';
import '../theme/udit_theme.dart';
import '../widgets/udit_ui.dart';
import 'arcade_screen.dart';
import 'ficha_screen.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  void _abrirFicha(BuildContext context, Contenido contenido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FichaScreen(contenido: contenido),
      ),
    );
  }

  void _abrirArcade(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArcadeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destacado = contenidos[5];

    // Las filas se reparten los títulos para no duplicar nombres en pantalla.
    final tendencias = contenidos.take(3).toList();
    final videos =
        contenidos.where((c) => c.tipo == 'Vídeo' && c.id != 1).toList();
    final otros = contenidos
        .where((c) => c.tipo != 'Vídeo' && c.id != destacado.id)
        .toList();

    return UditScaffold(
      appBar: AppBar(
        title: const Text('UDITflix'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Inicio',
              style: TextStyle(
                color: UditTheme.texto,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Series',
              style: TextStyle(color: UditTheme.textoSuave),
            ),
          ),
          IconButton(
            tooltip: 'UDIT Arcade',
            icon: const Icon(Icons.sports_esports),
            onPressed: () => _abrirArcade(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12, left: 2),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: UditTheme.rojo,
              child: Icon(
                Icons.person,
                size: 18,
                color: UditTheme.texto,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Hero(
              contenido: destacado,
              alAbrir: () => _abrirFicha(context, destacado),
            ),
          ),
          SliverToBoxAdapter(
            child: _Fila(
              titulo: 'Tendencias ahora',
              contenidos: tendencias,
              numeradas: true,
              alAbrir: (contenido) => _abrirFicha(context, contenido),
            ),
          ),
          SliverToBoxAdapter(
            child: _Fila(
              titulo: 'Vídeos para ti',
              contenidos: videos,
              alAbrir: (contenido) => _abrirFicha(context, contenido),
            ),
          ),
          SliverToBoxAdapter(
            child: _Fila(
              titulo: 'Cómics y juegos',
              contenidos: otros,
              alAbrir: (contenido) => _abrirFicha(context, contenido),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

/// Cartel principal, con imagen de fondo y acciones destacadas.
class _Hero extends StatelessWidget {
  final Contenido contenido;
  final VoidCallback alAbrir;

  const _Hero({
    required this.contenido,
    required this.alAbrir,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropImage(
      url: imagenDe(contenido),
      height: 300,
      overlay: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'N SERIE ORIGINAL UDIT',
              style: TextStyle(
                color: UditTheme.rojo,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              contenido.titulo,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 34,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 12),
                    ],
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'TOP 10',
                  style: TextStyle(
                    color: UditTheme.rojo,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  contenido.duracion,
                  style: const TextStyle(
                    color: UditTheme.texto,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                ContentBadge(tipo: contenido.tipo),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 460,
              child: Text(
                contenido.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE7E7E7),
                  fontSize: 14,
                  height: 1.45,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: alAbrir,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Reproducir'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: alAbrir,
                  icon: const Icon(Icons.info_outline, size: 19),
                  label: const Text('Más información'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    backgroundColor: const Color(0x66000000),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila horizontal de tarjetas, construida con ListView.builder.
class _Fila extends StatelessWidget {
  final String titulo;
  final List<Contenido> contenidos;
  final bool numeradas;
  final void Function(Contenido) alAbrir;

  const _Fila({
    required this.titulo,
    required this.contenidos,
    required this.alAbrir,
    this.numeradas = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RowHeader(titulo: titulo, accion: 'Explorar todos  >'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 178,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: contenidos.length,
            itemBuilder: (context, index) {
              return _Tarjeta(
                contenido: contenidos[index],
                posicion: index + 1,
                numerada: numeradas,
                alAbrir: () => alAbrir(contenidos[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Tarjeta de contenido con miniatura, posición y metadatos.
class _Tarjeta extends StatelessWidget {
  final Contenido contenido;
  final int posicion;
  final bool numerada;
  final VoidCallback alAbrir;

  const _Tarjeta({
    required this.contenido,
    required this.posicion,
    required this.numerada,
    required this.alAbrir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: alAbrir,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: double.infinity,
                    height: 116,
                    child: Image.network(
                      imagenDe(contenido),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const DecoratedBox(
                        decoration: BoxDecoration(gradient: UditTheme.acento),
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: UditTheme.sombraInferior),
                  ),
                ),
                if (numerada)
                  Positioned(
                    left: 8,
                    bottom: 0,
                    child: Text(
                      '$posicion',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                      ),
                    ),
                  ),
                const Positioned(
                  right: 8,
                  bottom: 8,
                  child: Icon(
                    Icons.play_circle_filled,
                    color: UditTheme.rojo,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              contenido.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: UditTheme.texto,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${contenido.tipo} · ${contenido.duracion}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: UditTheme.textoSuave,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
