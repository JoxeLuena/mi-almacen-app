import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/producto_disponible.dart'; // 📦 Modelo producto disponible
import '../models/producto_seleccionado.dart'; // 📦 Modelo producto seleccionado

// 📦 WIDGET: Gestión de productos del albarán
// Similar a un UserControl especializado en productos
class ProductosWidget extends StatelessWidget {
  final List<ProductoDisponible>
  productosDisponibles; // 📋 Lista productos del almacén
  final List<ProductoSeleccionado>
  productosSeleccionados; // 📋 Lista productos elegidos
  final bool isLoading; // ⏳ Indicador de carga
  final VoidCallback onAnadirProducto; // 🔗 Función para añadir producto
  final Function(int) onEditarProducto; // 🔗 Función para editar producto
  final Function(int) onEliminarProducto; // 🔗 Función para eliminar producto

  // 🏗️ CONSTRUCTOR: Recibe datos y funciones callback
  const ProductosWidget({
    super.key,
    required this.productosDisponibles, // 📋 Lista productos almacén obligatoria
    required this.productosSeleccionados, // 📋 Lista productos elegidos obligatoria
    required this.isLoading, // ⏳ Estado de carga obligatorio
    required this.onAnadirProducto, // 🔗 Callback añadir obligatorio
    required this.onEditarProducto, // 🔗 Callback editar obligatorio
    required this.onEliminarProducto, // 🔗 Callback eliminar obligatorio
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Construir la interfaz
    return Card(
      // 🃏 Tarjeta con sombra
      elevation: 4, // 🌫️ Nivel de sombra
      child: Padding(
        // 📏 Margen interno
        padding: const EdgeInsets.all(16), // 📏 16 píxeles en todos lados
        child: Column(
          // 📋 Columna vertical
          crossAxisAlignment:
              CrossAxisAlignment.start, // ⬅️ Alinear contenido a la izquierda
          children: [
            // 🏷️ ENCABEZADO: Título con botón añadir
            Row(
              // ➡️ Fila horizontal
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // 🎯 Espacio entre elementos
              children: [
                const Text(
                  'Productos del Albarán', // 📝 Título de la sección
                  style: TextStyle(
                    fontSize: 20, // 📏 Tamaño grande
                    fontWeight: FontWeight.bold, // 🔤 Negrita
                    color: Colors.blue, // 🔵 Color azul
                  ),
                ),
                ElevatedButton.icon(
                  // ➕ Botón para añadir producto
                  onPressed:
                      isLoading // 👆 Solo habilitado si no está cargando
                      ? null // ❌ Deshabilitado durante carga
                      : onAnadirProducto, // ✅ Ejecutar callback añadir
                  icon: const Icon(Icons.add), // ➕ Icono más
                  label: const Text('Añadir'), // 🏷️ Texto del botón
                  style: ElevatedButton.styleFrom(
                    // 🎨 Estilo del botón
                    backgroundColor: Colors.green, // 🟢 Fondo verde
                    foregroundColor: Colors.white, // ⚪ Texto blanco
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // 📏 Espacio después del encabezado
            // 📦 CONTENIDO: Lista de productos o mensaje vacío
            if (productosSeleccionados
                .isEmpty) // 🔍 Si no hay productos seleccionados
              _buildMensajeVacio() // 🏗️ Mostrar mensaje de lista vacía
            else // ✅ Si hay productos seleccionados
              _buildListaProductos(), // 🏗️ Mostrar lista de productos
            // 📊 RESUMEN: Total de productos (solo si hay productos)
            if (productosSeleccionados.isNotEmpty) // 🔍 Si hay productos
              _buildResumen(), // 🏗️ Mostrar resumen
          ],
        ),
      ),
    );
  }

  // 🏗️ MÉTODO: Construir mensaje cuando no hay productos
  Widget _buildMensajeVacio() {
    return Container(
      // 📦 Contenedor para el mensaje
      padding: const EdgeInsets.all(32), // 📏 Padding grande para centrar
      decoration: BoxDecoration(
        // 🎨 Decoración del contenedor
        color: Colors.grey.shade100, // ⚫ Fondo gris muy claro
        borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
        border: Border.all(
          // 🔲 Borde del contenedor
          color: Colors.grey.shade300, // ⚫ Color gris del borde
          width: 1, // 📏 Grosor del borde
        ),
      ),
      child: const Column(
        // 📋 Columna con contenido centrado
        children: [
          Icon(
            // 📦 Icono de caja vacía
            Icons.inventory_2_outlined,
            size: 48, // 📏 Tamaño grande
            color: Colors.grey, // ⚫ Color gris
          ),
          SizedBox(height: 12), // 📏 Espacio vertical
          Text(
            'No hay productos añadidos', // 📝 Mensaje principal
            style: TextStyle(
              color: Colors.grey, // ⚫ Color gris
              fontSize: 16, // 📏 Tamaño medio
              fontWeight: FontWeight.w500, // 🔤 Peso medio
            ),
          ),
          SizedBox(height: 8), // 📏 Espacio pequeño
          Text(
            'Usa el botón "Añadir" para incluir productos en el albarán', // 💡 Instrucción
            textAlign: TextAlign.center, // 🎯 Centrar texto
            style: TextStyle(
              color: Colors.grey, // ⚫ Color gris
              fontSize: 12, // 📏 Tamaño pequeño
            ),
          ),
        ],
      ),
    );
  }

  // 🏗️ MÉTODO: Construir lista de productos seleccionados
  Widget _buildListaProductos() {
    return Column(
      // 📋 Columna con todos los productos
      children: productosSeleccionados.asMap().entries.map((entry) {
        // 🗂️ Mapear cada producto con su índice
        final index = entry.key; // 🔢 Índice del producto en la lista
        final productoSel = entry.value; // 📦 Producto seleccionado actual

        return Container(
          // 📦 Contenedor para cada producto
          margin: const EdgeInsets.only(bottom: 8), // 📏 Margen inferior
          padding: const EdgeInsets.all(12), // 📏 Padding interno
          decoration: BoxDecoration(
            // 🎨 Decoración del contenedor
            color: Colors.blue.shade50, // 🔵 Fondo azul muy claro
            borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
            border: Border.all(
              // 🔲 Borde del contenedor
              color: Colors.blue.shade200, // 🔵 Color azul claro del borde
              width: 1, // 📏 Grosor del borde
            ),
          ),
          child: Row(
            // ➡️ Fila horizontal con contenido
            children: [
              // 🔵 INDICADOR: Círculo con cantidad
              CircleAvatar(
                backgroundColor: Colors.blue, // 🔵 Fondo azul
                radius: 20, // 📏 Radio del círculo
                child: Text(
                  '${productoSel.cantidad}', // 🔢 Mostrar cantidad
                  style: const TextStyle(
                    color: Colors.white, // ⚪ Texto blanco
                    fontWeight: FontWeight.bold, // 🔤 Negrita
                    fontSize: 14, // 📏 Tamaño medio
                  ),
                ),
              ),
              const SizedBox(width: 12), // 📏 Espacio horizontal
              // 📝 INFORMACIÓN: Datos del producto
              Expanded(
                // 📏 Expandir para ocupar espacio disponible
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
                  children: [
                    Text(
                      productoSel.nombreCompleto, // 📝 Referencia + descripción
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, // 🔤 Negrita
                        fontSize: 14, // 📏 Tamaño medio
                      ),
                    ),
                    if (productoSel
                        .observaciones
                        .isNotEmpty) // 📝 Solo mostrar si hay observaciones
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                        ), // 📏 Pequeño margen superior
                        child: Text(
                          'Obs: ${productoSel.observaciones}', // 📝 Mostrar observaciones
                          style: TextStyle(
                            color: Colors.grey.shade600, // ⚫ Color gris
                            fontSize: 12, // 📏 Tamaño pequeño
                          ),
                        ),
                      ),
                    // 📊 INFORMACIÓN: Stock disponible
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 2,
                      ), // 📏 Pequeño margen superior
                      child: Text(
                        'Stock disponible: ${productoSel.producto.stockActual}', // 📊 Mostrar stock
                        style: TextStyle(
                          color: Colors.green.shade600, // 🟢 Color verde
                          fontSize: 11, // 📏 Tamaño muy pequeño
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔘 ACCIONES: Botones editar y eliminar
              Row(
                // ➡️ Fila con botones
                mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo necesario
                children: [
                  IconButton(
                    // ✏️ Botón editar
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                    ), // ✏️ Icono naranja
                    onPressed: () =>
                        onEditarProducto(index), // 👆 Ejecutar callback editar
                    tooltip:
                        'Editar cantidad y observaciones', // 💡 Tooltip de ayuda
                  ),
                  IconButton(
                    // 🗑️ Botón eliminar
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ), // 🗑️ Icono rojo
                    onPressed: () => onEliminarProducto(
                      index,
                    ), // 👆 Ejecutar callback eliminar
                    tooltip:
                        'Eliminar producto del albarán', // 💡 Tooltip de ayuda
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🏗️ MÉTODO: Construir resumen de productos
  Widget _buildResumen() {
    // 📊 CÁLCULOS: Estadísticas de los productos
    final totalTipos =
        productosSeleccionados.length; // 🔢 Cantidad de tipos diferentes
    final totalUnidades =
        productosSeleccionados // 🔢 Suma total de unidades
            .map((p) => p.cantidad)
            .reduce((a, b) => a + b);

    return Container(
      // 📦 Contenedor del resumen
      margin: const EdgeInsets.only(top: 16), // 📏 Margen superior
      padding: const EdgeInsets.all(12), // 📏 Padding interno
      decoration: BoxDecoration(
        // 🎨 Decoración del contenedor
        color: Colors.green.shade50, // 🟢 Fondo verde claro
        borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
        border: Border.all(
          // 🔲 Borde del contenedor
          color: Colors.green.shade200, // 🟢 Color verde del borde
          width: 1, // 📏 Grosor del borde
        ),
      ),
      child: Row(
        // ➡️ Fila horizontal
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // 🎯 Espacio entre elementos
        children: [
          Column(
            // 📋 Columna con estadísticas
            crossAxisAlignment:
                CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
            children: [
              Text(
                'Resumen del Albarán:', // 📝 Título del resumen
                style: TextStyle(
                  fontWeight: FontWeight.bold, // 🔤 Negrita
                  color: Colors.green.shade700, // 🟢 Verde oscuro
                  fontSize: 14, // 📏 Tamaño medio
                ),
              ),
              const SizedBox(height: 4), // 📏 Espacio pequeño
              Text(
                '$totalTipos tipos de productos • $totalUnidades unidades totales', // 📊 Estadísticas
                style: TextStyle(
                  color: Colors.green.shade600, // 🟢 Verde medio
                  fontSize: 12, // 📏 Tamaño pequeño
                ),
              ),
            ],
          ),
          Icon(
            // ✅ Icono de verificación
            Icons.check_circle_outline,
            color: Colors.green.shade600, // 🟢 Color verde
            size: 24, // 📏 Tamaño medio
          ),
        ],
      ),
    );
  }
}
