import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vitals_service.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  final _pulseController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VitalsService>().fetchLogs());
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final sys = int.parse(_sysController.text);
      final dia = int.parse(_diaController.text);
      final pulse = _pulseController.text.isNotEmpty ? int.parse(_pulseController.text) : null;

      if (dia >= sys) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La presión sistólica debe ser mayor que la diastólica')),
        );
        return;
      }

      final success = await context.read<VitalsService>().addVitalSign(
        systolic: sys,
        diastolic: dia,
        heartRate: pulse,
        notes: _notesController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signos vitales registrados')));
        _formKey.currentState!.reset();
        _sysController.clear();
        _diaController.clear();
        _pulseController.clear();
        _notesController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al registrar')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<VitalsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Presión Arterial y Pulsos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sysController,
                          decoration: const InputDecoration(labelText: 'Sistólica (mmHg)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Req' : null,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('/', style: TextStyle(fontSize: 24)),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _diaController,
                          decoration: const InputDecoration(labelText: 'Diastólica (mmHg)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Req' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pulseController,
                    decoration: const InputDecoration(labelText: 'Frecuencia Cardíaca (lpm)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Guardar'),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text('Historial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: service.logs.length,
                itemBuilder: (ctx, i) {
                  final log = service.logs[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.monitor_heart, color: Colors.red, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Presión: ${log['systolic']}/${log['diastolic']} mmHg',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (log['heartRate'] != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.pink, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  'Pulsos: ${log['heartRate']} lpm',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.pink),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.grey, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                (log['timestamp'] != null && log['timestamp'].toString().length >= 16)
                                    ? log['timestamp'].toString().substring(0, 16)
                                    : (log['timestamp']?.toString() ?? 'Sin fecha'),
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
