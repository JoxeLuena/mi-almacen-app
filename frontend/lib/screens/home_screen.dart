import 'detalle_albaran_screen.dart';            // 📱 NUEVO: Importar la pantalla de detalles
import 'package:flutter/material.dart';          // 🎨 Widgets de Flutter (botones, listas, etc.)
import '../models/albaran.dart';                  // 📋 Nuestro modelo de datos
import '../services/api_service.dart';           // 🌐 Nuestro servicio para conectar con la API


class HomeScreen extends StatefulWidget {        // 📱 Pantalla que puede cambiar (estado dinámico)
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Albaran> albaranes = [];                  // 📋 Lista que guardará los albaranes
  bool isLoading = true;                         // ⏳ Bandera para mostrar "Cargando..."
  String? error;                                 // ❌ Para guardar mensajes de error

  @override
  void initState() {                             // 🚀 Se ejecuta automáticamente al crear la pantalla
    super.initState();
    cargarAlbaranes();                           // 📥 Cargar datos nada más abrir la app
  }

  // 📥 FUNCIÓN: Cargar albaranes desde la API
  Future<void> cargarAlbaranes() async {
    try {
      setState(() {                              // 🔄 Decir a Flutter: "voy a cambiar datos, redibuja la pantalla"
        isLoading = true;                        // ⏳ Mostrar indicador de carga
        error = null;                            // 🧹 Limpiar errores anteriores
      });

      final albaranesData = await ApiService.getAlbaranes(); // 🌐 Llamar a nuestra API

      setState(() {                              // 🔄 Actualizar pantalla con los datos nuevos
        albaranes = albaranesData;               // 📋 Guardar los albaranes obtenidos
        isLoading = false;                       // ✅ Ya no está cargando
      });
    } catch (e) {
      setState(() {                              // 🔄 Si hay error, actualizar pantalla
        isLoading = false;                       // ✅ Ya no está cargando
        error = 'Error: $e';                     // ❌ Mostrar el error al usuario
      });
    }
  }

  @override
  Widget build(BuildContext context) {          // 🎨 FUNCIÓN: Construir la interfaz visual
    return Scaffold(                             // 📱 Estructura básica de pantalla Flutter
      appBar: AppBar(                           // 📊 Barra superior
        title: const Text('Gestión de Albaranes'), // 🏷️ Título de la app
        backgroundColor: Colors.blue,            // 🎨 Color de fondo azul
        foregroundColor: Colors.white,           // 🎨 Color del texto blanco
      ),
      body: _buildBody(),                        // 📄 El contenido principal (función abajo)
      floatingActionButton: FloatingActionButton( // ➕ Botón redondo flotante
        onPressed: () {                          // 👆 Qué hacer cuando lo pulsen
          // TODO: Navegar a crear albarán
        },
        child: const Icon(Icons.add),            // ➕ Icono de "más"
      ),
    );
  }

  // 📄 FUNCIÓN: Construir el contenido principal
  Widget _buildBody() {
    if (isLoading) {                             // ⏳ Si está cargando
      return const Center(                       // 🎯 Centrar en pantalla
        child: CircularProgressIndicator(),      // ⭕ Ruedita de carga
      );
    }

    if (error != null) {                         // ❌ Si hay error
      return Center(                             // 🎯 Centrar en pantalla
        child: Column(                           // 📋 Columna vertical
          mainAxisAlignment: MainAxisAlignment.center, // 🎯 Centrar verticalmente
          children: [
            Text(error!),                        // ❌ Mostrar mensaje de error
            const SizedBox(height: 16),          // 📏 Espacio vertical
            ElevatedButton(                      // 🔄 Botón para reintentar
              onPressed: cargarAlbaranes,        // 👆 Volver a cargar datos
              child: const Text('Reintentar'),   // 🏷️ Texto del botón
            ),
          ],
        ),
      );
    }

    // ✅ Si todo va bien, mostrar la lista
    return ListView.builder(                     // 📋 Lista desplazable
      itemCount: albaranes.length,               // 📊 Cuántos elementos mostrar
      itemBuilder: (context, index) {           // 🏗️ Cómo construir cada elemento
        final albaran = albaranes[index];        // 📋 Obtener albarán actual
        return Card(                             // 🃏 Tarjeta con bordes redondeados
          margin: const EdgeInsets.all(8),       // 📏 Margen alrededor
          child: ListTile(                       // 📋 Elemento de lista estándar
            title: Text('${albaran.numeroAlbaran} - ${albaran.cliente}'), // 🏷️ Título principal
            subtitle: Text('Estado: ${albaran.estado}'), // 🏷️ Subtítulo
            trailing: const Icon(Icons.arrow_forward_ios), // ➡️ Flecha derecha
           onTap: () {                          // 👆 Qué hacer cuando lo pulsen
  // 🚀 NAVEGACIÓN: Ir a la pantalla de detalles
  Navigator.push(                    // 📱 Abrir nueva pantalla
    context,                         // 🌍 Contexto actual de la app
    MaterialPageRoute(               // 🛣️ Tipo de navegación (con animación)
      builder: (context) => DetalleAlbaranScreen(albaran: albaran), // 🏗️ Crear la pantalla de detalles pasándole el albarán
    ),
  );
},
          ),
        );
      },
    );
  }
}