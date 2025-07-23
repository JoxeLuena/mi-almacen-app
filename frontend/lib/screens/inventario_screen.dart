import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/producto_disponible.dart'; // 📦 Modelo producto
import '../services/productos_service.dart'; // 🏢 Servicio productos
import '../services/busqueda_service.dart'; // 🔍 Servicio búsqueda
import '../widgets/autocompletado_producto_widget.dart'; // 🔍 Widget autocompletado

// 📦 PANTALLA: Gestión completa de inventario
class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with SingleTickerProviderStateMixin {
  // 📊 CONTROLADOR: Para las pestañas
  late TabController _tabController;

  // 📦 ESTADO: Lista de productos
  List<ProductoDisponible> productos = [];
  List<ProductoDisponible> productosFiltrados = [];
  bool isLoading = true;
  String? error;

  // 🔍 ESTADO: Búsqueda y filtros
  final TextEditingController _busquedaController = TextEditingController();
  String _filtroUso = 'todos';
  String _filtroStock = 'todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 pestañas
    _cargarProductos();
    _busquedaController.addListener(_filtrarProductos);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  // 📥 FUNCIÓN: Cargar productos del inventario
  Future<void> _cargarProductos() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final productosData = await ProductosService.cargarProductosDisponibles();
      setState(() {
        productos = productosData;
        _filtrarProductos(); // Aplicar filtros iniciales
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error cargando productos: $e';
      });
    }
  }

  // 🔍 FUNCIÓN: Filtrar productos según criterios
  void _filtrarProductos() {
    final query = _busquedaController.text.toLowerCase();

    setState(() {
      productosFiltrados = productos.where((producto) {
        // 🔍 Filtro por texto (referencia o descripción)
        final coincideTexto = query.isEmpty ||
            producto.referencia.toLowerCase().contains(query) ||
            producto.descripcion.toLowerCase().contains(query);

        // 📊 Filtro por stock
        final coincideStock = _filtroStock == 'todos' ||
            (_filtroStock == 'bajo' && producto.stockActual < 10) ||
            (_filtroStock == 'sin' && producto.stockActual == 0) ||
            (_filtroStock == 'normal' && producto.stockActual >= 10);

        return coincideTexto && coincideStock;
      }).toList();

      // 📊 Ordenar por referencia
      productosFiltrados.sort((a, b) => a.referencia.compareTo(b.referencia));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: 'Productos'),
            Tab(icon: Icon(Icons.edit), text: 'Ajustes'),
            Tab(icon: Icon(Icons.analytics), text: 'Reportes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarProductos,
            tooltip: 'Recargar inventario',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabProductos(), // 📦 Pestaña productos
          _buildTabAjustes(), // ✏️ Pestaña ajustes
          _buildTabReportes(), // 📊 Pestaña reportes
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _mostrarDialogoCrearProducto,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Crear Nuevo Producto',
            )
          : null,
    );
  }

  // 📦 MÉTODO: Construir pestaña de productos
  Widget _buildTabProductos() {
    return Column(
      children: [
        // 🔍 SECCIÓN: Barra de búsqueda y filtros
        _buildBarraBusqueda(),
        // 📊 SECCIÓN: Estadísticas rápidas
        _buildEstadisticasRapidas(),
        // 📋 SECCIÓN: Lista de productos
        Expanded(child: _buildListaProductos()),
      ],
    );
  }

  // 🔍 MÉTODO: Construir barra de búsqueda
  Widget _buildBarraBusqueda() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // 🔍 CAMPO: Búsqueda por texto
          TextFormField(
            controller: _busquedaController,
            decoration: const InputDecoration(
              labelText: 'Buscar productos',
              hintText: 'Referencia o descripción...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          // 🔽 FILTROS: Stock
          Row(
            children: [
              const Text('Stock: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChipFiltro('todos', 'Todos', _filtroStock, (valor) {
                        setState(() {
                          _filtroStock = valor;
                          _filtrarProductos();
                        });
                      }),
                      _buildChipFiltro('normal', 'Normal (≥10)', _filtroStock,
                          (valor) {
                        setState(() {
                          _filtroStock = valor;
                          _filtrarProductos();
                        });
                      }),
                      _buildChipFiltro('bajo', 'Bajo (<10)', _filtroStock,
                          (valor) {
                        setState(() {
                          _filtroStock = valor;
                          _filtrarProductos();
                        });
                      }),
                      _buildChipFiltro('sin', 'Sin Stock', _filtroStock,
                          (valor) {
                        setState(() {
                          _filtroStock = valor;
                          _filtrarProductos();
                        });
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📊 MÉTODO: Construir estadísticas rápidas
  Widget _buildEstadisticasRapidas() {
    final totalProductos = productos.length;
    final stockBajo = productos.where((p) => p.stockActual < 10).length;
    final sinStock = productos.where((p) => p.stockActual == 0).length;
    final valorTotal = productos.fold(
        0.0, (sum, p) => sum + (p.stockActual * 1.0)); // Asumir precio promedio

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEstadisticaRapida('Total\nProductos', totalProductos.toString(),
              Icons.inventory, Colors.blue),
          _buildEstadisticaRapida('Stock\nBajo', stockBajo.toString(),
              Icons.warning, Colors.orange),
          _buildEstadisticaRapida(
              'Sin\nStock', sinStock.toString(), Icons.error, Colors.red),
          _buildEstadisticaRapida(
              'Filtrados',
              productosFiltrados.length.toString(),
              Icons.filter_list,
              Colors.green),
        ],
      ),
    );
  }

  // 📊 MÉTODO: Construir estadística individual
  Widget _buildEstadisticaRapida(
      String titulo, String valor, IconData icono, Color color) {
    return Column(
      children: [
        Icon(icono, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 📋 MÉTODO: Construir lista de productos
  Widget _buildListaProductos() {
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
              onPressed: _cargarProductos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (productosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No se encontraron productos',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros de búsqueda',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: productosFiltrados.length,
      itemBuilder: (context, index) {
        final producto = productosFiltrados[index];
        return _buildProductoCard(producto);
      },
    );
  }

  // 🃏 MÉTODO: Construir tarjeta de producto
  Widget _buildProductoCard(ProductoDisponible producto) {
    final colorStock = _getColorStock(producto.stockActual);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        // 📦 ICONO: Stock con color
        leading: CircleAvatar(
          backgroundColor: colorStock,
          child: Text(
            producto.stockActual.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        // 📝 TÍTULO: Referencia
        title: Text(
          producto.referencia,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // 📝 SUBTÍTULO: Descripción
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(producto.descripcion),
            const SizedBox(height: 4),
            Text(
              'Stock: ${producto.stockActual} unidades',
              style: TextStyle(
                color: colorStock,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        // 🔘 ACCIONES: Botones
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editarProducto(producto),
              tooltip: 'Editar producto',
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _ajustarStock(producto, true),
              tooltip: 'Ajuste positivo',
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _ajustarStock(producto, false),
              tooltip: 'Ajuste negativo',
            ),
          ],
        ),
      ),
    );
  }

  // ✏️ MÉTODO: Construir pestaña de ajustes
  Widget _buildTabAjustes() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Módulo de Ajustes', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Funcionalidad en desarrollo',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 📊 MÉTODO: Construir pestaña de reportes
  Widget _buildTabReportes() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Módulo de Reportes', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Funcionalidad en desarrollo',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 🏗️ MÉTODO: Construir chip de filtro
  Widget _buildChipFiltro(String valor, String etiqueta, String filtroActual,
      Function(String) onSelected) {
    final seleccionado = filtroActual == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(etiqueta),
        selected: seleccionado,
        onSelected: (selected) => onSelected(valor),
        selectedColor: Colors.green.withOpacity(0.3),
        labelStyle: TextStyle(
          color: seleccionado ? Colors.green.shade700 : Colors.black54,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // ➕ FUNCIÓN: Mostrar diálogo crear producto
  void _mostrarDialogoCrearProducto() {
    final referenciaController = TextEditingController();
    final descripcionController = TextEditingController();
    final stockController = TextEditingController(text: '0');
    final precioController = TextEditingController();
    String usoSeleccionado = 'produccion';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Nuevo Producto'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: referenciaController,
                        decoration: const InputDecoration(
                          labelText: 'Referencia *',
                          hintText: 'REF001, TORN-M6, etc.',
                          prefixIcon: Icon(Icons.tag),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Descripción detallada',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: usoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Uso del Producto *',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items:
                            BusquedaService.obtenerUsosDisponibles().map((uso) {
                          return DropdownMenuItem<String>(
                            value: uso['valor'],
                            child: Text(uso['etiqueta']!),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            usoSeleccionado = newValue ?? 'produccion';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: precioController,
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.euro),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Inicial',
                          hintText: '0',
                          prefixIcon: Icon(Icons.inventory),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => _procesarCrearProducto(
                    referenciaController.text,
                    descripcionController.text,
                    usoSeleccionado,
                    precioController.text,
                    stockController.text,
                  ),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ➕ FUNCIÓN: Procesar creación de producto
  Future<void> _procesarCrearProducto(
    String referencia,
    String descripcion,
    String uso,
    String precioTexto,
    String stockTexto,
  ) async {
    // Validaciones
    final errorReferencia = BusquedaService.validarReferencia(referencia);
    if (errorReferencia != null) {
      _mostrarError(errorReferencia);
      return;
    }

    final errorDescripcion = BusquedaService.validarDescripcion(descripcion);
    if (errorDescripcion != null) {
      _mostrarError(errorDescripcion);
      return;
    }

    final precio =
        precioTexto.trim().isEmpty ? null : double.tryParse(precioTexto);
    if (precioTexto.trim().isNotEmpty && precio == null) {
      _mostrarError('El precio debe ser un número válido');
      return;
    }

    final stock = int.tryParse(stockTexto) ?? 0;
    if (stock < 0) {
      _mostrarError('El stock no puede ser negativo');
      return;
    }

    try {
      Navigator.of(context).pop();

      final productoCreado = await BusquedaService.crearProducto(
        referencia: referencia,
        descripcion: descripcion,
        uso: uso,
        precio: precio,
        stockActual: stock,
      );

      if (productoCreado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Producto ${productoCreado.referencia} creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarProductos(); // Recargar lista
      }
    } catch (e) {
      _mostrarError('Error creando producto: $e');
    }
  }

  // ✏️ FUNCIÓN: Editar producto
  void _editarProducto(ProductoDisponible producto) {
    // TODO: Implementar edición de producto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edición de productos - Próximamente')),
    );
  }

  // 📊 FUNCIÓN: Ajustar stock
  void _ajustarStock(ProductoDisponible producto, bool esPositivo) {
    final cantidadController = TextEditingController();
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Ajuste ${esPositivo ? 'Positivo' : 'Negativo'} de Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: ${producto.referencia}'),
              Text('Stock actual: ${producto.stockActual}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad a ${esPositivo ? 'añadir' : 'restar'}',
                  prefixIcon: Icon(esPositivo ? Icons.add : Icons.remove),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo del ajuste',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implementar ajuste de stock
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ajuste de stock - Próximamente')),
                );
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  // 🎨 FUNCIÓN AUXILIAR: Obtener color según stock
  Color _getColorStock(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    return Colors.green;
  }

  // ⚠️ FUNCIÓN AUXILIAR: Mostrar error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }
}
