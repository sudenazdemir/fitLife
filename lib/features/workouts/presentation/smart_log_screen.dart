import 'package:flutter/material.dart';
import 'package:fitlife/features/workouts/domain/services/workout_processor.dart';
import 'package:fitlife/core/services/ai_workout_service.dart'; // Parsed modelleri (AiParsedWorkout) tanımak için

class SmartLogScreen extends StatefulWidget {
  const SmartLogScreen({super.key});

  @override
  State<SmartLogScreen> createState() => _SmartLogScreenState();
}

class _SmartLogScreenState extends State<SmartLogScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Az önce yazdığımız Processor'ı çağırıyoruz
  final WorkoutProcessor _processor = WorkoutProcessor();

  bool _isLoading = false;
  String? _feedback;
  int? _xpEarned;
  AiParsedWorkout? _parsedResult;

  void _analyzeAndSave() async {
    // Boş metin kontrolü
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen antrenmanını kısaca anlat.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Klavyeyi kapat
    FocusScope.of(context).unfocus();

    try {
      // 🚀 SİHİRLİ AN: Processor çalışıyor...
      final result = await _processor.processAndSave(_controller.text);

      if (result['success'] == true) {
        // İşlem Başarılı!
        setState(() {
          _feedback = result['feedback'];
          _xpEarned = result['xpEarned'];
          _parsedResult = result['parsed'];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🎉 Kaydedildi! +$_xpEarned XP Kazandın!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Processor hata döndürdüyse
        throw Exception(result['error']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bir hata oluştu: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema renklerini alalım
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Akıllı Log 🧠"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Bilgilendirme Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Antrenmanını serbestçe anlat.\nYapay zeka senin için analiz edip kaydetsin.",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Metin Giriş Alanı
            TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Örn: Bugün 3 set 10 tekrar Bench Press yaptım (60kg). Sonra 20 dk koşu bandında koştum. Biraz yorgundum ama iyi geçti.",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Analiz Butonu
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _analyzeAndSave,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isLoading ? "Analiz Ediliyor..." : "Kaydet ve XP Kazan",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            // --- SONUÇ ALANI (İşlem Başarılıysa Görünür) ---
            if (_feedback != null) ...[
              const SizedBox(height: 32),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              
              // Başlık
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "Antrenman Özeti",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // XP Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Text(
                      "+$_xpEarned XP",
                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Koç Yorumu Kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AI Koçun Yorumu:", style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _feedback!,
                      style: const TextStyle(fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Algılanan Hareketler Listesi
              if (_parsedResult != null && _parsedResult!.exercises.isNotEmpty) ...[
                const Text("Algılanan Hareketler:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._parsedResult!.exercises.map((ex) => Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.fitness_center, color: primaryColor, size: 20),
                    ),
                    title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${ex.sets ?? '-'} set x ${ex.reps ?? '-'} tekrar ${ex.weight != null ? '@ ${ex.weight}${ex.unit ?? ''}' : ''}",
                    ),
                  ),
                )),
              ],
            ],
          ],
        ),
      ),
    );
  }
}