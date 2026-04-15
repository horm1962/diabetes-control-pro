import 'package:flutter/material.dart';

enum ReminderType {
  glucose,
  medication,
}

class ReminderItem {
  final int id;
  final ReminderType type;
  final String title;
  final String body;
  final TimeOfDay time;
  bool isEnabled;

  ReminderItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'hour': time.hour,
      'minute': time.minute,
      'isEnabled': isEnabled,
    };
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as int,
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.medication,
      ),
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      time: TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int),
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}
