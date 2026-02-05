import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/exercise_library/domain/providers/exercise_providers.dart';

class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Filtrelenmiş listeyi dinliyoruz
    final asyncExercises = ref.watch(filteredExercisesProvider);
    // Seçili filtre
    final selectedMuscle = ref.watch(exerciseMuscleFilterProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Yaygın kas grupları
    final muscleGroups = [
      'All',
      'chest',
      'back',
      'legs',
      'arms',
      'shoulders',
      'abs', // "waist" yerine genelde "abs" kullanılır ama verine göre değişir
      'cardio',
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Exercise Library', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: Column(
        children: [
          // --- ARAMA ÇUBUĞU (MODERN) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(128),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                    onPressed: () {
                      ref.read(exerciseSearchQueryProvider.notifier).state = '';
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onChanged: (value) {
                  ref.read(exerciseSearchQueryProvider.notifier).state = value;
                },
              ),
            ),
          ),

          // --- KAS GRUBU FİLTRELERİ (YATAY & ŞIK) ---
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: muscleGroups.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final muscle = muscleGroups[index];
                final isAll = muscle == 'All';
                final isSelected =
                    (selectedMuscle == null && isAll) || (selectedMuscle == muscle);

                return FilterChip(
                  label: Text(
                    muscle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
                    ),
                  ),
                  onSelected: (selected) {
                    if (isAll) {
                      ref.read(exerciseMuscleFilterProvider.notifier).state = null;
                    } else {
                      ref.read(exerciseMuscleFilterProvider.notifier).state = muscle;
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // --- EGZERSİZ LİSTESİ ---
          Expanded(
            child: asyncExercises.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises found.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: exercises.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    
                    // Zorluk seviyesine göre renk belirleme
                    Color difficultyColor;
                    switch (exercise.difficulty.toLowerCase()) {
                      case 'beginner': difficultyColor = Colors.green; break;
                      case 'intermediate': difficultyColor = Colors.orange; break;
                      case 'advanced': difficultyColor = Colors.red; break;
                      default: difficultyColor = Colors.grey;
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withAlpha(77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Detay sayfasına git (Extra olarak objeyi gönder)
                          context.push(Routes.exerciseDetail, extra: exercise);
                        },
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // SOL: Renkli Zorluk Çubuğu
                              Container(
                                width: 6,
                                decoration: BoxDecoration(
                                  color: difficultyColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                              ),
                              
                              // ORTA: Resim (Hero Animasyonlu)
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Hero(
                                  tag: 'exercise_${exercise.id}', // Detay sayfasıyla aynı tag!
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(13),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: exercise.gifUrl != null
                                          ? Image.network(
                                              exercise.gifUrl!,
                                              fit: BoxFit.contain, // GIF'in tamamı görünsün
                                              errorBuilder: (c, e, s) => Icon(Icons.fitness_center, color: colorScheme.outline),
                                            )
                                          : Icon(Icons.fitness_center, color: colorScheme.outline),
                                    ),
                                  ),
                                ),
                              ),

                              // SAĞ: Bilgiler
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        exercise.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _buildBadge(theme, exercise.muscleGroup),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "• ${exercise.equipment}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // EN SAĞ: Ok İkonu
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.chevron_right_rounded, 
                                  color: colorScheme.onSurfaceVariant.withAlpha(128)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error loading library: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Küçük Badge Widget'ı
  Widget _buildBadge(ThemeData theme, String text) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}