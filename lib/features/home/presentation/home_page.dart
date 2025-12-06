import 'package:flutter/material.dart';
import 'package:fitlife/core/constants.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
   
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5A5CEB), // mor
            Color(0xFFF2C24F), // sarı
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Burada arka planı ŞEFFAF olan logo kullan:
            Image.asset(
              'assets/icons/fitlife_logo_transperent.png',
              width: 180,
            ),
            const SizedBox(height: 16),
            const Text(
              'Level up your body',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            // home_page.dart içinde build()’de uygun bir yere:
            TextButton.icon(
              onPressed: () {
                context.push(Routes.routineRunner);
              },
              icon: const Icon(Icons.play_circle_outline),

              label: const Text('Start Demo Routine'),
            ),
          ],
        ),
      ),
    );
  }
}

