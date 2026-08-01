import 'package:drifter_buoy/features/general_user/data/models/user_report_search_by_lat_lon_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserReportSearchByLatLonResponse.fromJson', () {
    test('parses nested map coordinates', () {
      final response = UserReportSearchByLatLonResponse.fromJson({
        'statusCode': 200,
        'message': 'ok',
        'isSuccess': true,
        'result': {
          'buoyId': 'BUOY0001',
          'latitude': '+23.060812',
          'longitude': '+80.123456',
        },
      });

      expect(response.latitude, '23.060812');
      expect(response.longitude, '80.123456');
      expect(response.hasCoordinates, isTrue);
    });

    test('parses list of buoy maps', () {
      final response = UserReportSearchByLatLonResponse.fromJson({
        'statusCode': 200,
        'message': 'ok',
        'isSuccess': true,
        'result': [
          {
            'buoyId': 'BUOY0001',
            'latitude': 23.060812,
            'longitude': 80.123456,
          },
        ],
      });

      expect(response.latitude, '23.060812');
      expect(response.longitude, '80.123456');
    });

    test('does not dump nested map into latitude/longitude fields', () {
      final response = UserReportSearchByLatLonResponse.fromJson({
        'statusCode': 200,
        'message': 'ok',
        'isSuccess': true,
        'result': {
          'LatitudeLongitude': {
            'buoyId': 'BUOY0001',
            'latitude': '+23.060812',
            'longitude': '+80.123456',
          },
        },
      });

      expect(response.latitude, '23.060812');
      expect(response.longitude, '80.123456');
      expect(response.latitude.contains('buoyId'), isFalse);
    });

    test('parses object-like result string', () {
      final response = UserReportSearchByLatLonResponse.fromJson({
        'statusCode': 200,
        'message': 'ok',
        'isSuccess': true,
        'result':
            '{buoyId: BUOY0001, latitude: +23.060812, longitude: +80.123456}',
      });

      expect(response.latitude, '23.060812');
      expect(response.longitude, '80.123456');
    });
  });
}
