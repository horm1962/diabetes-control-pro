import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/patient_navigation_wrapper.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/glucose_service.dart';
import 'services/nutrition_service.dart';
import 'services/notification_service.dart';
import 'services/activity_service.dart';
import 'services/doctor_service.dart';
import 'services/treatment_service.dart';
import 'services/habits_service.dart';
import 'services/reports_service.dart';
import 'services/lab_results_service.dart';
import 'services/vitals_service.dart';
import 'services/appointments_service.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await NotificationService().init();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, GlucoseService>(
          create: (context) => GlucoseService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, glucoseService) => glucoseService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, NutritionService>(
          create: (context) => NutritionService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, nutritionService) => nutritionService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, ActivityService>(
          create: (context) => ActivityService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, activityService) => activityService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, DoctorService>(
          create: (context) => DoctorService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, doctorService) => doctorService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, TreatmentService>(
          create: (context) => TreatmentService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, treatmentService) => treatmentService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, HabitsService>(
          create: (context) => HabitsService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, habitsService) => habitsService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, ReportsService>(
          create: (context) => ReportsService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, reportsService) => reportsService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, LabResultsService>(
          create: (context) => LabResultsService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, labResultsService) => labResultsService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, VitalsService>(
          create: (context) => VitalsService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, vitalsService) => vitalsService!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, AppointmentsService>(
          create: (context) => AppointmentsService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, appointmentsService) => appointmentsService!..updateAuth(auth),
        ),
      ],
      child: const ControlDiabetesApp(),
    ),
  );
}

class ControlDiabetesApp extends StatelessWidget {
  const ControlDiabetesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controlando Mi Diabetes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF4CAF50),
        ),
      ),
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) return const LoginScreen();
          
          if (auth.user?.role == UserRole.doctor) {
            return const DoctorDashboardScreen();
          }
          return PatientNavigationWrapper(
            initialIndex: auth.isNewRegistration ? 5 : 0,
          );
        },
      ),
    );
  }
}
