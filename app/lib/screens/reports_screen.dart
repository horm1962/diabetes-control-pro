import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reports_service.dart';
import '../services/glucose_service.dart';
import '../services/vitals_service.dart';
import '../services/nutrition_service.dart';
import '../services/activity_service.dart';
import '../services/lab_results_service.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../widgets/patient_app_bar_title.dart';
import 'pdf_viewer_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<ReportsService>().fetchGlucoseReport();
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportsService>().glucoseReport;

    return Scaffold(
      appBar: AppBar(
        title: const PatientAppBarTitle(title: 'Reportes de Salud'),
        centerTitle: true,
      ),
      floatingActionButton: _buildExportButton(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : report == null
              ? const Center(child: Text('Error al cargar reportes'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Resumen General',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      rowCard(
                        "Promedio de Glucosa",
                        "${report['averageGlucose']} mg/dL",
                        Icons.monitor_heart,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      rowCard(
                        "Control en Nivel Ideal",
                        "${report['timeInRangePercent']}%",
                        Icons.check_circle_outline,
                        report['timeInRangePercent'] >= 70 ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      rowCard(
                        "Glucosa Máxima",
                        "${report['maxGlucose']} mg/dL",
                        Icons.arrow_upward,
                        Colors.red,
                      ),
                      const SizedBox(height: 12),
                      rowCard(
                        "Glucosa Mínima",
                        "${report['minGlucose']} mg/dL",
                        Icons.arrow_downward,
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      rowCard(
                        "Registros Totales",
                        "${report['totalLogs']}",
                        Icons.list_alt,
                        Colors.grey,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget rowCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        // Mostrar indicador de carga inmediatamente
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          final auth = context.read<AuthService>();
          final glucoseService = context.read<GlucoseService>();
          final vitalsService = context.read<VitalsService>();
          final nutritionService = context.read<NutritionService>();
          final activityService = context.read<ActivityService>();
          final labService = context.read<LabResultsService>();

          // Asegurar que tenemos los datos más recientes de TODAS las fuentes
          await Future.wait([
            glucoseService.fetchLogs(),
            vitalsService.fetchLogs(),
            nutritionService.fetchLogs(),
            activityService.fetchLogs(),
            labService.fetchLogs(),
          ]);

          // Validar si hay al menos algo de información para exportar
          if (glucoseService.logs.isEmpty && 
              vitalsService.logs.isEmpty && 
              nutritionService.logs.isEmpty && 
              activityService.logs.isEmpty && 
              labService.logs.isEmpty) {
            if (!context.mounted) return;
            Navigator.pop(context); // Cerrar indicador de carga
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No hay registros de salud disponibles para exportar.'))
            );
            return;
          }

          final pdfBytes = await ExportService.generateMasterHealthReport(
            userName: auth.profile?.firstName ?? 'Paciente',
            glucoseLogs: glucoseService.logs,
            vitalsLogs: vitalsService.logs,
            nutritionLogs: nutritionService.logs,
            activityLogs: activityService.logs,
            labResults: labService.logs,
          );

          if (!context.mounted) return;
          Navigator.pop(context); // Cerrar indicador de carga

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                pdfBytes: pdfBytes,
                fileName: 'Reporte_Salud_${auth.profile?.firstName ?? "Paciente"}.pdf',
              ),
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          Navigator.pop(context); // Cerrar indicador de carga
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
        }
      },
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('Exportar PDF'),
      backgroundColor: Colors.redAccent,
    );
  }
}
