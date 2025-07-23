import 'package:flutter/material.dart';
import '../services/usuarios_service.dart';
import 'albaranes_screen.dart';
import 'inventario_screen.dart';
import 'usuarios_screen.dart';
import 'login_screen.dart';
import 'cambiar_password_screen.dart'; // ← Nuevo import

// 🏠 PANTALLA: Dashboard principal del sistema
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 📊 DATOS: Estadísticas rápidas del sistema
  Map<String, int> _estadisticas = {
    'albaranes_pendientes': 0,
    'albaranes_enviados': 0,
    'productos_bajo_stock': 0,
    'usuarios_activos': 0,
  };
  bool _cargandoEstadisticas = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  // 📊 FUNCIÓN: Cargar estadísticas del sistema
  Future<void> _cargarEstadisticas() async {
    setState(() {
      _cargandoEstadisticas = true;
    });

    try {
      // TODO: Implementar llamadas a API para obtener estadísticas reales
      // Por ahora usamos datos simulados
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _estadisticas = {
          'albaranes_pendientes': 8,
          'albaranes_enviados': 23,
          'productos_bajo_stock': 5,
          'usuarios_activos': 12,
        };
        _cargandoEstadisticas = false;
      });
    } catch (e) {
      setState(() {
        _cargandoEstadisticas = false;
      });
    }
  }

  // 🚪 FUNCIÓN: Cerrar sesión
  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Hacer logout
                UsuariosService.logout();

                // Navegar al login y limpiar el stack de navegación
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMovil = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMovil
              ? 'ALMACÉN MOLINCAR'
              : 'Sistema de Gestión de Almacén MOLINCAR',
          style: TextStyle(fontSize: isMovil ? 16 : 20),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        actions: [
          // 🔄 BOTÓN: Recargar estadísticas
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEstadisticas,
            tooltip: 'Actualizar estadísticas',
          ),

          // 👤 BOTÓN: Perfil/Usuario actual
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Menú de usuario',
            onSelected: (value) {
              switch (value) {
                case 'perfil':
                  // TODO: Mostrar perfil de usuario
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil - Próximamente')),
                  );
                  break;
                case 'cambiar_password':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CambiarPasswordScreen(),
                    ),
                  );
                  break;
                case 'logout':
                  _cerrarSesion();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'perfil',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(UsuariosService.usuarioActual?['nombre'] ?? 'Usuario'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'cambiar_password',
                child: Row(
                  children: [
                    Icon(Icons.lock_reset, size: 20, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text('Cambiar Contraseña'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMovil ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏢 HEADER: Bienvenida y empresa
            _buildHeaderEmpresa(isMovil),
            SizedBox(height: isMovil ? 8 : 16),

            // 📊 SECCIÓN: Estadísticas rápidas
            _buildSeccionEstadisticas(isMovil),
            SizedBox(height: isMovil ? 12 : 20),

            // 🧩 SECCIÓN: Módulos principales
            _buildSeccionModulos(isMovil),
            SizedBox(height: isMovil ? 12 : 20),

            // 🚀 SECCIÓN: Acciones rápidas
            _buildSeccionAccionesRapidas(isMovil),

            SizedBox(height: isMovil ? 20 : 40),
          ],
        ),
      ),
    );
  }

  // 🏗️ MÉTODO: Construir header de empresa (responsive)
  Widget _buildHeaderEmpresa(bool isMovil) {
    final usuarioActual = UsuariosService.usuarioActual;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMovil ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMovil ? 'ALMACÉN MOLINCAR' : 'GESTIÓN ALMACÉN DE MOLINCAR',
            style: TextStyle(
              fontSize: isMovil ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMovil ? 4 : 8),
          Text(
            isMovil
                ? 'Control de inventario y envíos'
                : 'Sistema integral de control de inventario y envíos',
            style: TextStyle(
              fontSize: isMovil ? 12 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: isMovil ? 6 : 12),
          Row(
            children: [
              Text(
                'Hoy: ${_formatearFechaHoy()}',
                style: TextStyle(
                  fontSize: isMovil ? 10 : 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              if (usuarioActual != null) ...[
                Icon(
                  Icons.person,
                  size: isMovil ? 14 : 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  usuarioActual['nombre'] ?? '',
                  style: TextStyle(
                    fontSize: isMovil ? 10 : 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 📊 MÉTODO: Construir sección de estadísticas
  Widget _buildSeccionEstadisticas(bool isMovil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Sistema',
          style: TextStyle(
            fontSize: isMovil ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isMovil ? 8 : 16),
        _cargandoEstadisticas
            ? const Center(child: CircularProgressIndicator())
            : GridView.count(
                crossAxisCount: isMovil ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: isMovil ? 6 : 10,
                crossAxisSpacing: isMovil ? 6 : 10,
                childAspectRatio: isMovil ? 2.5 : 2.8,
                children: [
                  _buildTarjetaEstadistica(
                    'Albaranes\nPendientes',
                    _estadisticas['albaranes_pendientes']!,
                    Icons.schedule,
                    Colors.orange,
                    isMovil,
                  ),
                  _buildTarjetaEstadistica(
                    'Productos\nBajo Stock',
                    _estadisticas['productos_bajo_stock']!,
                    Icons.warning,
                    Colors.red,
                    isMovil,
                  ),
                  // _buildTarjetaEstadistica(
                  // 'Usuarios\nActivos',
                  // _estadisticas['usuarios_activos']!,
                  // Icons.people,
                  //  Colors.green,
                  //  isMovil,
                  //),
                  //_buildTarjetaEstadistica(
                  // 'Albaranes\nEnviados',
                  //_estadisticas['albaranes_enviados']!,
                  // Icons.local_shipping,
                  //  Colors.blue,
                  //  isMovil,
                  //),
                ],
              ),
      ],
    );
  }

  // 🏗️ MÉTODO: Construir tarjeta individual de estadística
  Widget _buildTarjetaEstadistica(
    String titulo,
    int valor,
    IconData icono,
    Color color,
    bool isMovil,
  ) {
    return Container(
      padding: EdgeInsets.all(isMovil ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icono,
            size: isMovil ? 20 : 24,
            color: color,
          ),
          SizedBox(width: isMovil ? 6 : 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor.toString(),
                  style: TextStyle(
                    fontSize: isMovil ? 14 : 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: isMovil ? 9 : 11,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 MÉTODO: Construir sección de módulos
  Widget _buildSeccionModulos(bool isMovil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos del Sistema',
          style: TextStyle(
            fontSize: isMovil ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isMovil ? 8 : 16),
        Column(
          children: [
            _buildTarjetaModulo(
              'Gestión de Albaranes',
              'Crear, editar y gestionar albaranes de envío',
              Icons.description,
              Colors.blue,
              () => _navegarAAlbaranes(),
              isMovil,
            ),
            SizedBox(height: isMovil ? 8 : 12),
            _buildTarjetaModulo(
              'Gestión de Inventario',
              'Productos, stock, ajustes y referencias',
              Icons.inventory,
              Colors.green,
              () => _navegarAInventario(),
              isMovil,
            ),
            SizedBox(height: isMovil ? 8 : 12),
            _buildTarjetaModulo(
              'Gestión de Usuarios',
              'Usuarios, permisos y credenciales',
              Icons.people,
              Colors.purple,
              () => _navegarAUsuarios(),
              isMovil,
            ),
          ],
        ),
      ],
    );
  }

  // 🏗️ MÉTODO: Construir tarjeta de módulo
  Widget _buildTarjetaModulo(
    String titulo,
    String descripcion,
    IconData icono,
    Color color,
    VoidCallback onTap,
    bool isMovil,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMovil ? 12 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMovil ? 8 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                size: isMovil ? 24 : 32,
                color: color,
              ),
            ),
            SizedBox(width: isMovil ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: isMovil ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: isMovil ? 2 : 4),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: isMovil ? 11 : 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.7),
              size: isMovil ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }

  // 🚀 MÉTODO: Construir acciones rápidas
  Widget _buildSeccionAccionesRapidas(bool isMovil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: isMovil ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isMovil ? 8 : 16),
        isMovil
            ? Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _crearAlbaranRapido,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Albarán'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _anadirProductoRapido,
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Añadir Producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _crearAlbaranRapido,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Albarán'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _anadirProductoRapido,
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Añadir Producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  // 📋 FUNCIÓN: Navegar a albaranes
  void _navegarAAlbaranes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlbaranesScreen()),
    );
  }

  // 📦 FUNCIÓN: Navegar a inventario
  void _navegarAInventario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventarioScreen()),
    );
  }

  // 👥 FUNCIÓN: Navegar a usuarios
  void _navegarAUsuarios() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UsuariosScreen()),
    );
  }

  // ➕ FUNCIÓN: Crear albarán rápido
  void _crearAlbaranRapido() {
    _navegarAAlbaranes();
  }

  // 📦 FUNCIÓN: Añadir producto rápido
  void _anadirProductoRapido() {
    _navegarAInventario();
  }

  // 📅 FUNCIÓN: Formatear fecha de hoy
  String _formatearFechaHoy() {
    final hoy = DateTime.now();
    final diasSemana = [
      '',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    final meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return '${diasSemana[hoy.weekday]}, ${hoy.day} de ${meses[hoy.month]} de ${hoy.year}';
  }
}
