
//
// PANTALLA DE FICHA — UDITFLIX (ESTILO STREAMING)
//
// Recibe el mismo objeto Contenido de siempre y conserva la navegación:
//   -> "Ver contenido" abre el reproductor.
//   -> "Jugar en UDIT Arcade" abre el minijuego (solo para tipo Juego).
//

import 'package:flutter/material.dart';

import '../data/imagenes.dart';
import '../models/contenido.dart';
import '../theme/udit_theme.dart';
import '../widgets/udit_ui.dart';
import 'arcade_screen.dart';
import 'reproductor_screen.dart';

class FichaScreen extends StatelessWidget {
  final Contenido contenido;

  const FichaScreen({
    super.key,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return UditScaffold(
      appBar: AppBar(
        title: Text(
          contenido.titulo,
          style: const TextStyle(
            color: UditTheme.texto,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BackdropImage(
              url: imagenDe(contenido),
              height: 190,
              overlay: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContentBadge(tipo: contenido.tipo),
                    const SizedBox(height: 10),
                    Text(
                      contenido.titulo,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: 24,
                            shadows: const [
                              Shadow(color: Colors.black87, blurRadius: 10),
                            ],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: UditTheme.rojo,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          contenido.duracion,
                          style: const TextStyle(
                            color: UditTheme.texto,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SurfacePanel(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowHeader(
                      titulo: 'Ficha técnica',
                      accion: 'ID ${contenido.id}',
                    ),
                    const SizedBox(height: 14),
                    _FilaDato(etiqueta: 'TIPO', valor: contenido.tipo),
                    const SizedBox(height: 8),
                    _FilaDato(etiqueta: 'DURACIÓN', valor: contenido.duracion),
                    const Divider(height: 22),
                    Text(
                      contenido.descripcion,
                      style: const TextStyle(
                        color: Color(0xFFE7E7E7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (contenido.tipo == 'Juego') ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.sports_esports),
                      label: const Text('Jugar en UDIT Arcade'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArcadeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Ver contenido'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReproductorScreen(
                            contenido: contenido,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaDato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: UditTheme.textoSuave,
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              color: UditTheme.texto,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
