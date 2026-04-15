import 'package:flutter/material.dart';

class ComplicationsScreen extends StatelessWidget {
  const ComplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complicaciones y Síntomas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEmergencyCard(context),
          const SizedBox(height: 24),
          const Text(
            'Educación Preventiva',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            context,
            'Hipoglucemia',
            'Nivel bajo de azúcar en sangre. Síntomas: mareo, sudoración, hambre.',
            Icons.warning_amber_rounded,
            Colors.orange,
          ),
          _buildInfoTile(
            context,
            'Hiperglucemia',
            'Nivel alto de azúcar en sangre. Síntomas: sed excesiva, visión borrosa.',
            Icons.error_outline,
            Colors.red,
          ),
          _buildInfoTile(
            context,
            'Pie Diabético',
            'Importancia del cuidado diario de los pies para prevenir úlceras.',
            Icons.accessibility_new,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar a registro de síntomas
            },
            icon: const Icon(Icons.add),
            label: const Text('Registrar nuevo síntoma'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.emergency, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  '¿Situación Crítica?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Si experimentas confusión severa, pérdida de conocimiento o dolor en el pecho, contacta a emergencias inmediatamente.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('LLAMAR A EMERGENCIAS (911)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String desc, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        isThreeLine: true,
      ),
    );
  }
}
