import 'package:flutter/material.dart';
import '../models/albaran.dart';
import '../services/estados_service.dart';

// 🔘 WIDGET: Botones para cambiar estado de albarán
class BotonesEstadoWidget extends StatefulWidget {
  final Albaran albaran;
  final Function()? onEstadoCambiado; // Callback para recargar datos

  const BotonesEstadoWidget({
    super.key,
    required this.albaran,
    this.onEstadoCambiado,
  });

  @override
  State<BotonesEstadoWidget> createState() => _BotonesEstadoWidgetState();
}

class _BotonesEstadoWidgetState extends State<BotonesEstadoWidget> {
  bool _cambiandoEstado = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📊 TÍTULO Y ESTADO ACTUAL
          Row(
            children: [
              const Text(
                'Estado del Albarán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildChipEstado(),
            ],
          ),
          const SizedBox(height: 16),

          // 🔘 BOTONES SEGÚN ESTADO
          _buildBotonesPorEstado(),
        ],
      ),
    );
  }

  // 🏷️ MÉTODO: Chip del estado actual
  Widget _buildChipEstado() {
    final color = _getColorEstado();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconoEstado(),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            widget.albaran.estado.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 🔘 MÉTODO: Botones según el estado actual
  Widget _buildBotonesPorEstado() {
    final estado = widget.albaran.estado.toLowerCase();

    if (estado == 'pendiente') {
      return _buildBotonEnviar();
    } else if (estado == 'enviado') {
      return _buildBotonEntregar();
    } else if (estado == 'entregado') {
      return _buildEstadoFinal();
    } else {
      return _buildEstadoDesconocido();
    }
  }

  // 📤 MÉTODO: Botón para marcar como enviado
  Widget _buildBotonEnviar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📦 Material listo para envío',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _cambiandoEstado ? null : _marcarComoEnviado,
            icon: _cambiandoEstado
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.local_shipping),
            label:
                Text(_cambiandoEstado ? 'Enviando...' : 'Marcar como Enviado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 📦 MÉTODO: Botón para marcar como entregado
  Widget _buildBotonEntregar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚚 Material en tránsito - ¿Ya fue recepcionado?',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _cambiandoEstado ? null : _mostrarDialogoEntrega,
            icon: _cambiandoEstado
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle),
            label:
                Text(_cambiandoEstado ? 'Procesando...' : 'Confirmar Entrega'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ MÉTODO: Estado final - Entregado
  Widget _buildEstadoFinal() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          size: 48,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        const Text(
          '✅ Albarán Completado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const Text(
          'Material entregado y recepcionado',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  // ❓ MÉTODO: Estado desconocido
  Widget _buildEstadoDesconocido() {
    return const Column(
      children: [
        Icon(Icons.help_outline, size: 48, color: Colors.grey),
        Text('Estado no reconocido', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // 📤 FUNCIÓN: Marcar como enviado
  Future<void> _marcarComoEnviado() async {
    setState(() => _cambiandoEstado = true);

    try {
      final exito = await EstadosService.marcarComoEnviado(widget.albaran.id);

      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Albarán marcado como ENVIADO'),
              backgroundColor: Colors.blue,
            ),
          );
          widget.onEstadoCambiado?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error al cambiar estado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cambiandoEstado = false);
    }
  }

  // 📦 FUNCIÓN: Mostrar diálogo para entrega
  Future<void> _mostrarDialogoEntrega() async {
    final receptorController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Recepción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿El receptor ya tiene el material en su poder?'),
            const SizedBox(height: 16),
            TextFormField(
              controller: receptorController,
              decoration: const InputDecoration(
                labelText: 'Receptor (opcional)',
                hintText: 'Nombre de quien recibe',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _marcarComoEntregado(receptorController.text);
    }
  }

  // 📦 FUNCIÓN: Marcar como entregado
  Future<void> _marcarComoEntregado(String receptor) async {
    setState(() => _cambiandoEstado = true);

    try {
      final exito = await EstadosService.marcarComoEntregado(
        widget.albaran.id,
        receptorConfirma: receptor.isNotEmpty ? receptor : null,
      );

      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Albarán marcado como ENTREGADO'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onEstadoCambiado?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error al cambiar estado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cambiandoEstado = false);
    }
  }

  // 🎨 MÉTODO: Obtener color del estado
  Color _getColorEstado() {
    switch (widget.albaran.estado.toLowerCase()) {
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

  // 🎯 MÉTODO: Obtener icono del estado
  IconData _getIconoEstado() {
    switch (widget.albaran.estado.toLowerCase()) {
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
}
