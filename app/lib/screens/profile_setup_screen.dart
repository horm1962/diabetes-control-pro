import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/doctor_service.dart';
import '../models/user_profile.dart';
import 'package:intl/intl.dart';
import '../widgets/patient_app_bar_title.dart';
import 'patient_navigation_wrapper.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _targetLowController = TextEditingController();
  final _targetHighController = TextEditingController();
  final _insulinTypeController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _doctorEmailController = TextEditingController();
  DiabetesType _selectedType = DiabetesType.type1;
  TherapyType _selectedTherapy = TherapyType.diet_only;
  DateTime _birthDate = DateTime(1990, 1, 1);
  bool _isLoading = false;
  Map<String, dynamic>? _foundDoctor;
  bool _searchingDoctor = false;
  String? _linkedDoctorName;

  @override
  void initState() {
    super.initState();
    _populateFromCurrentProfile();
  }

  void _populateFromCurrentProfile() {
    final profile = Provider.of<AuthService>(context, listen: false).profile;
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _weightController.text = profile.weightKg.toString();
      _heightController.text = profile.heightCm.toString();
      _targetLowController.text = profile.targetGlucoseLow.toString();
      _targetHighController.text = profile.targetGlucoseHigh.toString();
      _insulinTypeController.text = profile.insulinType ?? '';
      _medicationsController.text = profile.medications ?? '';
      _allergiesController.text = profile.allergies ?? '';
      _selectedType = profile.diabetesType;
      _selectedTherapy = profile.therapyType;
      _birthDate = profile.birthDate;
    } else {
      _targetLowController.text = '70';
      _targetHighController.text = '140';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetLowController.dispose();
    _targetHighController.dispose();
    _insulinTypeController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _doctorEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const PatientAppBarTitle(title: 'Configuración de Perfil')),
      body: Consumer<AuthService>(
        builder: (context, auth, child) {
          // Si el perfil se cargó pero los controladores están vacíos (o son diferentes), actualizarlos
          if (auth.profile != null && _firstNameController.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _populateFromCurrentProfile());
            });
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              const Text(
                'Personaliza tu experiencia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Esto nos ayuda a adaptar las recomendaciones a tu tipo de diabetes.'),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),
              
              const Text('Tipo de Diabetes', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<DiabetesType>(
                value: _selectedType,
                items: [
                  DropdownMenuItem(value: DiabetesType.type1, child: Text('Tipo 1')),
                  DropdownMenuItem(value: DiabetesType.type2, child: Text('Tipo 2')),
                  DropdownMenuItem(value: DiabetesType.gestational, child: Text('Gestacional')),
                ],
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              
              const Text('Terapia Base', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<TherapyType>(
                value: _selectedTherapy,
                items: [
                  DropdownMenuItem(value: TherapyType.diet_only, child: Text('Solo Dieta')),
                  DropdownMenuItem(value: TherapyType.oral, child: Text('Fármacos Orales')),
                  DropdownMenuItem(value: TherapyType.insulin, child: Text('Insulina')),
                  DropdownMenuItem(value: TherapyType.combined, child: Text('Combinado')),
                ],
                onChanged: (val) => setState(() => _selectedTherapy = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              if (_selectedTherapy == TherapyType.insulin || _selectedTherapy == TherapyType.combined)
                TextFormField(
                  controller: _insulinTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Insulina',
                    hintText: 'Ej: Glargina, Aspart, NPH',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 24),

              const Text('Medicamentos y Alergias', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicationsController,
                decoration: const InputDecoration(labelText: 'Otros Medicamentos', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Alergias', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              const Text('Metas de Glucosa (mg/dL)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetLowController,
                      decoration: const InputDecoration(labelText: 'Mínimo', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _targetHighController,
                      decoration: const InputDecoration(labelText: 'Máximo', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ListTile(
                title: const Text('Fecha de Nacimiento'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_birthDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Altura (cm)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Guardar Perfil', style: TextStyle(fontSize: 18)),
              ),

              // Sección: Mi Médico
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.medical_services, color: Color(0xFF1565C0)),
                          SizedBox(width: 8),
                          Text(
                            'Mi Médico',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vincula a tu médico con su correo electrónico para que pueda ver tu historial y progreso médico.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),

              if (_linkedDoctorName != null)
                Card(
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green.shade200),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.verified_user, color: Colors.green),
                    title: Text(_linkedDoctorName!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Médico vinculado'),
                    trailing: TextButton(
                      onPressed: _unlinkDoctor,
                      child: const Text('Desvincular',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                )
              else ...
                [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _doctorEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo del médico',
                            hintText: 'doctor@ejemplo.com',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _searchingDoctor ? null : _searchDoctor,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                        ),
                        child: _searchingDoctor
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Buscar'),
                      ),
                    ],
                  ),
                  if (_foundDoctor != null)
                    Card(
                      margin: const EdgeInsets.only(top: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1565C0),
                          child:
                              Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(_foundDoctor!['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(_foundDoctor!['email'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () => _linkDoctor(_foundDoctor!['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Vincular'),
                        ),
                      ),
                    ),
                    ],
                  ],
                ),
              ),
            ),

            ],
          ),
        ),
      );
    },
  ),
);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final auth = Provider.of<AuthService>(context, listen: false);
      
      final profile = UserProfile(
        userId: auth.user!.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        diabetesType: _selectedType,
        therapyType: _selectedTherapy,
        birthDate: _birthDate,
        weightKg: double.tryParse(_weightController.text) ?? 0,
        heightCm: double.tryParse(_heightController.text) ?? 0,
        targetGlucoseLow: double.tryParse(_targetLowController.text) ?? 70,
        targetGlucoseHigh: double.tryParse(_targetHighController.text) ?? 140,
        insulinType: _insulinTypeController.text,
        medications: _medicationsController.text,
        allergies: _allergiesController.text,
      );

      try {
        final success = await auth.updateProfile(profile);
        
        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Perfil guardado con éxito!')));
          
          auth.isNewRegistration = false;
        }
      } catch (e) {
        if (!mounted) return;
        String errorMsg = e.toString().replaceAll('Exception:', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _searchDoctor() async {
    final email = _doctorEmailController.text.trim();
    if (email.isEmpty) return;
    setState(() { _searchingDoctor = true; _foundDoctor = null; });
    final doctorService = Provider.of<DoctorService>(context, listen: false);
    final result = await doctorService.searchDoctorByEmail(email);
    setState(() {
      _foundDoctor = result;
      _searchingDoctor = false;
    });
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró ningún médico con ese correo.')),
      );
    }
  }

  Future<void> _linkDoctor(String doctorId) async {
    final doctorService = Provider.of<DoctorService>(context, listen: false);
    try {
      final success = await doctorService.linkDoctor(doctorId);
      if (success && mounted) {
        setState(() {
          _linkedDoctorName = _foundDoctor?['name'];
          _foundDoctor = null;
          _doctorEmailController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Médico vinculado exitosamente!')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception:', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unlinkDoctor() async {
    final doctorService = Provider.of<DoctorService>(context, listen: false);
    final success = await doctorService.unlinkDoctor();
    if (success && mounted) {
      setState(() { _linkedDoctorName = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Médico desvinculado.')),
      );
    }
  }
}
