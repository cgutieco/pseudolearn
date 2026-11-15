import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/shell/device_class.dart';

void main() {
  group('DeviceClass.fromWidth (RFC 001 §3.4a)', () {
    test('widths below 600 are compact', () {
      expect(DeviceClass.fromWidth(0), DeviceClass.compact);
      expect(DeviceClass.fromWidth(1), DeviceClass.compact);
      expect(DeviceClass.fromWidth(360), DeviceClass.compact);
      expect(DeviceClass.fromWidth(599), DeviceClass.compact);
    });

    test('599 is compact and 600 is medium: the exact cut', () {
      expect(DeviceClass.fromWidth(599), DeviceClass.compact);
      expect(DeviceClass.fromWidth(600), DeviceClass.medium);
    });

    test('widths from 600 to 959 are medium', () {
      expect(DeviceClass.fromWidth(600), DeviceClass.medium);
      expect(DeviceClass.fromWidth(750), DeviceClass.medium);
      expect(DeviceClass.fromWidth(959), DeviceClass.medium);
    });

    test('959 is medium and 960 is expanded: the exact cut', () {
      expect(DeviceClass.fromWidth(959), DeviceClass.medium);
      expect(DeviceClass.fromWidth(960), DeviceClass.expanded);
    });

    test('widths at and above 960 are expanded', () {
      expect(DeviceClass.fromWidth(960), DeviceClass.expanded);
      expect(DeviceClass.fromWidth(1440), DeviceClass.expanded);
      expect(DeviceClass.fromWidth(10000), DeviceClass.expanded);
    });
  });
}
