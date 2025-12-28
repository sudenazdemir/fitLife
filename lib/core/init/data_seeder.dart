import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DataSeeder {
  static Future<void> seedFromApi() async {
    final exerciseBox = Hive.box<Exercise>('exercises');

    // 🚨 Temizlik Kodu (Hala aktif kalsın ki kediler gitsin)
    await exerciseBox.clear();
    debugPrint("DataSeeder: Kutu temizlendi.");

    try {
      debugPrint("DataSeeder: API'den veriler çekiliyor...");

      final dio = Dio();
      final response = await dio.get(
        'https://exercisedb.p.rapidapi.com/exercises',
        queryParameters: {'limit': '15', 'offset': '0'}, // Sayıyı biraz arttırdım
        options: Options(
          headers: {
            'X-RapidAPI-Key': dotenv.env['RAPID_API_KEY'] ?? '',
            'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // 🔥 KAS GRUBU RESİM HARİTASI (MANUEL & GÜVENLİ)
        // Her kas grubu için Unsplash'ten özel seçilmiş havalı fotolar.
        final Map<String, String> muscleImages = {
          'back': 'https://images.unsplash.com/photo-1603287681836-e174ce5b610d?q=80&w=600&auto=format&fit=crop', // Barfiks
          'cardio': 'https://images.unsplash.com/photo-1538805060512-e2828134b340?q=80&w=600&auto=format&fit=crop', // Koşu
          'chest': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=600&auto=format&fit=crop', // Bench Press
          'lower arms': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600&auto=format&fit=crop', // Dumbbell
          'lower legs': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600&auto=format&fit=crop', // Bacak/Squat
          'neck': 'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?q=80&w=600&auto=format&fit=crop', // Esneme
          'shoulders': 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=600&auto=format&fit=crop', // Omuz Press
          'upper arms': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600&auto=format&fit=crop', // Biceps
          'upper legs': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=600&auto=format&fit=crop', // Squat Rack
          'waist': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600&auto=format&fit=crop', // Karın/Abs
        };

        // Varsayılan resim (Eğer listede yoksa bu çıkar)
        const String defaultImage = 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600&auto=format&fit=crop';

        final List<Exercise> exercises = data.map((json) {
          final String bodyPart = json['bodyPart'] ?? 'unknown';
          
          // Map'ten uygun resmi bul, yoksa varsayılanı kullan
          final String safeImageUrl = muscleImages[bodyPart] ?? defaultImage;

          return Exercise(
            id: json['id'] ?? '0000',
            name: json['name'] ?? 'No Name',
            muscleGroup: bodyPart,
            equipment: json['equipment'] ?? 'Bodyweight',
            difficulty: 'Intermediate',
            description: json['instructions'] != null
                ? (json['instructions'] as List).join("\n")
                : "No description.",
            gifUrl: safeImageUrl, // ARTIK KEDİ YOK! 🦁
          );
        }).toList();

        await exerciseBox.addAll(exercises);
        debugPrint("DataSeeder: ${exercises.length} egzersiz yüklendi. (Kedisiz Versiyon)");

      } else {
        debugPrint("DataSeeder API Hatası: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("DataSeeder Bağlantı Hatası: $e");
    }
  }
}