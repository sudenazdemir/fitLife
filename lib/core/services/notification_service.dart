import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:fitlife/features/routines/domain/models/routine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Timezone Ayarları
    tz.initializeTimeZones();
    
    // HATA ÇÖZÜMÜ: Gelen veriyi güvenli bir şekilde String'e çeviriyoruz
    final dynamic localTimezoneResult = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = localTimezoneResult.toString();
    
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Eğer telefonun saat dilimi bulunamazsa varsayılan olarak UTC ayarla
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Android & iOS İzin ve Ayarlar
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleRoutineNotifications(Routine routine) async {
    await cancelRoutineNotifications(routine);

    if (!routine.isReminderEnabled ||
        routine.reminderHour == null ||
        routine.reminderMinute == null) {
      return;
    }

    for (final day in routine.daysOfWeek) {
      final notificationId = routine.id.hashCode + day;

      await _scheduleWeeklyNotification(
        id: notificationId,
        title: "It's Workout Time! 💪",
        body: "Time for your '${routine.name}' routine.",
        hour: routine.reminderHour!,
        minute: routine.reminderMinute!,
        dayOfWeek: day,
      );
    }
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int dayOfWeek,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDayAndTime(dayOfWeek, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'routine_channel',
          'Routine Reminders',
          channelDescription: 'Notifications for workout routines',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // HATA ÇÖZÜMÜ: Parametreler v18 sürümüne uygun hale getirildi
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelRoutineNotifications(Routine routine) async {
    for (int i = 1; i <= 7; i++) {
      final notificationId = routine.id.hashCode + i;
      await _notificationsPlugin.cancel(notificationId);
    }
  }
}