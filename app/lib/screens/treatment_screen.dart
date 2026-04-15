import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/treatment_service.dart';
import '../widgets/patient_app_bar_title.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = 'insulin';
  String _selectedUnit = 'unidades';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TreatmentService>().fetchLogs());
  }

  @override
  void dispose() {
    _medNameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<TreatmentService>().addTreatment(
        type: _selectedType,
        medicationName: _medNameController.text,
        dosage: double.parse(_dosageController.text),
        unit: _selectedUnit,
        notes: _notesController.text,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento registrado correctamente')),
        );
        _formKey.currentState!.reset();
        _medNameController.clear();
        _dosageController.clear();
        _notesController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TreatmentService>();

    return Scaffold(
      appBar: AppBar(title: const PatientAppBarTitle(title: 'Tratamiento Médico')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo de Tratamiento'),
                    items: const [
                      DropdownMenuItem(value: 'insulin', child: Text('Insulina')),
                      DropdownMenuItem(value: 'oral_medication', child: Text('Medicación Oral')),
                      DropdownMenuItem(value: 'other', child: Text('Otro')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                  TextFormField(
                    controller: _medNameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Medicamento'),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(labelText: 'Dosis'),
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: const InputDecoration(labelText: 'Unidad'),
                          items: const [
                            DropdownMenuItem(value: 'unidades', child: Text('Unidades')),
                            DropdownMenuItem(value: 'mg', child: Text('Miligramos (mg)')),
                            DropdownMenuItem(value: 'ml', child: Text('Mililitros (ml)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUnit = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notas Adicionales'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: const Text('Registrar Dosis'),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: service.logs.length,
                itemBuilder: (ctx, i) {
                  final log = service.logs[i];
                  return ListTile(
                    leading: const Icon(Icons.medication),
                    title: Text('${log['medicationName']} - ${log['dosage']} ${log['unit']}'),
                    subtitle: Text(
                      (log['timestamp'] != null && log['timestamp'].toString().length >= 16)
                          ? log['timestamp'].toString().substring(0, 16)
                          : (log['timestamp']?.toString() ?? 'Sin fecha'),
                    ),
                    trailing: Text(log['type'] == 'insulin' ? 'Insulina' : 'Oral'),
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
