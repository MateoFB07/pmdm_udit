// MODELO CONTENIDO

// Esta clase representa un contenido de nuestra plataforma UDITflix.
// Por ejemplo: una película, uncómic o un videojuego.

// En programación orientada a objetos, una clase define
// qué características tendrán los objetos que creamos.

class Contenido {
  final int id;
  final String titulo;
  final String descripcion;
  // Tipo de contenido: vídeo, cómic, juego.
  final String tipo;
  final String duracion;

  // Constructor: permite crear nuevos contenidos.

  const Contenido({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.duracion,
  });
}
