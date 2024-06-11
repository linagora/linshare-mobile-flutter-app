import 'package:linshare_flutter_app/presentation/util/audio_recorder.dart';
import 'package:flutter_test/flutter_test.dart';

class MockElapsedTime {
  int elapsedMilliseconds = 0;
}

void main() {
  group('formatElapsedTime', () {
    late MockElapsedTime mockElapsedTime;
    late AudioRecorder recorder;

    setUp(() {
      mockElapsedTime = MockElapsedTime();
      recorder = AudioRecorder();
    });

    void testElapsedTime(int milliseconds, String expected) {
      mockElapsedTime.elapsedMilliseconds = milliseconds;
      expect(recorder.formatElapsedTime(milliseconds), expected);
    }

    test('should format time correctly for 0 milliseconds', () {
      testElapsedTime(0, '00:00.00');
    });

    test('should format time correctly for 1 second', () {
      testElapsedTime(1000, '00:01.00');
    });

    test('should format time correctly for 1 minute', () {
      testElapsedTime(60000, '01:00.00');
    });

    test('should format time correctly for 1 minute and 1 second', () {
      testElapsedTime(61000, '01:01.00');
    });

    test(
        'should format time correctly for 1 minute, 1 second and 10 milliseconds',
        () {
      testElapsedTime(61010, '01:01.01');
    });

    test(
        'should format time correctly for 59 minutes, 59 seconds and 999 milliseconds',
        () {
      testElapsedTime(3599999, '59:59.99');
    });
  });
}
