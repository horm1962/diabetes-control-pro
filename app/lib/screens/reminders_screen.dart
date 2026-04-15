import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_item.dart';
import '../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final NotificationService _notificationService = NotificationService();
  
  List<ReminderItem> _glucoseReminders = [];
  List<ReminderItem> _medicationReminders = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    
    final glucoseString = prefs.getString('glucose_reminders');
    if (glucoseString != null) {
      final List<dynamic> decoded = json.decode(glucoseString);
      _glucoseReminders = decoded.map((e) => ReminderItem.fromJson(e)).toList();
    } else {
      // Default initial state for new users
      _glucoseReminders = [
        ReminderItem(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          type: ReminderType.glucose,
          title: 'Medición de Glucosa',
          body: 'Medición en ayunas',
          time: const TimeOfDay(hour: 8, minute: 0),
          isEnabled: false,
        )
      ];
    }

    final medString = prefs.getString('medication_reminders');
    if (medString != null) {
      final List<dynamic> decoded = json.decode(medString);
      _medicationReminders = decoded.map((e) => ReminderItem.fromJson(e)).toList();
    } else {
      // Default initial state
      _medicationReminders = [
        ReminderItem(
          id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1,
          type: ReminderType.medication,
          title: 'Medicación Principal',
          body: 'No olvides tu dosis',
          time: const TimeOfDay(hour: 21, minute: 0),
          isEnabled: false,
        )
      ];
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveReminders() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('glucose_reminders', json.encode(_glucoseReminders.map((e) => e.toJson()).toList()));
    await prefs.setString('medication_reminders', json.encode(_medicationReminders.map((e) => e.toJson()).toList()));
    
    await _notificationService.cancelAll();
    
    for (var r in [..._glucoseReminders, ..._medicationReminders]) {
      if (r.isEnabled) {
        await _notificationService.scheduleReminder(
          id: r.id,
          title: r.title,
          body: r.body,
          time: r.time,
        );
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorios actualizados y guardados exitosamente')),
      );
    }
  }

  void _addGlucoseReminder() async {
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));
    if (time != null) {
      setState(() {
        _glucoseReminders.add(ReminderItem(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          type: ReminderType.glucose,
          title: 'Medición de Glucosa',
          body: 'No olvides registrar tu glucosa',
          time: time,
          isEnabled: true,
        ));
      });
      _saveReminders();
    }
  }

  void _addMedicationReminder() {
    final nameController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nueva Medicación'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre y dosis',
                      hintText: 'Ej. Metformina 500mg',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Hora:'),
                    trailing: TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(context: context, initialTime: selectedTime);
                        if (time != null) {
                          setDialogState(() => selectedTime = time);
                        }
                      },
                      child: Text(selectedTime.format(context), style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      setState(() {
                        _medicationReminders.add(ReminderItem(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          type: ReminderType.medication,
                          title: nameController.text.trim(),
                          body: 'Hora de tu medicación',
                          time: selectedTime,
                          isEnabled: true,
                        ));
                      });
                      _saveReminders();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _deleteReminder(ReminderItem item, bool isGlucose) {
    setState(() {
      if (isGlucose) {
        _glucoseReminders.removeWhere((r) => r.id == item.id);
      } else {
        _medicationReminders.removeWhere((r) => r.id == item.id);
      }
    });
    _notificationService.cancel(item.id);
    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Configura tus alertas diarias. Puedes agregar múltiples horarios para tus mediciones y diferentes pastillas.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              // Sección Glucosa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bloodtype, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Mediciones de Glucosa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.red, size: 28),
                    onPressed: _addGlucoseReminder,
                  ),
                ],
              ),
              const Divider(),
              if (_glucoseReminders.isEmpty)
                const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay alertas de glucosa', style: TextStyle(color: Colors.grey))),
              ..._glucoseReminders.map((r) => _buildReminderTile(r, true)),
              
              const SizedBox(height: 32),
              
              // Sección Medicación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.medication, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Mis Medicamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                    onPressed: _addMedicationReminder,
                  ),
                ],
              ),
              const Divider(),
              if (_medicationReminders.isEmpty)
                const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay alarmas de medicación', style: TextStyle(color: Colors.grey))),
              ..._medicationReminders.map((r) => _buildReminderTile(r, false)),

              const SizedBox(height: 40),
            ],
          ),
    );
  }

  Widget _buildReminderTile(ReminderItem item, bool isGlucose) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          Icons.access_alarm,
          color: item.isEnabled ? (isGlucose ? Colors.red : Colors.blue) : Colors.grey,
        ),
        title: Text(
          item.type == ReminderType.medication ? item.title : item.time.format(context),
          style: TextStyle(fontWeight: FontWeight.bold, decoration: item.isEnabled ? null : TextDecoration.lineThrough),
        ),
        subtitle: Text(
          item.type == ReminderType.medication ? item.time.format(context) : item.title,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: item.isEnabled,
              activeColor: isGlucose ? Colors.red : Colors.blue,
              onChanged: (val) {
                setState(() => item.isEnabled = val);
                _saveReminders();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _deleteReminder(item, isGlucose),
            ),
          ],
        ),
        onTap: () async {
          // Permite editar la hora rápidamente al tocar
          final newTime = await showTimePicker(context: context, initialTime: item.time);
          if (newTime != null) {
            setState(() { /* update via reference but wait, time is final. We must recreate */ });
            // Let's keep it simple, they can delete and recreate or we recreate the item
            final index = isGlucose 
              ? _glucoseReminders.indexOf(item)
              : _medicationReminders.indexOf(item);
            
            final updatedItem = ReminderItem(
              id: item.id,
              type: item.type,
              title: item.title,
              body: item.body,
              time: newTime,
              isEnabled: item.isEnabled,
            );

            setState(() {
              if (isGlucose) {
                _glucoseReminders[index] = updatedItem;
              } else {
                _medicationReminders[index] = updatedItem;
              }
            });
            _saveReminders();
          }
        },
      ),
    );
  }
}
