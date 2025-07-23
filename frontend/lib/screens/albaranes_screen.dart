import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/albaran.dart'; // 📋 Modelo de albarán
import '../services/api_service.dart'; // 🌐 Servicio API
import '../services/impresion_service.dart'; // 🖨️ Servicio impresión
import 'detalle_albaran_screen.dart'; // 📱 Pantalla detalle
import 'crear_albaran_screen.dart'; // 📱 Pantalla crear

// 📋 PANTALLA: Gestión de Albaranes (renombrada de HomeScreen)
class AlbaranesScreen extends StatefulWidget {
  const AlbaranesScreen({super.key});

  @override
  State<AlbaranesScreen> createState() => _AlbaranesScreenState();
}

class _AlbaranesScreenState extends State<AlbaranesScreen> {
  // 📋 ESTADO: Lista de albaranes y estado de carga
  List<Albaran> albaranes = []; // 📋 Lista de albaranes
  bool isLoading = true; // ⏳ Indicador de carga
  String? error; // ❌ Mensaje de error
  String _filtroEstado = 'todos'; // 🔍 Filtro por estado

  // 🖨️ ESTADO: Control de impresión
  Set<int> _imprimiendo = {}; // 📊 IDs de albaranes que se están imprimiendo

  @override
  void initState() {
    super.initState();
    cargarAlbaranes(); // 📥 Cargar albaranes al iniciar
  }

  // 📥 FUNCIÓN: Cargar albaranes desde la API
  Future<void> cargarAlbaranes() async {
    try {
      setState(() {
        isLoading = true; // ⏳ Mostrar carga
        error = null; // 🧹 Limpiar errores
      });

      // 🌐 LLAMADA API: Obtener albaranes
      final albaranesData = await ApiService.getAlbaranes();

      setState(() {
        albaranes = albaranesData; // 📋 Guardar albaranes
        isLoading = false; // ✅ Terminar carga
      });
    } catch (e) {
      setState(() {
        isLoading = false; // ✅ Terminar carga
        error = 'Error: $e'; // ❌ Guardar error
      });
    }
  }

