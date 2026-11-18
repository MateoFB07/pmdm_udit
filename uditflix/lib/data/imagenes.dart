
//
// IMÁGENES DEL CATÁLOGO
//
// Las imágenes se sirven desde Unsplash (URL públicas verificadas).
// Se mantienen fuera del modelo Contenido para no alterar los datos
// ni los constructores existentes.
//

import '../models/contenido.dart';

const String _base = 'https://images.unsplash.com/';
const String _params = '?auto=format&fit=crop&w=1200&q=80';

const Map<int, String> _imagenes = {
  1: '${_base}photo-1518709268805-4e9042af9f23$_params',
  2: '${_base}photo-1451187580459-43490279c0fa$_params',
  3: '${_base}photo-1462331940025-496dfbfc7564$_params',
  4: '${_base}photo-1534796636912-3b95b3ab5986$_params',
  5: '${_base}photo-1446776811953-b23d57bd21aa$_params',
  6: '${_base}photo-1519681393784-d120267933ba$_params',
};

/// Devuelve la imagen asociada a un contenido, con un fallback seguro.
String imagenDe(Contenido contenido) {
  return _imagenes[contenido.id] ?? '${_base}photo-1451187580459-43490279c0fa$_params';
}
