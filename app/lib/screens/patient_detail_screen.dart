import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/doctor_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() { _isLoading = true; _error = null; });
    final doctorService = Provider.of<DoctorService>(context, listen: false);
    final result = await doctorService.fetchPatientSummary(widget.patientId);
    setState(() {
      _summary = result;
      _isLoading = false;
      if (result == null) _error = 'No se pudo cargar la información del paciente.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Text(
          widget.patientName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSummary,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSummary,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_summary == null) return const SizedBox();

    final profile = _summary!['profile'] as Map<String, dynamic>;
    final stats = _summary!['stats'] as Map<String, dynamic>;
    final recentLogs = _summary!['recentLogs'] as List<dynamic>;

    final tir = stats['tirPercent'] as int? ?? 0;
    final avg = stats['avgGlucose'] as int? ?? 0;
    final total = stats['totalLogs'] as int? ?? 0;
    final lastVal = stats['latestValue'];
    final lastTs = stats['latestTimestamp'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta del perfil clínico
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF1565C0),
                        child: Text(
                          widget.patientName.isNotEmpty
                              ? widget.patientName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patientName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _diabetesLabel(profile['diabetesType'] ?? ''),
                              style: const TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _therapyLabel(profile['therapyType'] ?? ''),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _infoRow('Peso', '${profile['weightKg']} kg'),
                  _infoRow('Altura', '${profile['heightCm']} cm'),
                  _infoRow('Rango objetivo',
                      '${profile['targetGlucoseLow']}–${profile['targetGlucoseHigh']} mg/dL'),
                  if ((profile['medications'] ?? '').toString().isNotEmpty)
                    _infoRow('Medicamentos', profile['medications']),
                  if ((profile['insulinType'] ?? '').toString().isNotEmpty)
                    _infoRow('Tipo de insulina', profile['insulinType']),
                  if ((profile['allergies'] ?? '').toString().isNotEmpty)
                    _infoRow('Alergias', profile['allergies']),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Estadísticas de glucosa
          const Text('Estadísticas de Glucosa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Row(
            children: [
              _statCard('TIR', '$tir%',
                  tir >= 70 ? Colors.green : tir >= 50 ? Colors.orange : Colors.red,
                  Icons.track_changes),
              const SizedBox(width: 12),
              _statCard('Promedio', '$avg mg/dL', Colors.blue, Icons.show_chart),
              const SizedBox(width: 12),
              _statCard('Registros', '$total', Colors.purple, Icons.list_alt),
            ],
          ),

          if (lastVal != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: Text(
                  'Última medición: $lastVal mg/dL',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: lastTs != null
                    ? Text(DateFormat('dd/MM/yyyy HH:mm').format(
                        DateTime.parse(lastTs).toLocal()))
                    : null,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Historial reciente
          if (recentLogs.isNotEmpty) ...[
            const Text('Registros Recientes (últimos 10)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...recentLogs.map((log) {
              final value = log['value'];
              final context = log['context'] ?? '';
              final timestamp = log['timestamp'];
              final notes = log['notes'];
              final color = _glucoseColor(value is num ? value.toDouble() : 0);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(Icons.bloodtype, color: color, size: 20),
                  ),
                  title: Text(
                    '${value is num ? value.toStringAsFixed(0) : value} mg/dL',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_contextLabel(context),
                          style: const TextStyle(fontSize: 12)),
                      if (timestamp != null)
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(
                              DateTime.parse(timestamp).toLocal()),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: notes != null && notes.toString().isNotEmpty
                      ? const Icon(Icons.note, size: 16, color: Colors.grey)
                      : null,
                  isThreeLine: true,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Color _glucoseColor(double v) {
    if (v < 70) return Colors.orange;
    if (v > 180) return Colors.red;
    return Colors.green;
  }

  String _contextLabel(String c) {
    const map = {
      'fasting': 'En ayunas',
      'pre_meal': 'Pre-comida',
      'post_meal': 'Post-comida',
      'bedtime': 'Al dormir',
      'other': 'Otro',
    };
    return map[c] ?? c;
  }

  String _diabetesLabel(String type) {
    switch (type) {
      case 'type1':
        return 'Diabetes Tipo 1';
      case 'type2':
        return 'Diabetes Tipo 2';
      case 'gestational':
        return 'Gestacional';
      default:
        return type;
    }
  }

  String _therapyLabel(String t) {
    switch (t) {
      case 'insulin':
        return 'Tratamiento con Insulina';
      case 'oral':
        return 'Fármacos Orales';
      case 'combined':
        return 'Terapia Combinada';
      case 'diet_only':
        return 'Solo Dieta';
      default:
        return t;
    }
  }
}
