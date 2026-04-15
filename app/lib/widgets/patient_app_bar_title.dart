import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class PatientAppBarTitle extends StatelessWidget {
  final String title;
  const PatientAppBarTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final profile = auth.profile;
        final fullName = profile != null && profile.firstName.isNotEmpty 
            ? '${profile.firstName} ${profile.lastName}' 
            : auth.user?.email ?? 'Paciente';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(
              fullName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        );
      },
    );
  }
}
