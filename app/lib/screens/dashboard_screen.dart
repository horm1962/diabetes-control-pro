import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'add_glucose_screen.dart';
import 'add_nutrition_screen.dart';
import 'add_activity_screen.dart';
import 'glucose_history_screen.dart';
import 'reminders_screen.dart';
import 'complications_screen.dart';
import 'vitals_screen.dart';
import 'lab_results_screen.dart';
import 'appointments_screen.dart';
import 'emergency_screen.dart';
import 'education_screen.dart';
import '../models/user_profile.dart';
import '../services/glucose_service.dart';
import '../services/diabetes_guidelines.dart';
import '../widgets/patient_app_bar_title.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GlucoseService>(context, listen: false).fetchLatestLog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PatientAppBarTitle(title: 'Inicio'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EducationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emergency, color: Colors.orangeAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmergencyScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildSummaryCard(context),
            const SizedBox(height: 24),
            _buildLatestGlucose(context),
            const SizedBox(height: 24),
            _buildCustomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestGlucose(BuildContext context) {
    return Consumer<GlucoseService>(
      builder: (context, glucoseService, child) {
        final latestLog = glucoseService.latestLog;

        if (latestLog == null) {
          return const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.history, color: Colors.grey),
              title: Text('Sin registros recientes'),
              subtitle: Text('Toca el botón + para empezar'),
            ),
          );
        }

        final timeAgo = DateTime.now().difference(latestLog.timestamp);
        String timeStr = 'Hace poco';
        if (timeAgo.inHours > 0) {
          timeStr = 'Hace ${timeAgo.inHours} horas';
        } else if (timeAgo.inMinutes > 0) {
          timeStr = 'Hace ${timeAgo.inMinutes} minutos';
        }

        return Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text('Último registro'),
            subtitle: Text('$timeStr - ${latestLog.contextLabel}'),
            trailing: Text(
              '${latestLog.value.toStringAsFixed(0)} mg/dL',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer2<AuthService, GlucoseService>(
      builder: (context, auth, glucoseService, _) {
        final profile = auth.profile;
        final tir = glucoseService.calculateTIR(
          profile?.targetGlucoseLow ?? 70,
          profile?.targetGlucoseHigh ?? 140,
        );
        final insight = glucoseService.getInsight(
          profile?.targetGlucoseLow ?? 70,
          profile?.targetGlucoseHigh ?? 140,
        );
        
        String diabetesLabel = '';
        if (profile != null) {
          switch (profile.diabetesType) {
            case DiabetesType.type1:
              diabetesLabel = '(Tipo 1)';
              break;
            case DiabetesType.type2:
              diabetesLabel = '(Tipo 2)';
              break;
            case DiabetesType.gestational:
              diabetesLabel = '(Gestacional)';
              break;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola ${profile?.firstName ?? "de nuevo"}!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Resumen hoy $diabetesLabel',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tir['total_logs'] > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insights, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: [
        _quickActionItem(context, Icons.bloodtype, 'Glucosa', Colors.red, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGlucoseScreen()),
          );
        }),
        _quickActionItem(context, Icons.favorite, 'Vitales', Colors.pink, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VitalsScreen()),
          );
        }),
        _quickActionItem(context, Icons.science, 'Laboratorio', Colors.deepPurple, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LabResultsScreen()),
          );
        }),
        _quickActionItem(context, Icons.restaurant, 'Nutrición', Colors.orange, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNutritionScreen()),
          );
        }),
        _quickActionItem(context, Icons.fitness_center, 'Actividad', Colors.blue, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddActivityScreen()),
          );
        }),
        _quickActionItem(context, Icons.calendar_month, 'Agenda', Colors.teal, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
          );
        }),
        _quickActionItem(context, Icons.medication, 'Recordatorios', Colors.green, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RemindersScreen()),
          );
        }),
      ],
    );
  }

  Widget _quickActionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GlucoseHistoryScreen()),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer2<AuthService, GlucoseService>(
            builder: (context, auth, glucoseService, _) {
              final profile = auth.profile;
              final tirInfo = glucoseService.calculateTIR(
                profile?.targetGlucoseLow ?? 70,
                profile?.targetGlucoseHigh ?? 140,
              );
              
              final double tirPercent = tirInfo['in_range'] ?? 0.0;
              final double tirFraction = (tirPercent / 100).clamp(0.0, 1.0);
              
              String message = 'Registra datos para ver tu progreso.';
              Color color = Colors.grey;
              
              if (tirInfo['total_logs'] > 0) {
                if (tirPercent >= 70) {
                  message = 'Buen trabajo, estás en rango.';
                  color = Colors.green;
                } else if (tirPercent >= 50) {
                  message = 'Puedes mejorar tu porcentaje en nivel ideal.';
                  color = Colors.orange;
                } else {
                  message = 'Atención, mucho tiempo fuera de rango.';
                  color = Colors.red;
                }
              }

              return Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Control en Nivel Ideal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${tirPercent.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: tirInfo['total_logs'] > 0 ? tirFraction : 0,
                    backgroundColor: Colors.grey[200],
                    color: color,
                    minHeight: 8,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomSection(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final profile = auth.profile;
        if (profile == null) return const SizedBox();

        final ranges = DiabetesGuidelines.targetRanges(profile.diabetesType);
        final tips = DiabetesGuidelines.dailyTips(profile.diabetesType);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRangeCard(ranges),
            const SizedBox(height: 24),
            const Text('Consejos del día', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...tips.map((tip) => _buildTipTile(tip)),
            const SizedBox(height: 24),
            _buildMealPlanCard(profile.diabetesType),
          ],
        );
      },
    );
  }

  Widget _buildRangeCard(Map<String, double> ranges) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.track_changes, color: Colors.blue),
                SizedBox(width: 8),
                Text('Tus Objetivos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _rangeItem('Ayunas', '${ranges['low']}-${ranges['high']}'),
                _rangeItem('Post-Comida', '<${ranges['post_meal']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangeItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('mg/dL', style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildTipTile(String tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.lightbulb, color: Colors.orange),
        title: Text(tip, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildMealPlanCard(DiabetesType type) {
    String title = '';
    String desc = '';
    switch (type) {
      case DiabetesType.type1:
        title = 'Conteo de Carbohidratos';
        desc = 'Aprende a ajustar tu insulina según lo que comes.';
        break;
      case DiabetesType.type2:
        title = 'Plato Saludable';
        desc = '50% vegetales, 25% proteína, 25% carbohidratos complejos.';
        break;
      case DiabetesType.gestational:
        title = 'Plan Gestacional';
        desc = 'Comidas pequeñas y frecuentes para evitar picos de glucosa.';
        break;
    }

    return Card(
      elevation: 0,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.restaurant_menu, color: Colors.green),
        onTap: () {
          // Navegar a detalles de nutrición
        },
      ),
    );
  }
}
