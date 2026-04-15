import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/appointments_service.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() => context.read<AppointmentsService>().fetchAppointments());
  }

  List<dynamic> _getEventsForDay(List<dynamic> allEvents, DateTime day) {
    return allEvents.where((event) {
      final eventDate = DateTime.parse(event['dateTime']).toLocal();
      return isSameDay(eventDate, day);
    }).toList();
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nueva Cita'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Asunto (Ej. Control) *'),
                  ),
                  TextFormField(
                    controller: doctorCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del Médico'),
                  ),
                  TextFormField(
                    controller: specialtyCtrl,
                    decoration: const InputDecoration(labelText: 'Especialidad'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Hora de la cita'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: selectedTime);
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),
                  TextFormField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(labelText: 'Notas / Qué llevar'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.isEmpty) return;
                  final fullDate = DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  final success = await context.read<AppointmentsService>().addAppointment(
                    title: titleCtrl.text,
                    dateTime: fullDate,
                    doctorName: doctorCtrl.text.isNotEmpty ? doctorCtrl.text : null,
                    specialty: specialtyCtrl.text.isNotEmpty ? specialtyCtrl.text : null,
                    notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                  );

                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Cita guardada')));
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentsService>();
    final dayEvents = _getEventsForDay(service.appointments, _selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda y Citas')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            eventLoader: (day) => _getEventsForDay(service.appointments, day),
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: dayEvents.isEmpty
              ? const Center(child: Text('No hay citas para este día.'))
              : ListView.builder(
                  itemCount: dayEvents.length,
                  itemBuilder: (ctx, i) {
                    final appt = dayEvents[i];
                    final time = DateTime.parse(appt['dateTime']).toLocal();
                    final isCompleted = appt['status'] == 'completed';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue),
                            Text(DateFormat.Hm().format(time), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        title: Text(appt['title'], style: TextStyle(decoration: isCompleted ? TextDecoration.lineThrough : null)),
                        subtitle: Text('${appt['doctorName'] ?? "Sin doctor"} - ${appt['specialty'] ?? ""}'),
                        trailing: Checkbox(
                          value: isCompleted,
                          onChanged: (val) {
                            if (val != null) {
                              service.updateStatus(appt['id'], val ? 'completed' : 'scheduled');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
