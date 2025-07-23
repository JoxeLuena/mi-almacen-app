import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuarios_service.dart';

// 👥 PANTALLA: Gestión de usuarios con datos reales
class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen>
    with SingleTickerProviderStateMixin {
  // 📊 CONTROLADOR: Para las pestañas
  late TabController _tabController;

  // 👥 ESTADO: Lista de usuarios
  List<Usuario> usuarios = [];
  List<Usuario> usuariosFiltrados = [];
  bool isLoading = true;
  String? error;

  // 🔍 ESTADO: Búsqueda y filtros
  final TextEditingController _busquedaController = TextEditingController();
  String _filtroRol = 'todos';
  String _filtroEstado = 'todos';

  // 📊 ESTADO: Estadísticas
  Map<String, dynamic> _estadisticas = {};
  bool _cargandoEstadisticas = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarUsuarios();
    _cargarEstadisticas();
    _busquedaController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  // 📥 FUNCIÓN: Cargar usuarios del backend
  Future<void> _cargarUsuarios() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // 🌐 LLAMADA AL SERVICIO: Obtener usuarios reales de la base de datos
      final usuariosData = await UsuariosService.obtenerUsuarios();

      if (!mounted) return;

      final usuariosLista =
          usuariosData.map((data) => Usuario.fromJson(data)).toList();

      setState(() {
        usuarios = usuariosLista;
        _filtrarUsuarios();
        isLoading = false;
      });

      print('✅ Usuarios cargados: ${usuarios.length}'); // Debug
    } catch (e) {
      print('❌ Error cargando usuarios: $e'); // Debug

      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = 'Error cargando usuarios: $e';
        usuarios = [];
        usuariosFiltrados = [];
      });
    }
  }

  // 📊 FUNCIÓN: Cargar estadísticas
  Future<void> _cargarEstadisticas() async {
    setState(() {
      _cargandoEstadisticas = true;
    });

    try {
      final stats = await UsuariosService.obtenerEstadisticas();
      setState(() {
        _estadisticas = stats;
        _cargandoEstadisticas = false;
      });
    } catch (e) {
      setState(() {
        _cargandoEstadisticas = false;
      });
    }
  }

  // 🔍 FUNCIÓN: Filtrar usuarios según criterios
  void _filtrarUsuarios() {
    final query = _busquedaController.text.toLowerCase();

    setState(() {
      usuariosFiltrados = usuarios.where((usuario) {
        // 🔍 Filtro por texto (nombre o email)
        final coincideTexto = query.isEmpty ||
            usuario.nombre.toLowerCase().contains(query) ||
            usuario.email.toLowerCase().contains(query);

        // 👤 Filtro por rol
        final coincideRol = _filtroRol == 'todos' || usuario.rol == _filtroRol;

        // ✅ Filtro por estado
        final coincideEstado = _filtroEstado == 'todos' ||
            (_filtroEstado == 'activos' && usuario.activo) ||
            (_filtroEstado == 'inactivos' && !usuario.activo);

        return coincideTexto && coincideRol && coincideEstado;
      }).toList();

      // 📊 Ordenar por nombre
      usuariosFiltrados.sort((a, b) => a.nombre.compareTo(b.nombre));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Usuarios'),
            Tab(icon: Icon(Icons.security), text: 'Permisos'),
            Tab(icon: Icon(Icons.history), text: 'Actividad'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _cargarUsuarios();
              _cargarEstadisticas();
            },
            tooltip: 'Recargar usuarios',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabUsuarios(), // 👥 Pestaña usuarios
          _buildTabPermisos(), // 🔐 Pestaña permisos
          _buildTabActividad(), // 📊 Pestaña actividad
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _mostrarDialogoCrearUsuario,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.person_add, color: Colors.white),
              tooltip: 'Crear Nuevo Usuario',
            )
          : null,
    );
  }

  // 👥 MÉTODO: Construir pestaña de usuarios
  Widget _buildTabUsuarios() {
    return Column(
      children: [
        // 🔍 SECCIÓN: Barra de búsqueda y filtros
        _buildBarraBusqueda(),
        // 📊 SECCIÓN: Estadísticas rápidas
        _buildEstadisticasRapidas(),
        // 📋 SECCIÓN: Lista de usuarios
        Expanded(child: _buildListaUsuarios()),
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
              labelText: 'Buscar usuarios',
              hintText: 'Nombre o email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          // 🔽 FILTROS: Rol y Estado
          Row(
            children: [
              // 👤 Filtro por rol
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rol:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChipFiltro('todos', 'Todos', _filtroRol,
                              (valor) {
                            setState(() {
                              _filtroRol = valor;
                              _filtrarUsuarios();
                            });
                          }),
                          _buildChipFiltro('administrador', 'Admin', _filtroRol,
                              (valor) {
                            setState(() {
                              _filtroRol = valor;
                              _filtrarUsuarios();
                            });
                          }),
                          _buildChipFiltro(
                              'supervisor', 'Supervisor', _filtroRol, (valor) {
                            setState(() {
                              _filtroRol = valor;
                              _filtrarUsuarios();
                            });
                          }),
                          _buildChipFiltro('usuario', 'Usuario', _filtroRol,
                              (valor) {
                            setState(() {
                              _filtroRol = valor;
                              _filtrarUsuarios();
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // ✅ Filtro por estado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChipFiltro('todos', 'Todos', _filtroEstado,
                              (valor) {
                            setState(() {
                              _filtroEstado = valor;
                              _filtrarUsuarios();
                            });
                          }),
                          _buildChipFiltro('activos', 'Activos', _filtroEstado,
                              (valor) {
                            setState(() {
                              _filtroEstado = valor;
                              _filtrarUsuarios();
                            });
                          }),
                          _buildChipFiltro(
                              'inactivos', 'Inactivos', _filtroEstado, (valor) {
                            setState(() {
                              _filtroEstado = valor;
                              _filtrarUsuarios();
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
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
    if (_cargandoEstadisticas) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildTarjetaEstadistica(
              'Total\nUsuarios',
              _estadisticas['total_usuarios']?.toString() ?? '0',
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTarjetaEstadistica(
              'Activos',
              _estadisticas['usuarios_activos']?.toString() ?? '0',
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTarjetaEstadistica(
              'Admins',
              _estadisticas['administradores']?.toString() ?? '0',
              Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTarjetaEstadistica(
              '24h',
              _estadisticas['accesos_24h']?.toString() ?? '0',
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // 🏗️ MÉTODO: Construir tarjeta de estadística
  Widget _buildTarjetaEstadistica(String titulo, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📋 MÉTODO: Construir lista de usuarios
  Widget _buildListaUsuarios() {
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
              onPressed: _cargarUsuarios,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (usuariosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No se encontraron usuarios',
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
      itemCount: usuariosFiltrados.length,
      itemBuilder: (context, index) {
        final usuario = usuariosFiltrados[index];
        return _buildUsuarioCard(usuario);
      },
    );
  }

  // 🃏 MÉTODO: Construir tarjeta de usuario
  Widget _buildUsuarioCard(Usuario usuario) {
    final colorRol = _getColorRol(usuario.rol);
    final tiempoUltimoAcceso = usuario.ultimoAcceso != null
        ? UsuariosService.formatearTiempoRelativo(
            usuario.ultimoAcceso!.toIso8601String())
        : 'Nunca';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        // 👤 AVATAR: Con inicial del nombre
        leading: CircleAvatar(
          backgroundColor: usuario.activo ? colorRol : Colors.grey,
          child: Text(
            usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        // 📝 TÍTULO: Nombre del usuario
        title: Row(
          children: [
            Expanded(
              child: Text(
                usuario.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: usuario.activo ? Colors.black : Colors.grey,
                ),
              ),
            ),
            // 🏷️ CHIP: Rol del usuario
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorRol.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorRol),
              ),
              child: Text(
                UsuariosService.obtenerNombreRol(usuario.rol),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorRol,
                ),
              ),
            ),
          ],
        ),
        // 📝 SUBTÍTULO: Email y estado
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              usuario.email,
              style: TextStyle(
                color: usuario.activo ? Colors.black54 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  usuario.activo ? Icons.check_circle : Icons.cancel,
                  size: 12,
                  color: usuario.activo ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  usuario.activo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: usuario.activo ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  tiempoUltimoAcceso,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        // 🔘 ACCIONES: Botones
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editarUsuario(usuario),
              tooltip: 'Editar usuario',
            ),
            IconButton(
              icon: Icon(
                usuario.activo ? Icons.block : Icons.check_circle,
                color: usuario.activo ? Colors.red : Colors.green,
              ),
              onPressed: () => _cambiarEstadoUsuario(usuario),
              tooltip:
                  usuario.activo ? 'Desactivar usuario' : 'Activar usuario',
            ),
          ],
        ),
      ),
    );
  }

  // ➕ FUNCIÓN: Mostrar diálogo para crear usuario
  void _mostrarDialogoCrearUsuario() {
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String rolSeleccionado = 'usuario';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Nuevo Usuario'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                      ),
                      items: ['usuario', 'supervisor', 'administrador']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(UsuariosService.obtenerNombreRol(value)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          rolSeleccionado = newValue ?? 'usuario';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => _procesarCrearUsuario(
                    nombreController.text,
                    emailController.text,
                    passwordController.text,
                    rolSeleccionado,
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

  // ➕ FUNCIÓN: Procesar creación de usuario
  Future<void> _procesarCrearUsuario(
    String nombre,
    String email,
    String password,
    String rol,
  ) async {
    // Validaciones
    final errorNombre = UsuariosService.validarNombre(nombre);
    if (errorNombre != null) {
      _mostrarError(errorNombre);
      return;
    }

    if (!UsuariosService.validarEmail(email)) {
      _mostrarError('Email inválido');
      return;
    }

    final errorPassword = UsuariosService.validarPassword(password);
    if (errorPassword != null) {
      _mostrarError(errorPassword);
      return;
    }

    try {
      Navigator.of(context).pop();

      final resultado = await UsuariosService.crearUsuario(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
      );

      if (resultado['exito']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${resultado['mensaje']}'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarUsuarios(); // Recargar lista
        _cargarEstadisticas(); // Recargar estadísticas
      } else {
        _mostrarError(resultado['error']);
      }
    } catch (e) {
      _mostrarError('Error creando usuario: $e');
    }
  }

  // ✏️ FUNCIÓN: Editar usuario
  void _editarUsuario(Usuario usuario) {
    // TODO: Implementar edición de usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edición de ${usuario.nombre} - Próximamente')),
    );
  }

  // 🔄 FUNCIÓN: Cambiar estado de usuario
  void _cambiarEstadoUsuario(Usuario usuario) {
    final accion = usuario.activo ? 'desactivar' : 'activar';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('${accion[0].toUpperCase()}${accion.substring(1)} Usuario'),
          content:
              Text('¿Estás seguro de que quieres $accion a ${usuario.nombre}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _procesarCambioEstado(usuario, !usuario.activo),
              child: Text(accion[0].toUpperCase() + accion.substring(1)),
            ),
          ],
        );
      },
    );
  }

  // 🔄 FUNCIÓN: Procesar cambio de estado
  Future<void> _procesarCambioEstado(Usuario usuario, bool nuevoEstado) async {
    try {
      Navigator.of(context).pop();

      final resultado =
          await UsuariosService.cambiarEstadoUsuario(usuario.id, nuevoEstado);

      if (resultado['exito']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${resultado['mensaje']}'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarUsuarios(); // Recargar lista
        _cargarEstadisticas(); // Recargar estadísticas
      } else {
        _mostrarError(resultado['error']);
      }
    } catch (e) {
      _mostrarError('Error cambiando estado: $e');
    }
  }

  // 🔐 MÉTODO: Construir pestaña de permisos
  Widget _buildTabPermisos() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Módulo de Permisos', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Funcionalidad en desarrollo',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 📊 MÉTODO: Construir pestaña de actividad
  Widget _buildTabActividad() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Registro de Actividad', style: TextStyle(fontSize: 20)),
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
        selectedColor: Colors.purple.withOpacity(0.3),
        labelStyle: TextStyle(
          color: seleccionado ? Colors.purple.shade700 : Colors.black54,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // 🎨 FUNCIÓN: Obtener color por rol
  Color _getColorRol(String rol) {
    switch (rol.toLowerCase()) {
      case 'administrador':
        return Colors.red;
      case 'supervisor':
        return Colors.orange;
      case 'usuario':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ⚠️ FUNCIÓN: Mostrar error
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
}
