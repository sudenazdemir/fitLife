import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:flutter/foundation.dart'; // 👈 debugPrint için gerekli
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DataSeeder {
  static Future<void> seedFromApi() async {
    final exerciseBox = Hive.box<Exercise>('exercises');

    // Eğer veri varsa tekrar çekme (API limitini harcamamak için önemli!)
    if (exerciseBox.isNotEmpty) {
      debugPrint("DataSeeder: Veriler zaten var, API isteği atılmadı.");
      return;
    }

    try {
      debugPrint("DataSeeder: API'den veriler çekiliyor...");

      final dio = Dio();

      // ExerciseDB Endpoint'i
      // limit=10 diyerek sadece 10 tane çekiyoruz test için.
      final response = await dio.get(
        'https://exercisedb.p.rapidapi.com/exercises',
        queryParameters: {'limit': '10', 'offset': '0'},
        options: Options(
          headers: {
            'X-RapidAPI-Key': dotenv.env['RAPID_API_KEY'] ?? '',
            'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final List<Exercise> exercises = data.map((json) {
          // 👇 DÜZELTME BURADA: ID'yi alıp linki biz yapıyoruz
          final String exerciseId = json['id'] ?? '0001';
          final String muscle = json['bodyPart'] ?? 'fitness';
          // ExerciseDB'nin genel GIF sunucusu:
          // 👇 YENİ (ÇALIŞAN - GitHub Raw):
          // 👇 YENİ (GARANTİ ÇALIŞAN - Dinamik Resim Servisi):
          // Boşlukları virgülle değiştiriyoruz ki url bozulmasın (örn: "upper legs" -> "upper,legs")
          final String encodedMuscle = muscle.replaceAll(' ', ',');
          final String manualGifUrl =
              'https://loremflickr.com/400/400/gym,fitness,$encodedMuscle/all';
          return Exercise(
            id: exerciseId,
            name: json['name'] ?? 'No Name',
            muscleGroup: json['bodyPart'] ?? 'General',
            equipment: json['equipment'] ?? 'Bodyweight',
            difficulty: 'Intermediate',
            // Instructions bir liste olarak geliyor, onu birleştirip String yapalım:
            description: json['instructions'] != null
                ? (json['instructions'] as List).join("\n")
                : "No description.",

            // Eğer API gifUrl vermediyse (ki vermiyor), biz oluşturduğumuzu kullanalım:
            gifUrl: json['gifUrl'] ?? manualGifUrl,
          );
        }).toList();

        await exerciseBox.addAll(exercises);
        debugPrint(
            "DataSeeder: API'den çekilen ${exercises.length} egzersiz kaydedildi.");
      } else {
        debugPrint("DataSeeder API Hatası: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("DataSeeder Bağlantı Hatası: $e");
    }
  }
}
