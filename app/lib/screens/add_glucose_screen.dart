import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/glucose_log.dart';
import '../services/glucose_service.dart';

class AddGlucoseScreen extends StatefulWidget {
  const AddGlucoseScreen({super.key});

  @override
  State<AddGlucoseScreen> createState() => _AddGlucoseScreenState();
}

class _AddGlucoseScreenState extends State<AddGlucoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  final _notesController = TextEditingController();
  GlucoseContext _selectedContext = GlucoseContext.fasting;
  DateTime _selectedDateTime = DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _glucoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Glucosa'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildValueInput(),
              const SizedBox(height: 24),
              _buildContextSelector(),
              const SizedBox(height: 24),
              _buildDateTimePicker(context),
              const SizedBox(height: 24),
              _buildNotesInput(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : () async => await _submitForm(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Registro', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nivel de Glucosa (mg/dL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _glucoseController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: '0',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Por favor ingrese un valor';
            final parsed = double.tryParse(value);
            if (parsed == null) return 'Ingrese un número válido';
            if (parsed < 20 || parsed > 600) return 'Valor fuera de rango (20–600 mg/dL)';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContextSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Momento del día', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: GlucoseContext.values.map((context) {
            return ChoiceChip(
              label: Text(_getContextLabel(context)),
              selected: _selectedContext == context,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedContext = context);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getContextLabel(GlucoseContext context) {
    switch (context) {
      case GlucoseContext.fasting: return 'Ayunas';
      case GlucoseContext.preMeal: return 'Antes de comer';
      case GlucoseContext.postMeal: return 'Después de comer';
      case GlucoseContext.beforeBed: return 'Antes de dormir';
      case GlucoseContext.other: return 'Otro';
    }
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha y Hora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _selectDateTime(context),
          icon: const Icon(Icons.calendar_today),
          label: Text('${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year} - ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        if (!mounted) return;
        setState(() {
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notas (Opcional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: '¿Cómo te sientes? ¿Qué comiste?',
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final glucoseService = Provider.of<GlucoseService>(context, listen: false);
      try {
        final success = await glucoseService.addLog(
          double.parse(_glucoseController.text),
          _selectedContext,
          _selectedDateTime,
          _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo guardar el registro. Intente nuevamente.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
