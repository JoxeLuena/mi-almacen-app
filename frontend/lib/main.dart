import 'package:flutter/material.dart';    // 🎨 Importar los widgets básicos de Flutter
import 'screens/home_screen.dart';         // 📱 Importar nuestra pantalla principal

void main() {                              // 🚀 FUNCIÓN PRINCIPAL: Punto de entrada de la app
  runApp(const MyApp());                   // ▶️ Ejecutar nuestra aplicación
}

class MyApp extends StatelessWidget {      // 🏗️ CLASE: Configuración principal de la app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {     // 🎨 FUNCIÓN: Construir la estructura principal
    return MaterialApp(                    // 📱 App con diseño Material (estilo Android/Google)
      title: 'Gestión Almacén',            // 🏷️ Nombre de la app (aparece en el navegador)
      debugShowCheckedModeBanner: false,   // 🚫 Quitar el banner "DEBUG" de arriba
      theme: ThemeData(                    // 🎨 CONFIGURACIÓN: Colores y estilos globales
        colorScheme: ColorScheme.fromSeed( // 🌈 Esquema de colores basado en un color principal
          seedColor: Colors.blue,          // 🔵 Color principal: azul
        ),
        useMaterial3: true,                // ✨ Usar la versión más moderna de Material Design
      ),
      home: const HomeScreen(),            // 🏠 PANTALLA INICIAL: Nuestra pantalla de albaranes
    );
  }
}