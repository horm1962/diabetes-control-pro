import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/glucose_log.dart';
import '../models/nutrition_log.dart';
import '../models/activity_log.dart';

class ExportService {
  static Future<Uint8List> generateMasterHealthReport({
    required String userName,
    required List<GlucoseLog> glucoseLogs,
    required List<dynamic> vitalsLogs,
    required List<NutritionLog> nutritionLogs,
    required List<ActivityLog> activityLogs,
    required List<dynamic> labResults,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(userName),
            pw.SizedBox(height: 20),
            
            // Sección de Glucosa
            _buildSectionTitle('Historial de Glucosa'),
            _buildGlucoseTable(glucoseLogs),
            pw.SizedBox(height: 20),

            // Sección de Signos Vitales
            _buildSectionTitle('Signos Vitales'),
            _buildVitalsTable(vitalsLogs),
            pw.SizedBox(height: 20),

            // Sección de Nutrición
            _buildSectionTitle('Resumen de Nutrición'),
            _buildNutritionTable(nutritionLogs),
            pw.SizedBox(height: 20),

            // Sección de Actividad
            _buildSectionTitle('Actividad Física'),
            _buildActivityTable(activityLogs),
            pw.SizedBox(height: 20),

            // Sección de Laboratorios
            _buildSectionTitle('Resultados de Laboratorio'),
            _buildLabResultsTable(labResults),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String userName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Informe Maestro de Salud', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.SizedBox(height: 4),
        pw.Text('Paciente: $userName', style: pw.TextStyle(fontSize: 16)),
        pw.Text('Fecha de generación: ${_formatDate(DateTime.now())}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
    );
  }

  static String _formatDate(dynamic date, {int length = 16}) {
    if (date == null) return 'N/A';
    final dateStr = date.toString();
    if (dateStr.length < length) return dateStr;
    return dateStr.substring(0, length);
  }

  static pw.Widget _buildGlucoseTable(List<GlucoseLog> logs) {
    if (logs.isEmpty) return pw.Text('No hay registros de glucosa disponibles.');
    return pw.Table.fromTextArray(
      headers: ['Fecha', 'Valor (mg/dL)', 'Contexto', 'Notas'],
      data: logs.map((log) => [
        _formatDate(log.timestamp),
        log.value.toStringAsFixed(1),
        log.contextLabel,
        log.notes ?? '',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellHeight: 25,
      cellAlignment: pw.Alignment.center,
    );
  }

  static pw.Widget _buildVitalsTable(List<dynamic> logs) {
    if (logs.isEmpty) return pw.Text('No hay registros de signos vitales disponibles.');
    return pw.Table.fromTextArray(
      headers: ['Fecha', 'Presión (S/D)', 'Pulso', 'Notas'],
      data: logs.map((log) => [
        _formatDate(log['createdAt']),
        "${log['systolic'] ?? '-'}/${log['diastolic'] ?? '-'} mmHg",
        log['heartRate']?.toString() ?? '-',
        log['notes'] ?? '',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
      cellHeight: 25,
      cellAlignment: pw.Alignment.center,
    );
  }

  static pw.Widget _buildNutritionTable(List<NutritionLog> logs) {
    if (logs.isEmpty) return pw.Text('No hay registros de nutrición disponibles.');
    return pw.Table.fromTextArray(
      headers: ['Fecha', 'Comida', 'Calorías', 'Carbs/Prot/Grasas'],
      data: logs.map((log) => [
        _formatDate(log.timestamp),
        log.mealLabel,
        log.calories?.toString() ?? '0',
        "${log.carbsG ?? 0}/${log.proteinG ?? 0}/${log.fatG ?? 0}g",
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.orange700),
      cellHeight: 25,
      cellAlignment: pw.Alignment.center,
    );
  }

  static pw.Widget _buildActivityTable(List<ActivityLog> logs) {
    if (logs.isEmpty) return pw.Text('No hay actividades registradas.');
    return pw.Table.fromTextArray(
      headers: ['Fecha', 'Actividad', 'Duración', 'Intensidad', 'Calorías'],
      data: logs.map((log) => [
        _formatDate(log.timestamp),
        log.activityType,
        "${log.durationMinutes} min",
        log.intensityLabel,
        log.caloriesBurned?.toString() ?? '-',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.purple700),
      cellHeight: 25,
      cellAlignment: pw.Alignment.center,
    );
  }

  static pw.Widget _buildLabResultsTable(List<dynamic> logs) {
    if (logs.isEmpty) return pw.Text('No hay resultados de laboratorio.');
    return pw.Table.fromTextArray(
      headers: ['Fecha', 'HbA1c', 'Colesterol', 'Creatinina', 'Urea'],
      data: logs.map((log) => [
        _formatDate(log['createdAt'], length: 10),
        log['hba1c']?.toString() ?? '-',
        log['cholesterolResult']?.toString() ?? '-',
        log['creatinine']?.toString() ?? '-',
        log['urea']?.toString() ?? '-',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red700),
      cellHeight: 25,
      cellAlignment: pw.Alignment.center,
    );
  }
}

