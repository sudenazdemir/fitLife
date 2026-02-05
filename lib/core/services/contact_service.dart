import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class ContactService {
  // Bu fonksiyon telefonun kendi mail uygulamasını açar
  Future<void> sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'destek@fitlife.com', // Buraya hayali veya gerçek bir mail yazabilirsin
      queryParameters: {
        'subject': 'FitLife Destek Talebi',
        'body': 'Merhaba, şu konuda yardım istiyorum: '
      },
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        throw Exception('Mail uygulaması başlatılamadı.');
      }
    } catch (e) {
      debugPrint('Mail gönderme hatası: $e');
    }
  }
}