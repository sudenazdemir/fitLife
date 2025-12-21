import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/exercise_library/domain/providers/exercise_providers.dart'; // Provider dosyanın doğru yolu
// 👇 BU İKİ SATIRI EKLEMEN GEREKİYOR:
import 'package:go_router/go_router.dart'; 
import 'package:fitlife/core/constants.dart';

class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Filtrelenmiş listeyi dinliyoruz (Arama ve filtreleme otomatik tetiklenir)
    final asyncExercises = ref.watch(filteredExercisesProvider);

    // UI'da hangi filtre seçili göstermek için bunu da dinliyoruz
    final selectedMuscle = ref.watch(exerciseMuscleFilterProvider);

    // API'den gelen yaygın kas grupları (Manuel liste, istersen API verisinden de çekilebilir)
    final muscleGroups = [
      'All',
      'chest',
      'back',
      'legs',
      'arms',
      'shoulders',
      'cardio',
      'waist'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersiz Kütüphanesi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- ARAMA ÇUBUĞU ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Egzersiz ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Aramayı temizle
                    ref.read(exerciseSearchQueryProvider.notifier).state = '';
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                // Her harf girişinde provider'ı güncelle -> liste otomatik yenilenir
                ref.read(exerciseSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // --- KAS GRUBU FİLTRELERİ (YATAY LİSTE) ---
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: muscleGroups.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final muscle = muscleGroups[index];
                final isSelected =
                    (selectedMuscle == null && muscle == 'All') ||
                        (selectedMuscle == muscle);

                return ChoiceChip(
                  label: Text(muscle.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (muscle == 'All') {
                      ref.read(exerciseMuscleFilterProvider.notifier).state =
                          null;
                    } else {
                      ref.read(exerciseMuscleFilterProvider.notifier).state =
                          muscle;
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // --- EGZERSİZ LİSTESİ ---
          Expanded(
            child: asyncExercises.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Eşleşen egzersiz bulunamadı.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // GIF GÖSTERİMİ
                          child: exercise.gifUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    exercise.gifUrl!,
                                    fit: BoxFit.cover,
                                    // GIF yüklenirken dönen çember göster
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                          child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2)));
                                    },
                                    // Hata olursa ikon göster
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                color: Colors.grey),
                                  ),
                                )
                              : const Icon(Icons.fitness_center),
                        ),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "${exercise.muscleGroup.toUpperCase()} • ${exercise.equipment}",
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        // 👇 BURAYI GÜNCELLE
                        onTap: () {
                          // Detay sayfasına git ve egzersiz verisini taşı
                          context.push(Routes.exerciseDetail, extra: exercise);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Bir hata oluştu: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
