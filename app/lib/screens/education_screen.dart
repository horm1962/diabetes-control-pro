import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centro Educativo')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCategoryHeader('Entendiendo la Diabetes', Icons.lightbulb, Colors.orange),
          _buildArticleCard(
            context,
            '¿Qué es la Hemoglobina A1c?',
            'La HbA1c es una prueba de sangre que refleja tu nivel promedio de glucosa en los últimos 3 meses...',
          ),
          _buildArticleCard(
            context,
            'Diferencias entre Tipo 1, Tipo 2 y Gestacional',
            'Conoce las bases fisiológicas de tu diagnóstico y por qué los tratamientos varían...',
          ),
          const SizedBox(height: 16),
          _buildCategoryHeader('Nutrición y Alimentación', Icons.restaurant, Colors.green),
          _buildArticleCard(
            context,
            'El Plato Saludable Diabético',
            'La regla del 50/25/25: Mitad del plato para vegetales sin almidón, un cuarto para proteínas magras...',
          ),
          _buildArticleCard(
            context,
            'Introducción al Conteo de Carbohidratos',
            'Aprende a leer etiquetas nutricionales y a calcular tu ratio de insulina/carbohidratos...',
          ),
          const SizedBox(height: 16),
          _buildCategoryHeader('Prevención de Complicaciones', Icons.shield, Colors.blue),
          _buildArticleCard(
            context,
            'Cuidado del Pie Diabético',
            'Revisa tus pies a diario, usa calzado cómodo y no camines descalzo. Prevención es la clave...',
          ),
          _buildArticleCard(
            context,
            'Protegiendo tus Riñones y Ojos',
            'El control estricto de la presión arterial y exámenes anuales evitan la progresión de daños...',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String summary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Acá idealmente se navegaría a una pantalla con el artículo completo
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artículo en construcción =]')));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(summary, style: TextStyle(color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              const Text('Leer más...', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
