import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/lab_results_service.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hba1cController = TextEditingController();
  final _cholesterolController = TextEditingController();
  final _triglyceridesController = TextEditingController();
  final _creatinineController = TextEditingController();
  final _hemoglobinController = TextEditingController();
  final _ureaController = TextEditingController();
  final _cystatinCController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LabResultsService>().fetchLogs());
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final hba1c = double.tryParse(_hba1cController.text);
      final chol = double.tryParse(_cholesterolController.text);
      final trig = double.tryParse(_triglyceridesController.text);
      final creat = double.tryParse(_creatinineController.text);
      final hemo = double.tryParse(_hemoglobinController.text);
      final ur = double.tryParse(_ureaController.text);
      final cys = double.tryParse(_cystatinCController.text);

      if (hba1c == null && chol == null && trig == null && creat == null && hemo == null && ur == null && cys == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa al menos un valor')));
        return;
      }

      final success = await context.read<LabResultsService>().addLabResult(
        hba1c: hba1c,
        cholesterolResult: chol,
        triglycerides: trig,
        creatinine: creat,
        hemoglobin: hemo,
        urea: ur,
        cystatinC: cys,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultados guardados')));
        _hba1cController.clear();
        _cholesterolController.clear();
        _triglyceridesController.clear();
        _creatinineController.clear();
        _hemoglobinController.clear();
        _ureaController.clear();
        _cystatinCController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<LabResultsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados de Laboratorio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: ExpansionTile(
                    title: const Text('Registrar Nuevo Examen', style: TextStyle(fontWeight: FontWeight.bold)),
                    initiallyExpanded: true,
                    children: [
                      TextFormField(
                        controller: _hba1cController,
                        decoration: const InputDecoration(labelText: 'Hemoglobina A1c (%)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cholesterolController,
                        decoration: const InputDecoration(labelText: 'Colesterol Total (mg/dL)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _triglyceridesController,
                        decoration: const InputDecoration(labelText: 'Triglicéridos (mg/dL)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _creatinineController,
                        decoration: const InputDecoration(labelText: 'Creatinina (mg/dL)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _hemoglobinController,
                        decoration: const InputDecoration(labelText: 'Hemoglobina (g/dL)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ureaController,
                        decoration: const InputDecoration(labelText: 'Urea (mg/dL)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cystatinCController,
                        decoration: const InputDecoration(labelText: 'Cistatina C (mg/L)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        child: _isLoading ? const CircularProgressIndicator() : const Text('Guardar Resultados'),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            const Text('Historial Clínico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              flex: 4,
              child: ListView.builder(
                itemCount: service.logs.length,
                itemBuilder: (ctx, i) {
                  final log = service.logs[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.science, color: Colors.blue),
                      title: Text(log['timestamp'].toString().substring(0, 10)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (log['hba1c'] != null) Text('HbA1c: ${log['hba1c']}%'),
                          if (log['cholesterolResult'] != null) Text('Colesterol: ${log['cholesterolResult']} mg/dL'),
                          if (log['triglycerides'] != null) Text('Triglicéridos: ${log['triglycerides']} mg/dL'),
                          if (log['creatinine'] != null) Text('Creatinina: ${log['creatinine']} mg/dL'),
                          if (log['hemoglobin'] != null) Text('Hemoglobina: ${log['hemoglobin']} g/dL'),
                          if (log['urea'] != null) Text('Urea: ${log['urea']} mg/dL'),
                          if (log['cystatinC'] != null) Text('Cistatina C: ${log['cystatinC']} mg/L'),
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
