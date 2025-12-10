import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fitlife/features/measurements/domain/providers/measurement_provider.dart';
import 'package:fitlife/features/measurements/domain/models/body_measurement.dart';

class MeasurementsPage extends ConsumerWidget {
  const MeasurementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Tracker'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMeasurementSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Log'),
      ),
      body: measurementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (measurements) {
          if (measurements.isEmpty) {
            return Center(
              child: Text(
                'No measurements yet.\nTap + to track your weight.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // Grafiği çizmek için veriyi tarihe göre (eskiden yeniye) sıralamalıyız
          final chartData = List<BodyMeasurement>.from(measurements)
            ..sort((a, b) => a.date.compareTo(b.date));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              // 📈 CHART SECTION
              Text(
                'Weight Trend',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: _WeightChart(data: chartData),
              ),
              const SizedBox(height: 24),

              // 📋 HISTORY LIST
              Text(
                'History',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...measurements.map((m) => _MeasurementCard(measurement: m)),
            ],
          );
        },
      ),
    );
  }

  void _showAddMeasurementSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavye açılınca yukarı itmesi için
      useSafeArea: true,
      builder: (ctx) => const _AddMeasurementForm(),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔹 CHART WIDGET
// -----------------------------------------------------------------------------

class _WeightChart extends StatelessWidget {
  final List<BodyMeasurement> data;

  const _WeightChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (data.length < 2) {
      return Center(child: Text('Add at least 2 logs to see the trend.', style: TextStyle(color: colorScheme.outline)));
    }

    // Min ve Max Y değerlerini belirle (Grafik güzel görünsün diye padding ekle)
    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final minY = (minWeight - 2).floorToDouble();
    final maxY = (maxWeight + 2).ceilToDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1, // Her 1 kg için çizgi (veya aralığa göre dinamik yapılabilir)
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 5), // Y ekseni (Kg)
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                // Sadece başı ve sonu göstererek kalabalığı önleyelim veya modüler yapalım
                if (index == 0 || index == data.length - 1 || index % 3 == 0) {
                   return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(data[index].date),
                      style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: minY > 0 ? minY : 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.weight);
            }).toList(),
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔹 FORM WIDGET (Bottom Sheet)
// -----------------------------------------------------------------------------

class _AddMeasurementForm extends ConsumerStatefulWidget {
  const _AddMeasurementForm();

  @override
  ConsumerState<_AddMeasurementForm> createState() => _AddMeasurementFormState();
}

class _AddMeasurementFormState extends ConsumerState<_AddMeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _weightController = TextEditingController();
  final _fatController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _fatController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text.replaceAll(',', '.'));
      final fat = double.tryParse(_fatController.text.replaceAll(',', '.'));
      final waist = double.tryParse(_waistController.text.replaceAll(',', '.'));
      final hip = double.tryParse(_hipController.text.replaceAll(',', '.'));

      await ref.read(measurementListProvider.notifier).addMeasurement(
        weight: weight,
        bodyFat: fat,
        waist: waist,
        hip: hip,
        date: _selectedDate,
      );

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Klavye
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New Log', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              // Date Picker Row
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg) *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Body Fat %',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _waistController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Waist (cm)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _hipController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Hip (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('SAVE ENTRY'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔹 LIST ITEM CARD
// -----------------------------------------------------------------------------

class _MeasurementCard extends StatelessWidget {
  final BodyMeasurement measurement;

  const _MeasurementCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          '${measurement.weight} kg',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy').format(measurement.date),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (measurement.bodyFat != null)
              _InfoChip(label: '${measurement.bodyFat}% Fat'),
            if (measurement.waist != null) ...[
              const SizedBox(width: 4),
              _InfoChip(label: '${measurement.waist}cm W'),
            ]
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}