import 'package:flutter/material.dart';

import 'screens/catalogo_screen.dart';
import 'theme/udit_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDITflix',
      debugShowCheckedModeBanner: false,
      theme: UditTheme.theme,
      home: const CatalogoScreen(),
    );
  }
}
