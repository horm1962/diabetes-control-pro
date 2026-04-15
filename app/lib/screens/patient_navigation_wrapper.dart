import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'glucose_history_screen.dart';
import 'treatment_screen.dart';
import 'habits_screen.dart';
import 'reports_screen.dart';
import 'profile_setup_screen.dart';
import 'package:provider/provider.dart';
import '../services/glucose_service.dart';
import '../services/treatment_service.dart';
import '../services/habits_service.dart';

class PatientNavigationWrapper extends StatefulWidget {
  final int initialIndex;
  const PatientNavigationWrapper({super.key, this.initialIndex = 0});

  @override
  State<PatientNavigationWrapper> createState() => _PatientNavigationWrapperState();
}

class _PatientNavigationWrapperState extends State<PatientNavigationWrapper> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    GlucoseHistoryScreen(),
    TreatmentScreen(),
    HabitsScreen(),
    ReportsScreen(),
    ProfileSetupScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final glucoseHasData = context.watch<GlucoseService>().hasDataToday;
    final treatmentHasData = context.watch<TreatmentService>().hasDataToday;
    final habitsHasData = context.watch<HabitsService>().hasDataToday;

    Color getIconColor(int index, bool hasData) {
      if (_selectedIndex == index) {
        return Theme.of(context).colorScheme.primary;
      }
      return hasData ? Colors.green : Colors.grey;
    }

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? null : Colors.grey),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype, color: getIconColor(1, glucoseHasData)),
            label: 'Glucosa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication, color: getIconColor(2, treatmentHasData)),
            label: 'Tratamiento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: getIconColor(3, habitsHasData)),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: _selectedIndex == 4 ? null : (glucoseHasData || treatmentHasData || habitsHasData ? Colors.green : Colors.grey)),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedIndex == 5 ? null : Colors.green), // El perfil siempre está "completo"
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
