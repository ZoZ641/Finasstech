import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  Function(String)? onNotificationTap;

  bool get isInitialized => _isInitialized;

  // Initialize
  Future<bool> initNotification() async {
    if (_isInitialized) return true;

    // Initialize timezone database
    tz.initializeTimeZones();
    // Set local timezone - Fix for the LateInitializationError
    try {
      final String timeZoneName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // If local timezone fails, use UTC as fallback
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    //android init settings
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    //ios init settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll handle permissions separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    //init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    //initialize the plugin
    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          onNotificationTap?.call(response.payload!);
        }
      },
    );

    _isInitialized = true;
    return true;
  }

  // Check and request notification permissions
  Future<bool> requestPermissions(BuildContext context) async {
    if (!_isInitialized) {
      await initNotification();
    }

    bool allGranted = true;

    // Request basic notification permission
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        allGranted = false;
        _showPermissionDialog(context, 'Notification', 'notifications');
      }
    }

    // For Android 12+ (API level 31+), request exact alarm permission
    if (Platform.isAndroid) {
      try {
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
            notificationPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidPlugin != null) {
          // Check if exact alarms are permitted
          final bool? exactAlarmsPermitted =
              await androidPlugin.canScheduleExactNotifications();

          if (exactAlarmsPermitted == false) {
            // Request permission
            final bool? requestGranted =
                await androidPlugin.requestExactAlarmsPermission();

            if (requestGranted == false) {
              allGranted = false;
              _showExactAlarmPermissionDialog(context);
            }
          }
        }
      } catch (e) {
        print('Error checking exact alarm permissions: $e');
        allGranted = false;
      }
    }

    return allGranted;
  }

  // Show a dialog explaining why permission is needed
  void _showPermissionDialog(
    BuildContext context,
    String permissionName,
    String usageDescription,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Permission Required'),
          content: Text(
            'This app needs $permissionName permission to send you $usageDescription. '
            'Please enable it in your device settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Special dialog for exact alarm permission
  void _showExactAlarmPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exact Alarm Permission Required'),
          content: const Text(
            'This app needs permission to schedule exact alarms for recurring expenses. '
            'Without this permission, notifications may be delayed.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();

                // Try to open exact alarm settings
                final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
                    notificationPlugin
                        .resolvePlatformSpecificImplementation<
                          AndroidFlutterLocalNotificationsPlugin
                        >();

                if (androidPlugin != null) {
                  await androidPlugin.requestExactAlarmsPermission();
                } else {
                  openAppSettings();
                }
              },
            ),
          ],
        );
      },
    );
  }

  //Notifications Detail Setup
  NotificationDetails notificationDetails(bool isYearly) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        isYearly ? 'yearly_budget_channel' : 'expense_channel',
        isYearly ? 'Yearly Budget Reminder' : 'Expense Reminder',
        channelDescription:
            isYearly
                ? 'This channel is for yearly budget reminders'
                : 'This channel is for expense reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  //Show Notification
  Future<void> showNotification({
    int id = 0,
    bool isYearly = false,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }
    return notificationPlugin.show(
      id,
      title,
      body,
      notificationDetails(isYearly),
    );
  }

  // Fixed method to avoid RangeError
  int generateNotificationIdFromUuidPartial(String uuidString) {
    // Convert UUID to a hash code, ensure it's positive and within Int32 range
    return uuidString.hashCode.abs() % 2147483647; // Max Int32 value
  }

  //Schedule Notification
  Future<void> showScheduleNotification({
    required int id,
    bool isYearly = false,
    required String title,
    required String body,
    required DateTime dateTime,
    bool isMonthly = false,
  }) async {
    // Ensure notifications are initialized before scheduling
    if (!_isInitialized) {
      await initNotification();
    }

    print(
      "notification with title: $title and body: $body and time: ${dateTime.day}-${dateTime.month}-${dateTime.year}",
    );

    // Convert id to string only once to avoid formatting issues
    final String idString = id.toString();
    final int notificationId = generateNotificationIdFromUuidPartial(idString);

    // Create TZDateTime safely
    tz.TZDateTime scheduledDate;
    try {
      scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

      // Ensure the date is in the future
      final now = tz.TZDateTime.now(tz.local);
      if (scheduledDate.isBefore(now)) {
        print("Warning: Scheduled date is in the past. Adjusted to future.");
        // Add one day if the time is in the past
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    } catch (e) {
      // Fallback if timezone conversion fails
      print("Error converting to TZ datetime: $e");
      final now = tz.TZDateTime.now(tz.local);
      scheduledDate = tz.TZDateTime(
        tz.local,
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
      );
    }

    try {
      return await notificationPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        notificationDetails(isYearly),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: idString,
        matchDateTimeComponents:
            isMonthly
                ? DateTimeComponents.dayOfMonthAndTime
                : DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      print("Failed to schedule notification: $e");

      // If exact alarms fail, try to fall back to inexact scheduling
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
        print("Exact alarms not permitted, falling back to inexact scheduling");
        try {
          return await notificationPlugin.zonedSchedule(
            notificationId,
            title,
            body,
            scheduledDate,
            notificationDetails(isYearly),
            androidScheduleMode: AndroidScheduleMode.inexact,
            payload: idString,
            matchDateTimeComponents:
                isMonthly
                    ? DateTimeComponents.dayOfMonthAndTime
                    : DateTimeComponents.dayOfWeekAndTime,
          );
        } catch (fallbackError) {
          print("Even fallback notification scheduling failed: $fallbackError");
        }
      }

      // If all else fails, show an immediate notification
      await showNotification(
        id: notificationId,
        title: "⚠️ $title",
        body:
            "$body\n(Could not schedule for later. Please check app permissions.)",
      );
    }
  }

  Future<void> cancelNotification({required int id}) async {
    final String idString = id.toString();
    final int notificationId = generateNotificationIdFromUuidPartial(idString);

    return notificationPlugin.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    return notificationPlugin.cancelAll();
  }

  // Check if exact alarms are allowed
  Future<bool> checkExactAlarmsPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      return await notificationPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.canScheduleExactNotifications() ??
          false;
    } catch (e) {
      print("Error checking exact alarms permission: $e");
      return false;
    }
  }
}
