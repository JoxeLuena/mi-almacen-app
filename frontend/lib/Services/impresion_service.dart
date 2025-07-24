import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// 🖨️ SERVICIO: Impresión de albaranes (versión completa con observaciones y firma)
class ImpresionService {
  // 🏢 CONFIGURACIÓN: Datos de la empresa
  static const String nombreEmpresa = 'MOLINCAR TECNICA';
  static const String direccionEmpresa =
      'Pol. Industrial Valdemies 2, Parcela 2, '
      '42100 AGREDA, España';
  static const String telefonoEmpresa = 'Tel: 34 976 192 812';
  static const String emailEmpresa = 'logistica@gmail.com';
  static const String webEmpresa = 'www.inpre.es';

  // 🖼️ FUNCIÓN: Cargar logo de la empresa
  static Future<Uint8List?> _cargarLogoEmpresa() async {
    try {
      // 📁 CARGAR: Logo desde assets
      final byteData = await rootBundle.load('assets/images/logo_empresa.png');
      return byteData.buffer.asUint8List();
    } catch (e) {
      // ⚠️ ERROR: Si no se encuentra el logo, continuar sin él
      print('⚠️ No se pudo cargar el logo: $e');
      return null;
    }
  }

  // 🖨️ FUNCIÓN PRINCIPAL: Imprimir albarán
  static Future<void> imprimirAlbaran(int albaranId) async {
    try {
      // 📊 OBTENER datos del backend
      final response = await http.get(
        // Uri.parse('http://192.168.1.207:3000/albaranes/$albaranId/imprimir'), //desarrollo
        Uri.parse(
            'https://850766ec91e4.ngrok-free.app/albaranes/$albaranId/imprimir'), // NGROK
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error obteniendo datos del servidor');
      }

      final resultado = json.decode(response.body);

      if (resultado['exito'] != true) {
        throw Exception(resultado['error'] ?? 'Error obteniendo datos');
      }

      // 📄 GENERAR PDF básico
      final pdf = await _generarPDFBasico(
        albaran: resultado['albaran'],
        productos: resultado['productos'] ?? [],
        resumen:
            resultado['resumen'] ?? {'total_tipos': 0, 'total_unidades': 0},
      );

      // 🖨️ MOSTRAR vista previa
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: 'Albaran_${resultado['albaran']['numero_albaran']}.pdf',
      );
    } catch (e) {
      throw Exception('Error imprimiendo albarán: $e');
    }
  }

  // 📄 FUNCIÓN: Generar PDF básico
  static Future<Uint8List> _generarPDFBasico({
    required Map<String, dynamic> albaran,
    required List<dynamic> productos,
    required Map<String, dynamic> resumen,
  }) async {
    final pdf = pw.Document();

    // 🖼️ CARGAR: Logo de la empresa
    final logoBytes = await _cargarLogoEmpresa();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 🏢 ENCABEZADO (con logo)
              _buildEncabezadoConLogo(albaran, logoBytes),
              pw.SizedBox(height: 20),

              // 📋 INFORMACIÓN DEL ALBARÁN
              _buildInformacion(albaran),
              pw.SizedBox(height: 20),

              // 📦 TABLA DE PRODUCTOS
              if (productos.isNotEmpty) _buildTablaProductos(productos),

              // 📝 OBSERVACIONES DEL ALBARÁN (nueva sección)
              if (albaran['observaciones'] != null &&
                  albaran['observaciones'].toString().trim().isNotEmpty) ...[
                pw.SizedBox(height: 16),
                _buildObservaciones(albaran['observaciones']),
              ],

              // 📊 ESPACIADOR FLEXIBLE
              pw.Spacer(),

              // ✍️ RECUADRO DE FIRMA (nueva sección)
              _buildRecuadroFirma(),
              pw.SizedBox(height: 16),

              // 📊 PIE DE PÁGINA
              _buildPiePagina(),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  // 🏢 FUNCIÓN: Construir encabezado CON LOGO
  static pw.Widget _buildEncabezadoConLogo(
      Map<String, dynamic> albaran, Uint8List? logoBytes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // 🏢 DATOS EMPRESA CON LOGO
          pw.Expanded(
            flex: 2,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 🖼️ LOGO (si está disponible)
                if (logoBytes != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(right: 12),
                    child: pw.Image(
                      pw.MemoryImage(logoBytes),
                      width: 60,
                      height: 60,
                      fit: pw.BoxFit.contain,
                    ),
                  ),

                // 📝 INFORMACIÓN DE LA EMPRESA
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        nombreEmpresa,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        direccionEmpresa,
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        telefonoEmpresa,
                        style:
                            pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        emailEmpresa,
                        style:
                            pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📋 DATOS ALBARÁN
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'ALBARÁN',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  albaran['numero_albaran'] ?? '',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _formatearFecha(albaran['fecha_creacion']),
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📋 FUNCIÓN: Construir información
  static pw.Widget _buildInformacion(Map<String, dynamic> albaran) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL ENVÍO',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Cliente: ${albaran['cliente'] ?? 'No especificado'}'),
          pw.Text(
              'Estado: ${albaran['estado']?.toString().toUpperCase() ?? 'PENDIENTE'}'),
          if (albaran['direccion_entrega'] != null &&
              albaran['direccion_entrega'].toString().trim().isNotEmpty)
            pw.Text('Dirección: ${albaran['direccion_entrega']}'),
        ],
      ),
    );
  }

  // 📦 FUNCIÓN: Construir tabla de productos
  static pw.Widget _buildTablaProductos(List<dynamic> productos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRODUCTOS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            // Encabezado
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildCelda('REFERENCIA', esEncabezado: true),
                _buildCelda('DESCRIPCIÓN', esEncabezado: true),
                _buildCelda('CANTIDAD', esEncabezado: true),
              ],
            ),
            // Productos
            ...productos
                .map((producto) => pw.TableRow(
                      children: [
                        _buildCelda(producto['referencia'] ?? ''),
                        _buildCelda(producto['descripcion'] ?? ''),
                        _buildCelda(producto['cantidad']?.toString() ?? '0'),
                      ],
                    ))
                .toList(),
          ],
        ),

        // 📊 RESUMEN DE PRODUCTOS
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total productos: ${productos.length} tipos • ',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Total unidades: ${productos.fold<int>(0, (sum, p) {
                  // Convertir cantidad a int, manejando String, num, o null
                  final cantidad = p['cantidad'];
                  if (cantidad == null) return sum;
                  if (cantidad is int) return sum + cantidad;
                  if (cantidad is double) return sum + cantidad.toInt();
                  if (cantidad is String)
                    return sum + (int.tryParse(cantidad) ?? 0);
                  return sum;
                })}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 📝 FUNCIÓN: Construir sección de observaciones (NUEVA)
  static pw.Widget _buildObservaciones(String observaciones) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.amber600, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.amber50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber600,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  '📝 OBSERVACIONES',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            observaciones.trim(),
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  // ✍️ FUNCIÓN: Construir recuadro de firma (NUEVA)
  static pw.Widget _buildRecuadroFirma() {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          // 📝 SECCIÓN: Fecha de recepción
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FECHA DE RECEPCIÓN',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    height: 1,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey400),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Día / Mes / Año',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✍️ SECCIÓN: Firma del receptor
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FIRMA o SELLO DEL RECEPTOR',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 40), // Espacio para la firma
                  pw.Container(
                    height: 1,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey400),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Firma, aclaración o sello',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📄 FUNCIÓN: Construir pie de página
  static pw.Widget _buildPiePagina() {
    final ahora = DateTime.now();
    final fechaHora =
        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year} ${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado por $nombreEmpresa • $emailEmpresa',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Impreso: $fechaHora',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  // 🏗️ FUNCIÓN AUXILIAR: Construir celda de tabla
  static pw.Widget _buildCelda(String texto, {bool esEncabezado = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: esEncabezado ? 10 : 9,
          fontWeight: esEncabezado ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // 📅 FUNCIÓN AUXILIAR: Formatear fecha
  static String _formatearFecha(dynamic fecha) {
    if (fecha == null) return '';

    try {
      final DateTime fechaObj =
          fecha is String ? DateTime.parse(fecha) : fecha as DateTime;

      return '${fechaObj.day.toString().padLeft(2, '0')}/${fechaObj.month.toString().padLeft(2, '0')}/${fechaObj.year}';
    } catch (e) {
      return fecha.toString();
    }
  }

  // 💾 FUNCIÓN: Guardar PDF (método que faltaba)
  static Future<void> guardarPDF(int albaranId, String nombreArchivo) async {
    try {
      // 📊 OBTENER datos del backend
      final response = await http.get(
        // Uri.parse('http://192.168.1.207:3000/albaranes/$albaranId/imprimir'), // desarrollo
        Uri.parse(
            'https://850766ec91e4.ngrok-free.app/albaranes/$albaranId/imprimir'), // NGROK
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error obteniendo datos del servidor');
      }

      final resultado = json.decode(response.body);

      if (resultado['exito'] != true) {
        throw Exception(resultado['error'] ?? 'Error obteniendo datos');
      }

      // 📄 GENERAR PDF
      final pdf = await _generarPDFBasico(
        albaran: resultado['albaran'],
        productos: resultado['productos'] ?? [],
        resumen:
            resultado['resumen'] ?? {'total_tipos': 0, 'total_unidades': 0},
      );

      // 💾 GUARDAR PDF
      await Printing.sharePdf(
        bytes: pdf,
        filename: '$nombreArchivo.pdf',
      );
    } catch (e) {
      throw Exception('Error guardando PDF: $e');
    }
  }
}
