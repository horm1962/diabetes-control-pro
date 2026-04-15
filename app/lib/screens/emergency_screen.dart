import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _callEmergency(BuildContext context, String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Marcado Manual Requerido'),
          content: Text('Tu plataforma actual no soporta marcado directo automático. Por favor, llama manualmente al número: $number'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergencia (S.O.S)'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.red,
              child: Icon(Icons.warning, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Necesitas ayuda inmediata?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Llamar a Emergencias (911)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _callEmergency(context, '911'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.contact_phone),
              label: const Text('Llamar al Endocrinólogo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // ToD0: Cargar de shared preferences o DB el número real
                _callEmergency(context, '0000000000');
              },
            ),
            const Divider(height: 48, thickness: 2),
            const Text(
              'Guía Rápida: Hipoglucemia (< 70 mg/dL)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aplica la Regla del 15:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('1. Come o bebe 15 gramos de carbohidratos rápidos (ej. medio vaso de jugo, 3 caramelos, 1 cucharada de miel).'),
                    SizedBox(height: 4),
                    Text('2. Espera 15 minutos.'),
                    SizedBox(height: 4),
                    Text('3. Vuelve a medir tu glucosa.'),
                    SizedBox(height: 4),
                    Text('4. Si sigue baja (<70), repite los pasos 1 al 3.'),
                    SizedBox(height: 12),
                    Text('🚨 Si el paciente pierde el conocimiento, NO darle nada por la boca. Administrar Glucagón o llamar al 911 de inmediato.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Guía Rápida: Hiperglucemia (> 250 mg/dL)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Bebe abundante agua para evitar deshidratación.'),
                    SizedBox(height: 4),
                    Text('2. Si es Tipo 1 y la glucosa es >250, mide cetonas. NO hagas ejercicio si hay cetonas positivas.'),
                    SizedBox(height: 4),
                    Text('3. Aplica dosis de corrección de insulina según lo indicado por tu médico.'),
                    SizedBox(height: 4),
                    Text('4. Mide de nuevo en 2 horas.'),
                    SizedBox(height: 12),
                    Text('🚨 Si hay náuseas, vómito, o dolor abdominal con hiperglucemia, acude a Urgencias (riesgo de CAD).', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
