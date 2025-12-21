import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      // Alt kısma sabit bir buton koyuyoruz
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
          ],
        ),
        child: FilledButton.icon(
          onPressed: () => _showAddToRoutineDialog(context, ref),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Add to Routine"),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BÜYÜK GIF / RESİM ALANI
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: exercise.gifUrl != null
                  ? Image.network(
                      exercise.gifUrl!,
                      fit: BoxFit.contain,
                      // Hata ayıklama için bu kısmı ekle:
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("RESİM HATASI: $error");
                        debugPrint(
                            "HATALI URL: ${exercise.gifUrl}"); // URL'i konsola bas
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 50, color: Colors.red),
                              Text("Yüklenemedi",
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                  : const Center(
                      child: Icon(Icons.fitness_center,
                          size: 80, color: Colors.grey)),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. BAŞLIK VE ETİKETLER
                  Text(
                    exercise.name,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(theme,
                          label: exercise.muscleGroup,
                          icon: Icons.accessibility_new,
                          color: Colors.blue),
                      _buildChip(theme,
                          label: exercise.equipment,
                          icon: Icons.fitness_center,
                          color: Colors.orange),
                      _buildChip(theme,
                          label: exercise.difficulty,
                          icon: Icons.speed,
                          color: Colors.red),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 3. AÇIKLAMA / TALİMATLAR
                  Text(
                    "Instructions",
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.description.isNotEmpty
                        ? exercise.description
                        : "No description available for this exercise.",
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(height: 1.5, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(ThemeData theme,
      {required String label, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- RUTİNE EKLEME DİYALOGU (Daha önce yazdığımız mantığın aynısı) ---
  void _showAddToRoutineDialog(BuildContext context, WidgetRef ref) {
    // StreamProvider kullanıyorsak .value veya .when kullanmalıyız,
    // ama basitlik için burada repository'den çekiyoruz veya listeyi dinliyoruz.
    final routinesAsync = ref.read(routinesListProvider);

    routinesAsync.when(
      loading: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Loading routines..."))),
      error: (e, s) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e"))),
      data: (routines) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Add ${exercise.name} to...'),
              content: SizedBox(
                width: double.maxFinite,
                child: routines.isEmpty
                    ? const Text(
                        "You don't have any routines yet. Go to Routines tab to create one.")
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: routines.length,
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          final isAlreadyAdded =
                              routine.exerciseIds.contains(exercise.id);

                          return ListTile(
                            leading: Icon(
                              isAlreadyAdded
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isAlreadyAdded ? Colors.green : null,
                            ),
                            title: Text(routine.name),
                            onTap: () async {
                              if (isAlreadyAdded) {
                                Navigator.pop(context);
                                return;
                              }
                              // Ekleme İşlemi
                              routine.exerciseIds.add(exercise.id);
                              await routine.save(); // HiveObject özelliği

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Added to ${routine.name}")));
                              }
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
