import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/glucose_service.dart';
import '../models/glucose_log.dart';
import 'package:intl/intl.dart';
import '../widgets/patient_app_bar_title.dart';

class GlucoseHistoryScreen extends StatefulWidget {
  const GlucoseHistoryScreen({super.key});

  @override
  State<GlucoseHistoryScreen> createState() => _GlucoseHistoryScreenState();
}

class _GlucoseHistoryScreenState extends State<GlucoseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GlucoseService>(context, listen: false).fetchLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PatientAppBarTitle(title: 'Historial de Glucosa'),
      ),
      body: Consumer<GlucoseService>(
        builder: (context, glucoseService, child) {
          if (glucoseService.logs.isEmpty) {
            return const Center(
              child: Text('No hay registros de glucosa aún.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tendencia Semanal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _buildChart(glucoseService.logs),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Registros Recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildLogsList(glucoseService.logs),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(List<GlucoseLog> logs) {
    // Tomamos los últimos 7 registros para el gráfico
    final chartLogs = logs.take(7).toList().reversed.toList();
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartLogs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(chartLogs[value.toInt()].timestamp),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
        lineBarsData: [
          LineChartBarData(
            spots: chartLogs.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(List<GlucoseLog> logs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final log = logs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getGlucoseColor(log.value).withOpacity(0.1),
            child: Icon(Icons.bloodtype, color: _getGlucoseColor(log.value)),
          ),
          title: Text('${log.value.toStringAsFixed(0)} mg/dL'),
          subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp)} - ${log.contextLabel}'),
          trailing: log.notes != null && log.notes!.isNotEmpty
              ? const Icon(Icons.note, size: 16)
              : null,
        );
      },
    );
  }

  Color _getGlucoseColor(double value) {
    if (value < 70) return Colors.orange; // Hipoglucemia
    if (value > 180) return Colors.red; // Hiperglucemia
    return Colors.green; // Rango normal
  }
}
