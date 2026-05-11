import 'package:flutter_test/flutter_test.dart';
import 'package:controlando_mi_diabetes/models/glucose_log.dart';
import 'package:controlando_mi_diabetes/models/user_profile.dart';
import 'package:controlando_mi_diabetes/services/diabetes_guidelines.dart';

// Subclass to expose internal state for testing without needing a real AuthService
class _TestableGlucoseCalc {
  final List<GlucoseLog> logs;
  _TestableGlucoseCalc(this.logs);

  List<GlucoseLog> get _todayLogs {
    final now = DateTime.now();
    return logs.where((log) =>
        log.timestamp.year == now.year &&
        log.timestamp.month == now.month &&
        log.timestamp.day == now.day).toList();
  }

  Map<String, dynamic> calculateTIR(double low, double high, {bool todayOnly = false}) {
    final source = todayOnly ? _todayLogs : logs;
    if (source.isEmpty) {
      return {'in_range': 0.0, 'high': 0.0, 'low': 0.0, 'total_logs': 0, 'low_episodes': 0, 'high_episodes': 0};
    }
    int inRange = 0, high_ = 0, low_ = 0;
    for (var log in source) {
      if (log.value < low) low_++;
      else if (log.value > high) high_++;
      else inRange++;
    }
    final total = source.length;
    return {
      'in_range': (inRange / total) * 100,
      'high': (high_ / total) * 100,
      'low': (low_ / total) * 100,
      'total_logs': total,
      'low_episodes': low_,
      'high_episodes': high_,
    };
  }
}

GlucoseLog _log(double value, {DateTime? timestamp}) => GlucoseLog(
      id: '1',
      value: value,
      context: GlucoseContext.fasting,
      timestamp: timestamp ?? DateTime.now(),
    );

void main() {
  group('calculateTIR', () {
    test('empty logs returns zeros', () {
      final calc = _TestableGlucoseCalc([]);
      final result = calc.calculateTIR(70, 140);
      expect(result['total_logs'], 0);
      expect(result['in_range'], 0.0);
    });

    test('all in range', () {
      final calc = _TestableGlucoseCalc([_log(100), _log(110), _log(120)]);
      final result = calc.calculateTIR(70, 140);
      expect(result['in_range'], 100.0);
      expect(result['low_episodes'], 0);
      expect(result['high_episodes'], 0);
    });

    test('mixed values calculate correctly', () {
      final calc = _TestableGlucoseCalc([
        _log(50),  // low
        _log(100), // in range
        _log(200), // high
        _log(200), // high
      ]);
      final result = calc.calculateTIR(70, 140);
      expect(result['in_range'], 25.0);
      expect(result['low_episodes'], 1);
      expect(result['high_episodes'], 2);
    });

    test('todayOnly filters out past logs', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final calc = _TestableGlucoseCalc([
        _log(50, timestamp: yesterday),   // past low — must NOT count
        _log(100),                         // today in range
      ]);
      final todayResult = calc.calculateTIR(70, 140, todayOnly: true);
      expect(todayResult['total_logs'], 1);
      expect(todayResult['low_episodes'], 0);

      final allResult = calc.calculateTIR(70, 140, todayOnly: false);
      expect(allResult['total_logs'], 2);
    });
  });

  group('UserProfile.fromJson', () {
    test('parses camelCase fields', () {
      final profile = UserProfile.fromJson({
        'userId': 'u1',
        'firstName': 'Ana',
        'lastName': 'López',
        'diabetesType': 'type1',
        'therapyType': 'insulin',
        'birthDate': '1990-05-15T00:00:00.000Z',
        'weightKg': 65.0,
        'heightCm': 160.0,
        'targetGlucoseLow': 70.0,
        'targetGlucoseHigh': 140.0,
      });
      expect(profile.firstName, 'Ana');
      expect(profile.diabetesType, DiabetesType.type1);
      expect(profile.therapyType, TherapyType.insulin);
      expect(profile.weightKg, 65.0);
    });

    test('parses snake_case fields', () {
      final profile = UserProfile.fromJson({
        'user_id': 'u2',
        'first_name': 'Carlos',
        'last_name': 'Vega',
        'diabetes_type': 'type2',
        'therapy_type': 'oral',
        'birth_date': '1985-01-01',
        'weight_kg': 80,
        'height_cm': 175,
        'target_glucose_low': 80,
        'target_glucose_high': 130,
      });
      expect(profile.lastName, 'Vega');
      expect(profile.diabetesType, DiabetesType.type2);
    });

    test('falls back gracefully on missing fields', () {
      final profile = UserProfile.fromJson({});
      expect(profile.firstName, '');
      expect(profile.weightKg, 0.0);
      expect(profile.diabetesType, DiabetesType.type2);
      expect(profile.therapyType, TherapyType.dietOnly);
    });

    test('falls back gracefully on bad date', () {
      final profile = UserProfile.fromJson({'birthDate': 'not-a-date'});
      expect(profile.birthDate, DateTime(1990, 1, 1));
    });
  });

  group('DiabetesGuidelines', () {
    test('targetRanges returns stricter values for gestational', () {
      final gestational = DiabetesGuidelines.targetRanges(DiabetesType.gestational);
      final type2 = DiabetesGuidelines.targetRanges(DiabetesType.type2);
      expect(gestational['high']! < type2['high']!  , isTrue);
    });

    test('dailyTips returns 3 tips for each type', () {
      for (final type in DiabetesType.values) {
        expect(DiabetesGuidelines.dailyTips(type).length, 3);
      }
    });

    test('imc calculates correctly', () {
      final profile = UserProfile.fromJson({
        'weightKg': 70.0,
        'heightCm': 175.0,
        'birthDate': '1990-01-01',
      });
      final imc = profile.imc;
      expect(imc, closeTo(22.86, 0.1));
    });
  });
}
