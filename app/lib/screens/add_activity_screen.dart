import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_log.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../data/activity_database.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  ActivityIntensity _selectedIntensity = ActivityIntensity.medium;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;
  double? _currentMets;
  late TextEditingController _autocompleteController;

  @override
  void initState() {
    super.initState();
    _durationController.addListener(_calculateCalories);
  }

  void _calculateCalories() {
    if (_currentMets == null) return;
    final duration = double.tryParse(_durationController.text);
    if (duration == null || duration <= 0) return;
    
    final auth = Provider.of<AuthService>(context, listen: false);
    final weight = auth.profile?.weightKg != null && auth.profile!.weightKg > 0 
        ? auth.profile!.weightKg 
        : 70.0;
    
    // Fórmula de calorías quemadas: METs * Peso(kg) * Tiempo(h)
    final calories = _currentMets! * weight * (duration / 60);
    _caloriesController.text = calories.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Actividad'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActivitySearch(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Duración (min)',
                        prefixIcon: const Icon(Icons.timer),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingrese la duración';
                        if (int.tryParse(value) == null) return 'Ingrese un número';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Calorías (kcal)',
                        prefixIcon: const Icon(Icons.local_fire_department),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildIntensitySelector(),
              const SizedBox(height: 24),
              _buildDateTimePicker(context),
              const SizedBox(height: 24),
              _buildNotesInput(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Actividad', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Intensidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ActivityIntensity.values.map((intensity) {
            return ChoiceChip(
              label: Text(_getIntensityLabel(intensity)),
              selected: _selectedIntensity == intensity,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIntensity = intensity);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getIntensityLabel(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.low: return 'Baja';
      case ActivityIntensity.medium: return 'Media';
      case ActivityIntensity.high: return 'Alta';
    }
  }

  Widget _buildActivitySearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Calculadora Automática de Actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Autocomplete<ActivityItem>(
          displayStringForOption: (ActivityItem option) => option.name,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable<ActivityItem>.empty();
            return activityDatabase.where((ActivityItem activity) {
              return activity.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (ActivityItem selection) {
            FocusScope.of(context).unfocus();
            _autocompleteController.text = selection.name;
            setState(() {
              _selectedIntensity = selection.defaultIntensity;
              _currentMets = selection.mets;
            });
            
            if (_durationController.text.isEmpty) {
              _durationController.text = '30';
            } else {
              _calculateCalories();
            }
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            _autocompleteController = textEditingController; // Save custom text reference
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              validator: (val) => val == null || val.isEmpty ? 'Escribe o elige una actividad' : null,
              decoration: InputDecoration(
                hintText: 'Ej. Caminar, Correr, Natación...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.green.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    textEditingController.clear();
                    focusNode.unfocus();
                    _currentMets = null;
                  },
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 250, maxWidth: MediaQuery.of(context).size.width - 32),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final ActivityItem option = options.elementAt(index);
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.directions_run, color: Colors.white, size: 20),
                        ),
                        title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Intensidad: ${_getIntensityLabel(option.defaultIntensity)}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Al seleccionar un ejercicio, se calcularán las calorías automáticamente multiplicadas por tu peso (kg) actual guardado en tu perfil y el tiempo.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
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
          label: Text('${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} - ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}'),
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
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notas adicionales',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: '¿Cómo te sentiste durante el ejercicio?',
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final activityService = Provider.of<ActivityService>(context, listen: false);
      final success = await activityService.addLog(
        activityType: _autocompleteController.text,
        durationMinutes: int.parse(_durationController.text),
        intensity: _selectedIntensity,
        caloriesBurned: int.tryParse(_caloriesController.text),
        timestamp: _selectedDateTime,
        notes: _notesController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Actividad guardada exitosamente')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar la actividad')),
          );
        }
      }
    }
  }
}
