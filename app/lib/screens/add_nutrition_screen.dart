import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_log.dart';
import '../services/nutrition_service.dart';
import '../data/food_database.dart';

class AddNutritionScreen extends StatefulWidget {
  const AddNutritionScreen({super.key});

  @override
  State<AddNutritionScreen> createState() => _AddNutritionScreenState();
}

class _AddNutritionScreenState extends State<AddNutritionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carbsController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  MealType _selectedMealType = MealType.breakfast;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Comida'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMealTypeSelector(),
              const SizedBox(height: 24),
              _buildFoodSearch(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildInput('Carbohidratos (g)', _carbsController, Icons.cookie)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput('Proteína (g)', _proteinController, Icons.egg)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInput('Grasas (g)', _fatController, Icons.opacity)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput('Calorías (kcal)', _caloriesController, Icons.bolt)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDateTimePicker(context),
              const SizedBox(height: 24),
              _buildNotesInput(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Nutrición', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de comida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MealType.values.map((meal) {
            return ChoiceChip(
              label: Text(_getMealLabel(meal)),
              selected: _selectedMealType == meal,
              onSelected: (selected) {
                if (selected) setState(() => _selectedMealType = meal);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getMealLabel(MealType meal) {
    switch (meal) {
      case MealType.breakfast: return 'Desayuno';
      case MealType.lunch: return 'Almuerzo';
      case MealType.dinner: return 'Cena';
      case MealType.snack: return 'Snack';
    }
  }

  Widget _buildFoodSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buscador rápido de alimentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Autocomplete<FoodItem>(
          displayStringForOption: (FoodItem option) => '',
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable<FoodItem>.empty();
            return foodDatabase.where((FoodItem food) {
              return food.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (FoodItem selection) async {
            FocusScope.of(context).unfocus(); // Ocultar teclado
            await _showPortionDialog(selection);
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Ej. Manzana, Arroz, Pollo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.blue.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    textEditingController.clear();
                    focusNode.unfocus();
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
                      final FoodItem option = options.elementAt(index);
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.restaurant, color: Colors.white, size: 20),
                        ),
                        title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${option.portion} • ${option.carbs}g Carbs • ${option.calories} kcal', style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
            'Selecciona un alimento para sumar sus valores automáticamente. Puedes buscar y elegir varios.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Future<void> _showPortionDialog(FoodItem food) async {
    double multiplier = 1.0;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('1 Porción = ${food.portion}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  const Text('¿Cuántas porciones consumiste?', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.remove, color: Colors.blue),
                          onPressed: multiplier > 0.25 
                              ? () => setDialogState(() => multiplier -= 0.25)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        multiplier.toStringAsFixed(2).replaceAll('.00', ''),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () => setDialogState(() => multiplier += 0.25),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Representa ${(food.carbs * multiplier).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}g de Carbs',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  onPressed: () {
                    // Aplicar multiplicador a la interfaz
                    final currentCarbs = double.tryParse(_carbsController.text) ?? 0;
                    final currentPro = double.tryParse(_proteinController.text) ?? 0;
                    final currentFat = double.tryParse(_fatController.text) ?? 0;
                    final currentCal = double.tryParse(_caloriesController.text) ?? 0;

                    setState(() {
                      _carbsController.text = (currentCarbs + (food.carbs * multiplier)).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
                      _proteinController.text = (currentPro + (food.protein * multiplier)).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
                      _fatController.text = (currentFat + (food.fat * multiplier)).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
                      _caloriesController.text = (currentCal + (food.calories * multiplier)).toStringAsFixed(0);

                      final notes = _notesController.text;
                      String addedText = multiplier == 1.0 
                          ? '${food.name} (${food.portion})'
                          : '${multiplier.toStringAsFixed(2).replaceAll('.00', '')}x ${food.name} (${food.portion})';
                          
                      if (notes.isEmpty) {
                        _notesController.text = addedText;
                      } else {
                        _notesController.text = '$notes, $addedText';
                      }
                    });
                    
                    Navigator.pop(ctx);
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
        labelText: 'Notas / Alimentos ingeridos',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: 'Ej: 2 rebanadas de pan integral, huevos revueltos...',
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final nutritionService = Provider.of<NutritionService>(context, listen: false);
      final success = await nutritionService.addLog(
        mealType: _selectedMealType,
        carbsG: double.tryParse(_carbsController.text),
        proteinG: double.tryParse(_proteinController.text),
        fatG: double.tryParse(_fatController.text),
        calories: int.tryParse(_caloriesController.text),
        notes: _notesController.text,
        timestamp: _selectedDateTime,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro nutricional guardado')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar el registro')),
          );
        }
      }
    }
  }
}
