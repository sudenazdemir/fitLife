import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

// --- Modeller (Aynı kalıyor) ---
class AiParsedWorkout {
  final List<AiParsedExercise> exercises;
  final String? notes;
  final String? feeling;

  AiParsedWorkout({required this.exercises, this.notes, this.feeling});

  factory AiParsedWorkout.fromJson(Map<String, dynamic> json) {
    return AiParsedWorkout(
      exercises: (json['exercises'] as List?)
              ?.map((e) => AiParsedExercise.fromJson(e))
              .toList() ??
          [],
      notes: json['notes'],
      feeling: json['feeling'],
    );
  }
}

class AiParsedExercise {
  final String name;
  final int? sets;
  final int? reps;
  final double? weight;
  final String? unit;

  AiParsedExercise({
    required this.name,
    this.sets,
    this.reps,
    this.weight,
    this.unit,
  });

  factory AiParsedExercise.fromJson(Map<String, dynamic> json) {
    return AiParsedExercise(
      name: json['name'] ?? 'Unknown',
      sets: json['sets'],
      reps: json['reps'],
      weight: (json['weight'] as num?)?.toDouble(),
      unit: json['unit'],
    );
  }
}

// --- GÜNCELLENMİŞ SERVİS ---
class AiWorkoutService {
  final Dio _dio = Dio();
  
  // URL'in sonundaki "?key=..." kısmını sildik, onu aşağıda dinamik ekleyeceğiz.
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // API Key'i güvenli bir şekilde alıyoruz (boşlukları temizleyerek)
  String? get _apiKey => dotenv.env['GEMINI_API_KEY']?.trim();

  /// Yardımcı Metod: API'ye İstek Atma
  Future<String> _callGemini(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception("API Key .env dosyasında bulunamadı veya boş!");
    }

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
          },
          // Hata durumunda (404, 400 vs) hemen crash olmasın, cevabı okuyalım
          validateStatus: (status) => status != null && status < 500,
        ),
        data: {
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        },
      );

      

      // Başarılı Cevap (200 OK)
      if (response.statusCode == 200) {
        final data = response.data;
        final String? text = data['candidates']?[0]['content']?['parts']?[0]['text'];
        
        if (text == null) throw Exception("AI boş cevap döndü.");
        return text;
      } 
      // 404 veya Başka Hata Durumu
      else {
        // Google'dan gelen detaylı hata mesajını konsola yazalım
        debugPrint("API HATASI (${response.statusCode}): ${response.data}");
        throw Exception("API Hatası: ${response.statusCode} - ${response.statusMessage}");
      }

    } on DioException catch (e) {
      // Bağlantı kopması vs.
      throw Exception("Bağlantı Hatası: ${e.message}");
    } catch (e) {
      throw Exception("Bilinmeyen Hata: $e");
    }
  }

  // 1. Metni Analiz Et
  Future<AiParsedWorkout> parseWorkoutText(String text) async {
    final prompt = '''
    Sen bir JSON dönüştürücüsün. Aşağıdaki spor notunu analiz et.
    Kullanıcı Metni: "$text"
    
    Çıktı SADECE şu formatta JSON olmalı:
    {
      "exercises": [
        {
          "name": "Egzersiz Adı",
          "sets": 3,
          "reps": 10,
          "weight": 50.5,
          "unit": "kg"
        }
      ],
      "notes": "notlar",
      "feeling": "his"
    }
    Lütfen ```json etiketi kullanma, sadece saf JSON ver.
    ''';

    final jsonString = await _callGemini(prompt);
    
    // Temizlik
    final cleanJson = jsonString.replaceAll(RegExp(r'^```json|```$'), '').trim();

    try {
      return AiParsedWorkout.fromJson(jsonDecode(cleanJson));
    } catch (e) {
      debugPrint("Gelen Hatalı JSON: $cleanJson");
      throw Exception("JSON Parse Hatası: $e");
    }
  }

  // 2. Koç Tavsiyesi Ver
  Future<String> generateFeedback(String rawText, AiParsedWorkout parsed) async {
    final prompt = '''
    Kullanıcı antrenman yaptı: "$rawText".
    Hareket sayısı: ${parsed.exercises.length}.
    Ona Türkçe, 2 cümlelik kısa ve motive edici bir koç tavsiyesi ver.
    ''';

    return await _callGemini(prompt);
  }

  Future<void> checkAvailableModels() async {
  final Dio dio = Dio();
  final String? apiKey = dotenv.env['GEMINI_API_KEY']?.trim();

  if (apiKey == null || apiKey.isEmpty) {
    throw Exception("API Key .env dosyasında bulunamadı veya boş!");
  }

  try {
    final response = await dio.get(
      'https://generativelanguage.googleapis.com/v1beta/models',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': apiKey,
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode == 200) {
      debugPrint("Mevcut Modeller: ${response.data}");
    } else {
      debugPrint("Model Listeleme Hatası (${response.statusCode}): ${response.data}");
    }
  } catch (e) {
    debugPrint("Model Listeleme Bağlantı Hatası: $e"); 
  }
}
}