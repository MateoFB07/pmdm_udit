import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uditflix/arcade/marcianitos_udit_game.dart';
import 'package:uditflix/data/contenidos.dart';
import 'package:uditflix/data/videos.dart';
import 'package:uditflix/screens/arcade_screen.dart';
import 'package:uditflix/screens/catalogo_screen.dart';
import 'package:uditflix/screens/ficha_screen.dart';
import 'package:uditflix/screens/reproductor_screen.dart';

void main() {
  testWidgets('el catálogo permite abrir UDIT Arcade', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogoScreen()));

    expect(find.byTooltip('UDIT Arcade'), findsOneWidget);

    await tester.tap(find.byTooltip('UDIT Arcade'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('UDIT Arcade'), findsWidgets);
    expect(find.text('Marcianitos UDIT'), findsOneWidget);
    expect(find.text('Game Over'), findsNothing);
  });

  testWidgets('la ficha de un juego muestra el acceso a UDIT Arcade',
      (tester) async {
    final juego = contenidos.firstWhere((c) => c.tipo == 'Juego');

    await tester.pumpWidget(
      MaterialApp(home: FichaScreen(contenido: juego)),
    );

    expect(find.text('Jugar en UDIT Arcade'), findsOneWidget);
    expect(find.text('Ver contenido'), findsOneWidget);

    await tester.tap(find.text('Jugar en UDIT Arcade'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('UDIT Arcade'), findsWidgets);
  });

  testWidgets('la ficha de un vídeo conserva el acceso al reproductor',
      (tester) async {
    final video = contenidos.firstWhere((c) => c.tipo == 'Vídeo');

    await tester.pumpWidget(
      MaterialApp(home: FichaScreen(contenido: video)),
    );

    expect(find.text('Ver contenido'), findsOneWidget);
    expect(find.text('Jugar en UDIT Arcade'), findsNothing);
  });

  testWidgets('el juego empieza con puntuación cero', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ArcadeScreen()));

    expect(find.text('Puntos: 0'), findsOneWidget);
    expect(find.text('Toca para disparar'), findsOneWidget);
  });

  test('el vídeo de demostración usa una URL https accesible', () {
    final uri = Uri.parse(videoDemostracionUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, 'interactive-examples.mdn.mozilla.net');
    expect(uri.path.endsWith('.mp4'), isTrue);
  });

  test('cada contenido abre un vídeo diferente', () {
    final urls = contenidos.map((contenido) => videoDe(contenido)).toList();

    expect(urls.toSet().length, contenidos.length);
    expect(videoDe(contenidos.first), videoDemostracionUrl);

    for (final url in urls) {
      final uri = Uri.parse(url);
      expect(uri.scheme, 'https');
      expect(uri.path.endsWith('.mp4'), isTrue);
    }
  });

  test('el juego expone los parámetros de demostración', () {
    expect(MarcianitosUditGame.velocidadNave, greaterThan(0));
    expect(MarcianitosUditGame.velocidadBala, greaterThan(0));
    expect(MarcianitosUditGame.velocidadMarcianitoInicial, greaterThan(0));
    expect(MarcianitosUditGame.filas, greaterThan(0));
    expect(MarcianitosUditGame.columnas, greaterThan(0));
  });
}