  // ➕ FUNCIÓN: Navegar a crear albarán
  Future<void> _navegarACrearAlbaran() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearAlbaranScreen()),
    );

    if (resultado == true) {
      cargarAlbaranes(); // 🔄 Recargar si se creó albarán
    }
  }

  // 🖨️ FUNCIÓN: Imprimir albarán desde la lista
  Future<void> _imprimirAlbaranRapido(Albaran albaran) async {
    setState(() {
      _imprimiendo.add(albaran.id); // ⏳ Marcar como imprimiendo
    });

    try {
      // 🖨️ LLAMADA AL SERVICIO: Imprimir albarán
      await ImpresionService.imprimirAlbaran(albaran.id);

      // ✅ ÉXITO: Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🖨️ Albarán ${albaran.numeroAlbaran} enviado a impresión'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // ❌ ERROR: Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error imprimiendo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _imprimiendo.remove(albaran.id); // ✅ Quitar de imprimiendo
        });
      }
    }
  }

  // 🔍 FUNCIÓN: Filtrar albaranes por estado
  List<Albaran> get albaranesFiltrados {
    if (_filtroEstado == 'todos') {
      return albaranes; // 📋 Mostrar todos
    }
    return albaranes.where((a) => a.estado == _filtroEstado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📱 Estructura básica
      appBar: AppBar(
        // 📊 Barra superior
        title: const Text('Gestión de Albaranes'), // 🏷️ Título
        backgroundColor: Colors.blue, // 🔵 Fondo azul
        foregroundColor:
            const Color.fromARGB(255, 255, 254, 254), // ⚪ Texto Negro
        actions: [
          // 🔄 BOTÓN: Recargar
          IconButton(
            icon: const Icon(Icons.refresh), // 🔄 Icono recargar
            onPressed: cargarAlbaranes, // 👆 Acción recargar
            tooltip: 'Recargar Lista', // 💡 Tooltip
          ),
        ],
        bottom: PreferredSize(
          // 🔍 FILTROS: Barra de filtros debajo del AppBar
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color.fromARGB(255, 57, 102, 250),
            child: Row(
              children: [
                const Text(
                  'Filtrar:', // 🏷️ Etiqueta
                  style: TextStyle(
                      color: Color.fromARGB(255, 17, 17, 17),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // ↔️ Scroll horizontal
                    child: Row(
                      children: [
                        _buildChipFiltro('todos', 'Todos'),
                        _buildChipFiltro('pendiente', 'Pendientes'),
                        _buildChipFiltro('enviado', 'Enviados'),
                        _buildChipFiltro('entregado', 'Entregados'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(), // 📄 Contenido principal
      floatingActionButton: FloatingActionButton(
        // ➕ Botón flotante crear
        onPressed: _navegarACrearAlbaran, // 👆 Acción crear
        backgroundColor: Colors.blue, // 🔵 Fondo azul
        child: const Icon(Icons.add,
            color: Color.fromARGB(255, 10, 10, 10)), // ➕ Icono más blanco
        tooltip: 'Crear Nuevo Albarán', // 💡 Tooltip
      ),
    );
  }

  // 🏗️ MÉTODO: Construir chip de filtro
  Widget _buildChipFiltro(String valor, String etiqueta) {
    final seleccionado = _filtroEstado == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(etiqueta), // 🏷️ Texto del chip
        selected: seleccionado, // ✅ Si está seleccionado
        onSelected: (selected) {
          // 👆 Cambiar filtro
          setState(() {
            _filtroEstado = valor; // 🔍 Actualizar filtro
          });
        },
        selectedColor: Colors.white.withOpacity(0.3), // 🎨 Color seleccionado
        labelStyle: TextStyle(
          color: seleccionado
              ? const Color.fromARGB(255, 4, 199, 53)
              : const Color.fromARGB(179, 63, 51, 51),
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // 🏗️ MÉTODO: Construir contenido principal
  Widget _buildBody() {
    if (isLoading) {
      // ⏳ Si está cargando
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      // ❌ Si hay error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: cargarAlbaranes, // 🔄 Reintentar
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final albaranesMostrar = albaranesFiltrados;

    if (albaranesMostrar.isEmpty) {
      // 📋 Si no hay albaranes (después del filtro)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _filtroEstado == 'todos'
                  ? 'No hay albaranes creados'
                  : 'No hay albaranes con estado "$_filtroEstado"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_filtroEstado == 'todos')
              ElevatedButton.icon(
                onPressed: _navegarACrearAlbaran,
                icon: const Icon(Icons.add),
                label: const Text('Crear Primer Albarán'),
              ),
          ],
        ),
      );
    }

    // 📋 LISTA: Mostrar albaranes
    return Column(
      children: [
        // 📊 ESTADÍSTICAS: Resumen rápido
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEstadistica('Total', albaranes.length, Colors.blue),
              _buildEstadistica(
                  'Pendientes',
                  albaranes.where((a) => a.estado == 'pendiente').length,
                  Colors.orange),
              _buildEstadistica(
                  'Enviados',
                  albaranes.where((a) => a.estado == 'enviado').length,
                  Colors.blue),
              _buildEstadistica(
                  'Entregados',
                  albaranes.where((a) => a.estado == 'entregado').length,
                  Colors.green),
            ],
          ),
        ),
        // 📋 LISTA: Albaranes filtrados
        Expanded(
          child: ListView.builder(
            itemCount: albaranesMostrar.length,
            itemBuilder: (context, index) {
              final albaran = albaranesMostrar[index];
              return _buildAlbaranCard(
                  albaran); // 🏗️ Construir card de albarán
            },
          ),
        ),
      ],
    );
  }

  // 🏗️ MÉTODO: Construir estadística
  Widget _buildEstadistica(String etiqueta, int cantidad, Color color) {
    return Column(
      children: [
        Text(
          cantidad.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          etiqueta,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // 🏗️ MÉTODO: Construir card de albarán
  Widget _buildAlbaranCard(Albaran albaran) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        // 📦 ICONO: Según el estado
        leading: CircleAvatar(
          backgroundColor: _getColorEstado(albaran.estado),
          child: Icon(
            _getIconoEstado(albaran.estado),
            color: Colors.white,
            size: 20,
          ),
        ),
        // 📝 TÍTULO: Número y cliente
        title: Text(
          '${albaran.numeroAlbaran} - ${albaran.cliente}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // 📊 SUBTÍTULO: Estado y fecha
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getColorEstado(albaran.estado),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    albaran.estado.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatearFecha(albaran.fechaCreacion),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        // 🔘 ACCIONES: Botones de acción
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🖨️ BOTÓN: Imprimir rápido
            if (_imprimiendo.contains(albaran.id))
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.print, size: 20),
                onPressed: () => _imprimirAlbaranRapido(albaran),
                tooltip: 'Imprimir',
                color: Colors.blue,
              ),
            // ➡️ ICONO: Ir al detalle
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        // 👆 ACCIÓN: Ir al detalle
        onTap: () async {
          // 🔄 NAVEGAR: Esperar resultado de la pantalla de detalle
          final huboCambios = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleAlbaranScreen(albaran: albaran),
            ),
          );

          // 🔄 RECARGAR: Si hubo cambios, actualizar la lista
          if (huboCambios == true) {
            cargarAlbaranes(); // Recargar lista de albaranes
          }
        },
      ),
    );
  }

  // 🎨 FUNCIÓN AUXILIAR: Obtener color según el estado
  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'enviado':
        return Colors.blue;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 🎯 FUNCIÓN AUXILIAR: Obtener icono según el estado
  IconData _getIconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule;
      case 'enviado':
        return Icons.local_shipping;
      case 'entregado':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  // 📅 FUNCIÓN AUXILIAR: Formatear fecha
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
