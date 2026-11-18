
//
// VÍDEOS DEL CATÁLOGO
//
// Cada contenido abre su propio vídeo de demostración. Todas las URLs
// han sido verificadas (HTTP 200, content-type video/mp4 y CORS *),
// para que funcionen tanto en Android como en la versión web.
//

import '../models/contenido.dart';

/// Vídeo principal (se mantiene como constante pública por compatibilidad).
const String videoPrincipalUrl =
    'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4';

const Map<int, String> _videos = {
  1: videoPrincipalUrl,
  2: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4',
  3: 'https://cdn.jsdelivr.net/gh/mediaelement/mediaelement-files@master/big_buck_bunny.mp4',
  4: 'https://cdn.jsdelivr.net/gh/mediaelement/mediaelement-files@master/echo-hereweare.mp4',
  5: 'https://download.samplelib.com/mp4/sample-10s.mp4',
  6: 'https://download.samplelib.com/mp4/sample-20s.mp4',
};

/// Devuelve el vídeo asociado a un contenido, con fallback seguro.
String videoDe(Contenido contenido) =>
    _videos[contenido.id] ?? videoPrincipalUrl;

/// Número de vídeos distintos disponibles en la demostración.
int get totalVideos => _videos.length;
