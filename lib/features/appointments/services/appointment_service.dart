import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class AppointmentService {
  static const _storageKey = 'appointments_v1';
  static const _freeCountKey = 'appointments_free_used';
  static const _freeCountMonthKey = 'appointments_free_month';

  static final AppointmentService _instance = AppointmentService._();
  factory AppointmentService() => _instance;
  AppointmentService._();

  Future<List<Appointment>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Appointment.decodeList(raw);
    } catch (e) {
      debugPrint('[AppointmentService] Decode error: $e');
      return [];
    }
  }

  Future<void> _saveAll(List<Appointment> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Appointment.encodeList(list));
  }

  Future<void> save(Appointment appointment) async {
    final all = await getAll();
    final idx = all.indexWhere((a) => a.id == appointment.id);
    if (idx >= 0) {
      all[idx] = appointment;
    } else {
      all.add(appointment);
    }
    await _saveAll(all);
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((a) => a.id == id);
    await _saveAll(all);
  }

  Future<List<Appointment>> getUpcoming() async {
    final all = await getAll();
    final now = DateTime.now();
    return all
        .where((a) =>
            a.status == AppointmentStatus.upcoming &&
            a.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  Future<List<Appointment>> getCompleted() async {
    final all = await getAll();
    return all
        .where((a) => a.status == AppointmentStatus.completed)
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  /// Check how many free appointments used this month
  Future<int> freeAppointmentsUsedThisMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final month = '${DateTime.now().year}-${DateTime.now().month}';
    final storedMonth = prefs.getString(_freeCountMonthKey) ?? '';
    if (storedMonth != month) {
      // Reset for new month
      await prefs.setInt(_freeCountKey, 0);
      await prefs.setString(_freeCountMonthKey, month);
      return 0;
    }
    return prefs.getInt(_freeCountKey) ?? 0;
  }

  Future<void> incrementFreeCount() async {
    final prefs = await SharedPreferences.getInstance();
    final month = '${DateTime.now().year}-${DateTime.now().month}';
    await prefs.setString(_freeCountMonthKey, month);
    final current = prefs.getInt(_freeCountKey) ?? 0;
    await prefs.setInt(_freeCountKey, current + 1);
  }

  /// Generate available time slots for a given date
  List<DateTime> getAvailableSlots(DateTime date) {
    final slots = <DateTime>[];
    // Generate slots from 9 AM to 9 PM, every 30 min
    for (var hour = 9; hour <= 21; hour++) {
      for (final min in [0, 30]) {
        if (hour == 21 && min == 30) continue;
        final slot = DateTime(date.year, date.month, date.day, hour, min);
        if (slot.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
          slots.add(slot);
        }
      }
    }
    return slots;
  }

  /// Get mood improvement stats
  Future<Map<String, dynamic>> getMoodStats() async {
    final completed = await getCompleted();
    final withMoods = completed
        .where((a) => a.moodBefore != null && a.moodAfter != null)
        .toList();
    if (withMoods.isEmpty) {
      return {'sessions': 0, 'avgImprovement': 0.0};
    }
    double totalImprovement = 0;
    for (final a in withMoods) {
      totalImprovement += (a.moodAfter!.score - a.moodBefore!.score);
    }
    return {
      'sessions': withMoods.length,
      'avgImprovement': totalImprovement / withMoods.length,
    };
  }
}
