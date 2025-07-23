import 'package:flutter/material.dart';
import '../services/logs_service.dart';
import 'dart:async';

// 📝 PANTALLA: Logs de Actividad del Sistema
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen>
    with SingleTickerProviderStateMixin {
  // 📊 CONTROLADOR: Para las pestañas
  late TabController _tabController;

  // 📝 ESTADO: Lista de logs y estado de carga
  List<LogActividad> logs = [];
  List<LogActividad> logsResultadoBusqueda = [];
  EstadisticasLogs? estadisticas;
  bool isLoading = true;
  bool isSearching = false;
  String? error;

  // 🔍 ESTADO: Búsqueda y filtros
  final TextEditingController _busquedaController = TextEditingController();
  String _filtroAccion = 'todos';
  Timer? _debounceTimer;
  bool _mostrandoResultadoBusqueda = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 pestañas
    _cargarDatos();
    _busquedaController.addListener(_onBusquedaCambiada);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 📥 FUNCIÓN: Cargar datos iniciales
  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // 🔄 Cargar logs y estadísticas en paralelo
      final logsData = await LogsService.obtenerLogs(limit: 100);
      final estadisticasData = await LogsService.obtenerEstadisticas();

      setState(() {
        logs = logsData;
        estadisticas = estadisticasData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error cargando logs: $e';
      });
    }
  }

  // 🔍 FUNCIÓN: Manejar cambios en búsqueda con debounce
  void _onBusquedaCambiada() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_busquedaController.text.trim().isEmpty) {
        setState(() {
          _mostrandoResultadoBusqueda = false;
          logsResultadoBusqueda = [];
        });
      } else {
        _buscarLogs(_busquedaController.text);
      }
    });
  }

  // 🔍 FUNCIÓN: Buscar logs
  Future<void> _buscarLogs(String query) async {
    if (query.trim().length < 2) return;

    setState(() {
      isSearching = true;
    });

    try {
      final resultados = await LogsService.buscarLogs(query);
      setState(() {
        logsResultadoBusqueda = resultados;
        _mostrandoResultadoBusqueda = true;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      _mostrarError('Error buscando: $e');
    }
  }

  // ⚠️ FUNCIÓN: Mostrar mensaje de error
  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔍 GETTER: Logs filtrados por acción
  List<LogActividad> get _logsFiltrados {
    final logsParaFiltrar =
        _mostrandoResultadoBusqueda ? logsResultadoBusqueda : logs;

    if (_filtroAccion == 'todos') {
      return logsParaFiltrar;
    }
    return logsParaFiltrar.where((log) => log.accion == _filtroAccion).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Logs de Actividad'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Recargar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Actividad'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPestanaActividad(), // 📝 Pestaña de logs
          _buildPestanaEstadisticas(), // 📊 Pestaña de estadísticas
        ],
      ),
    );
  }

  // 📝 MÉTODO: Construir pestaña de actividad
  Widget _buildPestanaActividad() {
    return Column(
      children: [
        // 🔍 BARRA DE BÚSQUEDA Y FILTROS
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Column(
            children: [
              // 🔍 Campo de búsqueda
              TextField(
                controller: _busquedaController,
                decoration: InputDecoration(
                  hintText: 'Buscar en logs...',
                  prefixIcon: isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  suffixIcon: _busquedaController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _busquedaController.clear();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // 🔍 Filtro por acción
              Row(
                children: [
                  const Text('Filtrar por acción: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _filtroAccion,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                            value: 'todos', child: Text('Todas las acciones')),
                        ...LogsService.accionesDisponibles.map((accion) =>
                            DropdownMenuItem(
                                value: accion, child: Text(accion))),
                      ],
                      onChanged: (valor) {
                        setState(() {
                          _filtroAccion = valor ?? 'todos';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 📋 LISTA DE LOGS
        Expanded(
          child: _buildListaLogs(),
        ),
      ],
    );
  }

  // 📋 MÉTODO: Construir lista de logs
  Widget _buildListaLogs() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDatos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final logsFiltrados = _logsFiltrados;

    if (logsFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _mostrandoResultadoBusqueda
                  ? 'No se encontraron logs para "${_busquedaController.text}"'
                  : 'No hay logs disponibles',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: logsFiltrados.length,
      itemBuilder: (context, index) {
        final log = logsFiltrados[index];
        return _buildTarjetaLog(log);
      },
    );
  }

  // 🃏 MÉTODO: Construir tarjeta de log individual
  Widget _buildTarjetaLog(LogActividad log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _parseColor(log.colorAccion),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              log.iconoAccion,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        title: Text(
          log.descripcion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${log.accion} • ${log.fechaFormateada}'),
            if (log.usuarioNombre != null)
              Text('👤 ${log.usuarioNombre}',
                  style: TextStyle(color: Colors.blue.shade600)),
            if (log.ipAddress != null)
              Text('🌐 ${log.ipAddress}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: log.detalles != null
            ? IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _mostrarDetallesLog(log),
              )
            : null,
        onTap: () => _mostrarDetallesLog(log),
      ),
    );
  }

  // 🎨 FUNCIÓN: Convertir string de color a Color
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey; // Color por defecto si hay error
    }
  }

  // 📊 MÉTODO: Construir pestaña de estadísticas
  Widget _buildPestanaEstadisticas() {
    if (isLoading || estadisticas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Estadísticas Generales',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildTarjetaEstadistica(
                'Total Actividades',
                estadisticas!.totalActividades.toString(),
                Icons.format_list_numbered,
                Colors.blue,
              ),
              _buildTarjetaEstadistica(
                'Usuarios Activos',
                estadisticas!.usuariosActivos.toString(),
                Icons.people,
                Colors.green,
              ),
              _buildTarjetaEstadistica(
                'Total Logins',
                estadisticas!.totalLogins.toString(),
                Icons.login,
                Colors.orange,
              ),
              _buildTarjetaEstadistica(
                'Usuarios Creados',
                estadisticas!.usuariosCreados.toString(),
                Icons.person_add,
                Colors.purple,
              ),
              _buildTarjetaEstadistica(
                'Albaranes Creados',
                estadisticas!.albaranesCreados.toString(),
                Icons.description,
                Colors.teal,
              ),
              _buildTarjetaEstadistica(
                'Actividad 24h',
                estadisticas!.actividades24h.toString(),
                Icons.schedule,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📊 MÉTODO: Construir tarjeta de estadística
  Widget _buildTarjetaEstadistica(
      String titulo, String valor, IconData icono, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 FUNCIÓN: Mostrar detalles del log en un diálogo
  void _mostrarDetallesLog(LogActividad log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(log.iconoAccion),
            const SizedBox(width: 8),
            Expanded(child: Text(log.accion)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('📝 Descripción', log.descripcion),
              _buildDetalleItem('⏰ Fecha', log.createdAt.toString()),
              if (log.usuarioNombre != null)
                _buildDetalleItem(
                    '👤 Usuario', '${log.usuarioNombre} (${log.usuarioEmail})'),
              if (log.ipAddress != null)
                _buildDetalleItem('🌐 IP', log.ipAddress!),
              if (log.detalles != null) ...[
                const SizedBox(height: 12),
                const Text('📊 Detalles:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.detalles.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // 📝 MÉTODO: Construir item de detalle
  Widget _buildDetalleItem(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              etiqueta,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
