import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 1. KAYAR BAŞLIK VE RESİM (SLIVER APP BAR)
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true, // Yukarıda sabit kalması için
            stretch: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                exercise.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16, // Collapsed iken font boyutu
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Arka plan rengi (Resim yoksa veya yüklenirken)
                  Container(color: Colors.white),
                  
                  // Resim / GIF
                  if (exercise.gifUrl != null)
                    Hero(
                      tag: 'exercise_${exercise.id}', // Liste sayfasında da aynı tag varsa animasyonlu geçer
                      child: Image.network(
                        exercise.gifUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_outlined, size: 40, color: colorScheme.error),
                                const SizedBox(height: 8),
                                Text("Image load failed", style: TextStyle(color: colorScheme.error)),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Icon(Icons.fitness_center, size: 80, color: colorScheme.outlineVariant),
                  
                  // Resmin üzerine hafif bir gölge (Yazı okunsun diye)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black12],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. İÇERİK (SliverToBoxAdapter içinde)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiketler (Chips)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInfoChip(
                        context, 
                        label: exercise.muscleGroup, 
                        icon: Icons.accessibility_new_rounded,
                        color: Colors.blue
                      ),
                      _buildInfoChip(
                        context, 
                        label: exercise.equipment, 
                        icon: Icons.fitness_center_rounded,
                        color: Colors.orange
                      ),
                      _buildDifficultyChip(context, exercise.difficulty),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Açıklama Başlığı
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        "Instructions",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Açıklama Metni
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(77),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.description.isNotEmpty
                          ? exercise.description
                          : "No detailed instructions available for this exercise yet.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Alt butonun altında kalmasın diye boşluk
                ],
              ),
            ),
          ),
        ],
      ),
      
      // ALT BUTON (SABİT)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: FilledButton.icon(
            onPressed: () => _showAddToRoutineDialog(context, ref),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Add to Routine"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Standart Bilgi Çipi
  Widget _buildInfoChip(BuildContext context, {required String label, required IconData icon, required Color color}) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color, 
              fontWeight: FontWeight.bold, 
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }

  // Zorluğa Göre Renk Değiştiren Çip
  Widget _buildDifficultyChip(BuildContext context, String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
      case 'expert':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return _buildInfoChip(
      context, 
      label: difficulty, 
      icon: Icons.speed_rounded, 
      color: color
    );
  }

  // --- RUTİNE EKLEME DİYALOGU ---
  void _showAddToRoutineDialog(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.read(routinesListProvider);

    routinesAsync.when(
      loading: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Loading routines..."))),
      error: (e, s) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e"))),
      data: (routines) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Add to Routine',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  if (routines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(Icons.post_add, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            "You don't have any routines yet.",
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          )
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: routines.length,
                        separatorBuilder: (c, i) => const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          final isAlreadyAdded = routine.exerciseIds.contains(exercise.id);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isAlreadyAdded ? Colors.green.withAlpha(25) : Colors.grey.withAlpha(25),
                              child: Icon(
                                isAlreadyAdded ? Icons.check : Icons.add,
                                color: isAlreadyAdded ? Colors.green : Colors.grey,
                              ),
                            ),
                            title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text("${routine.exerciseIds.length} exercises"),
                            onTap: () async {
                              if (isAlreadyAdded) {
                                Navigator.pop(context);
                                return;
                              }
                              // --- 🔥 DÜZELTİLEN KISIM 🔥 ---
                              // 1. Rutin listesine yeni ID'yi ekle
                              final updatedRoutine = Routine(
                                id: routine.id,
                                name: routine.name,
                                daysOfWeek: routine.daysOfWeek,
                                exerciseIds: [...routine.exerciseIds, exercise.id], // Kopyalayarak ekle
                                createdAt: routine.createdAt,
                                reminderHour: routine.reminderHour,
                                reminderMinute: routine.reminderMinute,
                                isReminderEnabled: routine.isReminderEnabled
                              );

                              // 2. Repository üzerinden kaydet (Firebase'e yazar)
                              await ref.read(routineRepositoryProvider).saveRoutine(updatedRoutine);

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${exercise.name} added to ${routine.name}"),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.green,
                                  )
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}