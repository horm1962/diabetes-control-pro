import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habits_service.dart';
import '../widgets/patient_app_bar_title.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  double _sleepHours = 7.0;
  int _waterGlasses = 4;
  String _mood = 'normal';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HabitsService>().fetchLogs());
  }

  void _submitHabits() async {
    final success = await context.read<HabitsService>().addHabitLog(
      sleepHours: _sleepHours,
      waterGlasses: _waterGlasses,
      mood: _mood,
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hábitos registrados')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitsService>();

    return Scaffold(
      appBar: AppBar(title: const PatientAppBarTitle(title: 'Hábitos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Horas de Sueño', style: TextStyle(fontSize: 16)),
                    Slider(
                      value: _sleepHours,
                      min: 0,
                      max: 12,
                      divisions: 24,
                      label: '${_sleepHours.toStringAsFixed(1)} h',
                      onChanged: (val) => setState(() => _sleepHours = val),
                    ),
                    const SizedBox(height: 16),
                    const Text('Vasos de Agua', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () {
                            if (_waterGlasses > 0) setState(() => _waterGlasses--);
                          },
                        ),
                        Text('$_waterGlasses', style: const TextStyle(fontSize: 24)),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () => setState(() => _waterGlasses++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Estado de Ánimo', style: TextStyle(fontSize: 16)),
                    DropdownButton<String>(
                      value: _mood,
                      items: const [
                        DropdownMenuItem(value: 'excelente', child: Text('😁 Excelente')),
                        DropdownMenuItem(value: 'bueno', child: Text('🙂 Bueno')),
                        DropdownMenuItem(value: 'normal', child: Text('😐 Normal')),
                        DropdownMenuItem(value: 'malo', child: Text('😟 Malo')),
                        DropdownMenuItem(value: 'estresado', child: Text('😫 Estresado')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _mood = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _submitHabits,
                      child: const Text('Registrar Hoy'),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            const Text('Historial Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: service.logs.length,
                itemBuilder: (ctx, i) {
                  final log = service.logs[i];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('${log['sleepHours']}h sueño - ${log['waterGlasses']} vasos'),
                    subtitle: Text(
                      (log['timestamp'] != null && log['timestamp'].toString().length >= 16)
                          ? log['timestamp'].toString().substring(0, 16)
                          : (log['timestamp']?.toString() ?? 'Sin fecha'),
                    ),
                    trailing: Text(log['mood']),
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
